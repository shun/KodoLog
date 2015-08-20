//
//  SensorManager.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/01.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit
import CoreLocation

enum ACTIVITY_STS:Int {
    case UNKNOWN = 0
    case STAY = 1
    case MOVE = 2
}

enum LOCATION_STS: Int {
    case STOP = 0
    case STANDARD = 1
    case SIGNIFICANT = 2
}

struct LastLocationInfo {
    var stored: Bool
    var location: CLLocation
}

class SensorManager: NSObject,  LocationControllerDelegate,  MotionActivityControllerDelegate {
// MARK: member
    private var m_locationcontroller: LocationController
    private var m_motionactivitycontroller: MotionActivityController
    private var m_timer: NSTimer?
    private var m_wroteheader: Bool = false
    private var m_docrootpath: String?
    private var m_logdate: String = ""
    private var m_currentlogdate: String = ""
    private var m_lastactivitytype: ACTIVITYTYPE = .INVALID
    private var m_stationarycounter: Int64 = 0
    private var m_movingcounter: Int64 = 0
    private var m_locationsts: LOCATION_STS = .STOP
    private var m_lastlocation: LastLocationInfo
    private var m_laststeps: Int = 0
    private var m_activitysts:ACTIVITY_STS = .UNKNOWN

    class var sharedInstance:SensorManager {
        struct Static {
            static let instance = SensorManager()
        }
        return Static.instance
    }

// MARK: methord
    private override init() {
        m_locationcontroller = LocationController()
        m_motionactivitycontroller = MotionActivityController()
        var loc = CLLocation()
        m_lastlocation = LastLocationInfo(stored: false, location: loc)

        super.init()
        
        m_docrootpath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as? String
        var conditions = NSMutableDictionary()
        conditions["gpsaccuracy"] = 10
        conditions["pauselocationservice"] = false
        conditions["distancefilter"] = 20.0 as Double

        m_locationcontroller.setup(conditions)
        setLocationStatus(.STANDARD)
        m_locationcontroller.startUpdateLocation()
        m_motionactivitycontroller.start()

        m_timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("timercallback"), userInfo: nil, repeats: true)
    }

    func didWroteHeader() ->Bool {
        return m_wroteheader
    }

    func setLocationStatus(sts:LOCATION_STS) {
        var conditions = NSMutableDictionary()

        if (sts == .STANDARD) {
            LogTrace.sharedInstance.debug(format: "GPS accuracy 10m")
            conditions["gpsaccuracy"] = 10
            conditions["activitytype"] = "automotive"
        }
        else if (sts == .SIGNIFICANT) {
            LogTrace.sharedInstance.debug(format: "GPS accuracy 100m")
            conditions["gpsaccuracy"] = 100
            conditions["activitytype"] = "other"
        }

        m_locationcontroller.setup(conditions)
        m_locationsts = sts
    }

    func writeHeader(ofs:NSOutputStream) {
        let header: String = "" +
            "Time," +
            "MOVE Status," +
            "LOC Status," +
            // LocationManager
            "GPS Time," +
            "Latitude," +
            "Longitude," +
            "Altitude," +
            "HAccuracy," +
            "VAccuracy," +
            "GPSAccuracy," +
            "Cource," +
            "Speed," +
            "DistanceFilter," +
            "HeadingFilter," +
            "LMActivityType," +
            // MotionActivityManager
            "Steps," +
            "Distance," +
            "MAActivityType," +
            "FloorAscended," +
            "FloorDescended," +
            // DeviceInfo
            "Name," +
            "SystemName," +
            "SystemVersion," +
            "Model," +
            "LocalizedModel," +
            "Battery Level," +
            "Battery Status\n"

        var ret = ofs.write(header, maxLength:count(header))
        m_wroteheader = true
    }

    func updatestatus() {
        // 滞在中か
        if (isStayingLocation()) {
            m_stationarycounter++

            if (m_stationarycounter > 10) {
                m_movingcounter = 0
            }

            if ((m_locationsts != .SIGNIFICANT) && (m_stationarycounter >= 10 * 60)) {
                // 10分静止していた場合はSignificantLocationに遷移
                setLocationStatus(.SIGNIFICANT)
            }
            m_activitysts = .STAY
        }
        else {
            m_stationarycounter = 0
            m_movingcounter++
            //LogTrace.sharedInstance.debug(format: "m_movingcounter : %d", arguments: m_movingcounter)

            // 20秒以上動き続けててSignificant Locationの場合はStandard Locationに設定する
            if ((m_movingcounter > 5) && (m_locationsts != .STANDARD)) {
                setLocationStatus(.STANDARD)
            }
            m_activitysts = .MOVE
        }

        didMoveCoordinates();
    }

    func writeSensorLog() {
        let now = NSDate()
        var ofs:NSOutputStream
        let curdate = Utility.getDateTimeString(now, format: "yyyyMMdd")
        let filemanager = NSFileManager.defaultManager()

        let logdirpath = m_docrootpath! + "/logs/"
        let path = logdirpath + "/" + curdate + ".csv"

        // ログディレクトリがない場合は作成する
        if (!filemanager.fileExistsAtPath(logdirpath)) {
            filemanager.createDirectoryAtPath(logdirpath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }

        if ((count(m_currentlogdate) != 0) && (curdate != m_currentlogdate)) {
            m_wroteheader = false
            // ファイルの日付が更新されたので、前のファイルをアップロードする
            m_currentlogdate = curdate
        }

        ofs = NSOutputStream(toFileAtPath: path, append: true)!
        ofs.open()

        if (!didWroteHeader()) {
            writeHeader(ofs)
        }

        let curdatetime = Utility.getDateTimeString(now, format: "yyyy-MM-dd HH:mm:ss") + ","
        ofs.write(curdatetime, maxLength: count(curdatetime))
        let movests = String(format:"%@,", m_activitysts == .STAY ? "STAY" : "MOVE")
        ofs.write(movests, maxLength: count(movests))
        let locsts = String(format:"0x%04x,", m_locationsts.rawValue)
        ofs.write(locsts, maxLength: count(locsts))

        writeLocationLog(ofs)
        writeMotionActivityLog(ofs)
        writeMotionLog()
        writeDeviceInfo(ofs)
        ofs.write("\n", maxLength: 1)
        ofs.close()
    }

    func isStayingLocation() -> Bool {
        let activitytype = m_motionactivitycontroller.activitytype
        let laststeps = m_motionactivitycontroller.steps
        var ret: Bool = false

        if (m_laststeps != laststeps) {
            ret = false
            m_laststeps = laststeps
        }
        else if ((activitytype == .INVALID) || (activitytype == .UNKNOWN)) {
            // 取得した種別が不明な場合は前回の有効値を使用する
            if (m_lastactivitytype == .STATIONARY) {
                ret = true
            }
            else {
                // ずっと不明 or 無効な場合なとりあえず動いているとしておく
                ret = false
            }
        }
        else if (activitytype == .STATIONARY) {
            ret = true
        }

        // ステータスが正常な場合のみラスト情報を更新する
        if ((activitytype != .INVALID) && (activitytype != .UNKNOWN)) {
            m_lastactivitytype = activitytype
        }

        return ret
    }

    func didMoveCoordinates() -> Bool {
        var loc = m_locationcontroller.getLastLocation()
        if (loc == nil) {
            return false
        }

        if (m_lastlocation.stored == false) {
            // 最初に取得した座標なので移動したと認識させる
            m_lastlocation.stored = true;
            m_lastlocation.location = loc
            return true;
        }

        if ((m_lastlocation.location.coordinate.latitude == loc.coordinate.latitude) && (m_lastlocation.location.coordinate.longitude == loc.coordinate.longitude)) {
            return false
        }

        m_lastlocation.location = loc
        return true
    }

    func writeLocationLog(ofs:NSOutputStream) {
        let gpstime = Utility.getDateTimeString(m_lastlocation.location.timestamp, format: "yyyy-MM-dd HH:mm:ss")

        let logstr = gpstime + "," +
            String(format:"%f,", m_lastlocation.location.coordinate.latitude) +
            String(format:"%f,", m_lastlocation.location.coordinate.longitude) +
            String(format:"%f,", m_lastlocation.location.altitude) +
            String(format:"%f,", m_lastlocation.location.horizontalAccuracy) +
            String(format:"%f,", m_lastlocation.location.verticalAccuracy) +
            String(format:"%f,", m_locationcontroller.gpsaccuracy) +
            String(format:"%f,", m_lastlocation.location.course) +
            String(format:"%f,", m_lastlocation.location.speed) +
            String(format:"%f,", m_locationcontroller.distancefilter) +
            String(format:"%f,", m_locationcontroller.headingfilter) +
            String(format:"%d,", m_locationcontroller.activitytype.rawValue)

        ofs.write(logstr, maxLength:count(logstr))
    }

    func writeMotionActivityLog(ofs: NSOutputStream) {
        m_laststeps = m_motionactivitycontroller.steps
        var logstr = String(format:"%d,", m_laststeps) +
            String(format:"%d,", m_motionactivitycontroller.distance) +
            String(format:"0x%08x,", m_motionactivitycontroller.activitytype.rawValue) +
            String(format:"%d,", m_motionactivitycontroller.floorsAscended) +
            String(format:"%d,", m_motionactivitycontroller.floorsDescended)

        ofs.write(logstr, maxLength:count(logstr))
    }
    
    func writeMotionLog() {

    }

    func writeDeviceInfo(ofs:NSOutputStream) {
        let deviceinfo = UIDevice.currentDevice()

        var status = ""
        switch(deviceinfo.batteryState) {
            case .Charging:             status = "Charging"
            case .Full:                 status = "Full"
            case .Unknown:              status = "Unknown"
            case .Unplugged:            status = "Unplugged"
        }
        let logstr = deviceinfo.name + "," +
            deviceinfo.systemName + "," +
            deviceinfo.systemVersion + "," +
            deviceinfo.model + "," +
            deviceinfo.localizedModel + "," +
            String(format: "%f,", deviceinfo.batteryLevel * 100) +
            status

        ofs.write(logstr, maxLength:count(logstr))
    }
    
    func timercallback() {
        updatestatus()
#if true
        writeSensorLog()
#else
    if (m_activitysts == .MOVE) {
        writeSensorLog()
    }
#endif
    }

    func updateLocation() {
        LogTrace.sharedInstance.info()
        updatestatus()
        writeSensorLog()
    }

    func updateActivity() {
        LogTrace.sharedInstance.info()
        updatestatus()
        writeSensorLog()
    }
}

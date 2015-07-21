//
//  SensorManager.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/01.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit
import CoreLocation

enum LOCATION_STS: Int {
    case STOP
    case STANDARD
    case SIGNIFICANT
}

class SensorManager: NSObject {
// MARK: member
    private static let instance = SensorManager()
    private var m_locationcontroller: LocationController?
    private var m_motionactivitycontroller: MotionActivityController?
    private var m_timer: NSTimer?
    private var m_wroteheader: Bool = false
    private var m_docrootpath: String?
    private var m_logdate: String = ""
    private var m_currentlogdate: String = ""
    private var m_lastlocation: CLLocation?
    private var m_lastactivitytype: ACTIVITYTYPE = .INVALID
    private var m_stationarycounter: Int64 = 0
    private var m_movingcounter: Int64 = 0
    private var m_locationsts: LOCATION_STS = .STOP

// MARK: methord
    override init() {
        super.init()

        m_docrootpath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as? String
        var conditions = NSMutableDictionary()
        conditions["gpsaccuracy"] = 10
        conditions["pauselocationservice"] = false
        conditions["distancefilter"] = 10.0 as Double
        m_locationcontroller = LocationController()
        m_locationcontroller?.setup(conditions)
        m_motionactivitycontroller = MotionActivityController()
        setLocationStatus(.STANDARD)

        m_timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("timercallback"), userInfo: nil, repeats: true)
    }

    func didWroteHeader() ->Bool {
        return m_wroteheader
    }

    func setLocationStatus(sts:LOCATION_STS) {
        if (sts == .STANDARD) {
            m_locationcontroller?.startUpdateLocation()
            m_locationcontroller?.stopMonitoringSignificantLocation()
        }
        else if (sts == .SIGNIFICANT) {
            m_locationcontroller?.startMonitoringSignificantLocation()
            m_locationcontroller?.stopUpdateLocation()
        }
        m_locationsts = sts
    }
    func writeHeader(ofs:NSOutputStream) {
        let header: String = "" +
            "Time," +
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
            // ファイルの日付が更新されたので、前のファイルをアップロードする
            m_currentlogdate = curdate
        }

        ofs = NSOutputStream(toFileAtPath: path, append: true)!
        ofs.open()

        if (!didWroteHeader()) {
            writeHeader(ofs)
        }

        // 滞在中か
        if (isStationary()) {
            m_stationarycounter++
            m_movingcounter = 0

            if ((m_locationsts != .SIGNIFICANT) && (m_stationarycounter >= 10 * 60)) {
                // 10分静止していた場合はSignificantLocationに遷移
                setLocationStatus(.SIGNIFICANT)
            }
            // 滞在中の場合はログを出力しない
            return
        }
        else {
            m_stationarycounter = 0
            m_movingcounter++

            // 10秒以上動き続けててSignificant Locationの場合はStandard Locationに設定する
            if ((m_movingcounter > 10) && (m_locationsts != .STANDARD)) {
                setLocationStatus(.STANDARD)
            }
        }

        if (!didMoveCoordinates()) {
            // 緯度経度が前回と変わっていない場合はログを出力しない
            return
        }
        let curdatetime = Utility.getDateTimeString(now, format: "yyyy-MM-dd hh:mm:ss") + ","
        ofs.write(curdatetime, maxLength: count(curdatetime))
        writeLocationLog(ofs)
        writeMotionActivityLog(ofs)
        writeMotionLog()
        writeDeviceInfo(ofs)
        ofs.write("\n", maxLength: 1)
        ofs.close()
    }

    func isStationary() -> Bool {
        var ret: Bool = false
        if ((m_motionactivitycontroller?.activitytype == .INVALID) || (m_motionactivitycontroller?.activitytype == .UNKNOWN)) {
            // 取得した種別が不明な場合は前回の有効値を使用する
            if (m_lastactivitytype == .STATIONARY) {
                ret = true
            }
            else {
                // ずっと不明 or 無効な場合なとりあえず動いているとしておく
                ret = false
            }
        }
        else if (m_motionactivitycontroller?.activitytype == .STATIONARY) {
            ret = true
        }
        return ret
    }

    func didMoveCoordinates() -> Bool {
        var loc = m_locationcontroller!.getLastLocation()
        if (loc == nil) {
            return false
        }

        // 前回と同じであればログ出力をしない
        if ((m_lastlocation?.coordinate.latitude == loc.coordinate.latitude) && (m_lastlocation?.coordinate.latitude == loc.coordinate.longitude)) {
            return false
        }

        m_lastlocation = loc
        return true
    }

    func writeLocationLog(ofs:NSOutputStream) {
        let gpstime = Utility.getDateTimeString(m_lastlocation!.timestamp, format: "yyyy-MM-dd hh:mm:ss")

        let logstr = gpstime + "," +
            String(format:"%f,", m_lastlocation!.coordinate.latitude) +
            String(format:"%f,", m_lastlocation!.coordinate.longitude) +
            String(format:"%f,", m_lastlocation!.altitude) +
            String(format:"%f,", m_lastlocation!.horizontalAccuracy) +
            String(format:"%f,", m_lastlocation!.verticalAccuracy) +
            String(format:"%f,", m_locationcontroller!.gpsaccuracy) +
            String(format:"%f,", m_lastlocation!.course) +
            String(format:"%f,", m_lastlocation!.speed) +
            String(format:"%f,", m_locationcontroller!.distancefilter) +
            String(format:"%f,", m_locationcontroller!.headingfilter) +
            String(format:"%d,", m_locationcontroller!.activitytype.rawValue)

        ofs.write(logstr, maxLength:count(logstr))
    }

    func writeMotionActivityLog(ofs: NSOutputStream) {
        var logstr = String(format:"%d,", m_motionactivitycontroller!.steps) +
            String(format:"%d,", m_motionactivitycontroller!.distance) +
            String(format:"%d,", m_motionactivitycontroller!.activitytype.rawValue) +
            String(format:"%d,", m_motionactivitycontroller!.floorsAscended) +
            String(format:"%d,", m_motionactivitycontroller!.floorsDescended)

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
        writeSensorLog()
    }
}

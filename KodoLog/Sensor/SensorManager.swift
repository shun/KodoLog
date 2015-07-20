//
//  SensorManager.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/01.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit
import CoreLocation

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
        m_locationcontroller!.startUpdateLocation()
        m_motionactivitycontroller = MotionActivityController()

        m_timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("timercallback"), userInfo: nil, repeats: true)
    }

    func didWroteHeader() ->Bool {
        return m_wroteheader
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

        let curdatetime = Utility.getDateTimeString(now, format: "yyyy-MM-dd hh:mm:ss") + ","
        ofs.write(curdatetime, maxLength: count(curdatetime))
        writeLocationLog(ofs)
        writeMotionActivityLog(ofs)
        writeMotionLog()
        writeDeviceInfo(ofs)
        ofs.write("\n", maxLength: 1)
        ofs.close()
    }

    func writeLocationLog(ofs:NSOutputStream) {
        var loc = m_locationcontroller!.getLastLocation()
        if (loc == nil) {
            return
        }
        let gpstime = Utility.getDateTimeString(loc.timestamp, format: "yyyy-MM-dd hh:mm:ss")

        let logstr = gpstime + "," +
            String(format:"%f,", loc.coordinate.latitude) +
            String(format:"%f,", loc.coordinate.longitude) +
            String(format:"%f,", loc.altitude) +
            String(format:"%f,", loc.horizontalAccuracy) +
            String(format:"%f,", loc.verticalAccuracy) +
            String(format:"%f,", m_locationcontroller!.gpsaccuracy) +
            String(format:"%f,", loc.course) +
            String(format:"%f,", loc.speed) +
            String(format:"%f,", m_locationcontroller!.distancefilter) +
            String(format:"%f,", m_locationcontroller!.headingfilter) +
            String(format:"%d,", m_locationcontroller!.activitytype.rawValue)

        ofs.write(logstr, maxLength:count(logstr))
    }

    func writeMotionActivityLog(ofs: NSOutputStream) {
        var logstr = String(format:"%d,", m_motionactivitycontroller!.steps) +
            String(format:"%d,", m_motionactivitycontroller!.distance) +
            String(format:"%d,", m_motionactivitycontroller!.activitytype) +
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

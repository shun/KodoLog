//
//  LocationController.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/01.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit
import CoreLocation

enum REQUEST_LOCATION_MODE:Int {
    case UNKNOWN = 0
    case STANDARD = 1
    case SIGNIFICANT = 2
}

protocol LocationControllerDelegate: class {
    func updateLocation()
}

class LocationController: NSObject, CLLocationManagerDelegate {
// MARK: local member
    private var m_locationmanager: CLLocationManager
    private var m_lastlocation: CLLocation?
    private var m_authorized: Bool = false
    private var m_requestmode:REQUEST_LOCATION_MODE

// MARK: getter/setter
    var distancefilter: CLLocationDistance {
        get { return m_locationmanager.distanceFilter }
    }

    var headingfilter: CLLocationDegrees {
        get { return m_locationmanager.headingFilter }
    }

    var activitytype: CLActivityType {
        get { return m_locationmanager.activityType }
    }

    var gpsaccuracy: CLLocationAccuracy {
        get { return m_locationmanager.desiredAccuracy }
    }

// MARK: method
    func setGPSAccuracy(gpsaccuracy:Int32) {
        switch(gpsaccuracy) {
            case 100:
                m_locationmanager.desiredAccuracy = kCLLocationAccuracyHundredMeters

            case 1000:
                m_locationmanager.desiredAccuracy = kCLLocationAccuracyKilometer

            case 3000:
                m_locationmanager.desiredAccuracy = kCLLocationAccuracyKilometer

            case -1:
                m_locationmanager.desiredAccuracy = kCLLocationAccuracyBest

            case -2:
                m_locationmanager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

            case 10:
                fallthrough
            default:
                m_locationmanager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
    }

    override init() {
        m_locationmanager = CLLocationManager()
        m_requestmode = .UNKNOWN
        super.init()

        m_locationmanager.delegate = self
        m_locationmanager.requestAlwaysAuthorization()
        m_locationmanager.headingFilter = kCLHeadingFilterNone
        m_locationmanager.requestAlwaysAuthorization()
    }

    func setup(conditions:NSDictionary) {
        if let gpsaccuracy = conditions["gpsaccuracy"] as? NSNumber {
            self.setGPSAccuracy(gpsaccuracy.intValue)
        }
        if let pauselocationservice = conditions["pauselocationservice"] as? Bool {
            m_locationmanager.pausesLocationUpdatesAutomatically = pauselocationservice
        }
        if let distancefilter = conditions["distancefilter"] as? Double {
            m_locationmanager.distanceFilter = distancefilter
        }
        if let headingfilter = conditions["headingfilter"] as? Double {
            if (headingfilter == 0) {
                m_locationmanager.headingFilter = kCLHeadingFilterNone
            }
            else {
                m_locationmanager.headingFilter = headingfilter
            }
        }
        if let activitytype = conditions["activitytype"] as? String {
            if (activitytype == "automotive") {
                m_locationmanager.activityType = .AutomotiveNavigation
            }
            else if (activitytype == "fitness") {
                m_locationmanager.activityType = .Fitness
            }
            else if (activitytype == "vehicle") {
                m_locationmanager.activityType = .OtherNavigation
            }
            else {
                m_locationmanager.activityType = .Other
            }
        }
    }

    func startUpdateLocation() {
        LogTrace.sharedInstance.info()
        m_requestmode = .STANDARD
        if (m_authorized) {
            m_locationmanager.startUpdatingLocation()
        }
    }

    func stopUpdateLocation() {
        LogTrace.sharedInstance.info()
        m_locationmanager.stopUpdatingLocation()
    }

    func startMonitoringSignificantLocation() {
        LogTrace.sharedInstance.info()
        m_requestmode = .SIGNIFICANT
        if (m_authorized) {
            m_locationmanager.startMonitoringSignificantLocationChanges()
        }
    }

    func stopMonitoringSignificantLocation() {
        LogTrace.sharedInstance.info()
        m_locationmanager.stopMonitoringSignificantLocationChanges()
    }


    func getLastLocation() -> CLLocation! {
        return m_lastlocation;
//        return m_locationmanager.location;
    }

// MARK: delegate
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.AuthorizedAlways) {
            m_authorized = true

            if (m_requestmode == .STANDARD) {
                startUpdateLocation()
            }
            else if (m_requestmode == .SIGNIFICANT) {
                startMonitoringSignificantLocation()
            }
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        LogTrace.sharedInstance.info()
        var lastlocation = locations.last as? CLLocation
        m_lastlocation = lastlocation
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        LogTrace.sharedInstance.error(format: "%@", arguments: error.localizedDescription)
    }

    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        LogTrace.sharedInstance.info()
    }

    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        LogTrace.sharedInstance.info()
    }
}

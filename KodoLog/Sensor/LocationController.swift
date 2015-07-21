//
//  LocationController.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/01.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit
import CoreLocation

class LocationController: NSObject, CLLocationManagerDelegate {
// MARK: local member
    private var m_locationmanager: CLLocationManager?
    private var m_lastlocation: CLLocation?
    private var m_authorized: Bool = false

// MARK: getter/setter
    var distancefilter: CLLocationDistance {
        get { if let distancefilter = m_locationmanager?.distanceFilter {
                return distancefilter
            }
            else {
                return -1
            }
        }
    }

    var headingfilter: CLLocationDegrees {
        get { if let headingfilter = m_locationmanager?.headingFilter {
            return headingfilter
        }
        else {
            return -1
            }
        }
    }

    var activitytype: CLActivityType {
        get { return m_locationmanager!.activityType
        }
    }

    var gpsaccuracy: CLLocationAccuracy {
        get { if let gpsaccuracy = m_locationmanager?.desiredAccuracy {
                return gpsaccuracy
            }
            else {
                return -1
            }
        }
    }

// MARK: method
    func setGPSAccuracy(gpsaccuracy:Int32) {
        switch(gpsaccuracy) {
            case 100:
                m_locationmanager?.desiredAccuracy = kCLLocationAccuracyHundredMeters

            case 1000:
                m_locationmanager?.desiredAccuracy = kCLLocationAccuracyKilometer

            case 3000:
                m_locationmanager?.desiredAccuracy = kCLLocationAccuracyKilometer

            case -1:
                m_locationmanager?.desiredAccuracy = kCLLocationAccuracyBest

            case -2:
                m_locationmanager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation

            case 10:
                fallthrough
            default:
                m_locationmanager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
    }

    override init() {
        super.init()

        m_locationmanager = CLLocationManager()
        m_locationmanager?.delegate = self
        m_locationmanager?.requestAlwaysAuthorization()

    }

    func setup(conditions:NSDictionary) {
        if let gpsaccuracy = conditions["gpsaccuracy"] as? NSNumber {
            self.setGPSAccuracy(gpsaccuracy.intValue)
        }
        if let pauselocationservice = conditions["pauselocationservice"] as? Bool {
            m_locationmanager?.pausesLocationUpdatesAutomatically = pauselocationservice
        }
        if let distancefilter = conditions["distancefilter"] as? Double {
            m_locationmanager?.distanceFilter = distancefilter
        }

    }

    func startUpdateLocation() {
        if (m_authorized) {
            m_locationmanager?.startUpdatingLocation()
        }
        else {
            m_locationmanager?.requestAlwaysAuthorization()
        }
    }

    func stopUpdateLocation() {
        m_locationmanager?.stopUpdatingLocation()
    }

    func startMonitoringSignificantLocation() {
        m_locationmanager?.startMonitoringSignificantLocationChanges()
    }

    func stopMonitoringSignificantLocation() {
        m_locationmanager?.stopMonitoringSignificantLocationChanges()
    }


    func getLastLocation() -> CLLocation! {
        return m_locationmanager?.location;
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.AuthorizedAlways) {
            m_authorized = true
            self.startUpdateLocation()
        }
    }

    /*
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var lastlocation = locations.last as? CLLocation
    }
*/
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("error")
    }
}

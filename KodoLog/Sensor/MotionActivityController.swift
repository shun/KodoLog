//
//  MotionActivityController.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/01.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit
import CoreMotion

enum ACTIVITYTYPE:Int {
    case INVALID
    case STATIONARY
    case WALKING
    case RUNNING
    case AUTOMOTIVE
    case CYCLING
    case UNKNOWN
}

class MotionActivityController: NSObject {
    private var m_motionactivitymanager: CMMotionActivityManager?
    private var m_pedometer: CMPedometer?
    private var m_activitytype: ACTIVITYTYPE = .INVALID
    internal var activitytype: ACTIVITYTYPE {
        get {return m_activitytype}
    }
    private var m_steps: Int = 0
    internal var steps: Int {
        get {return m_steps }
    }
    private var m_distance : Double = 0.0
    internal var distance: Double {
        get {return m_distance }
    }

    private var m_floorsAscended: Int = 0
    internal var floorsAscended:Int {
        get {return m_floorsAscended }
    }
    private var m_floorsDescended: Int = 0
    internal var floorsDescended: Int {
        get {return m_floorsDescended }
    }

    override init() {
    }

    func start() {
        if (!CMMotionActivityManager.isActivityAvailable()) {
            return
        }

        m_motionactivitymanager = CMMotionActivityManager()
        m_motionactivitymanager?.startActivityUpdatesToQueue(NSOperationQueue.mainQueue()) {(activity:CMMotionActivity!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                var activitytype: ACTIVITYTYPE = .INVALID
                if(activity.stationary == true){
                    activitytype = .STATIONARY
                }
                if (activity.walking == true){
                    activitytype = .WALKING
                }
                if (activity.running == true){
                    activitytype = .RUNNING
                }
                if (activity.automotive == true){
                    activitytype = .AUTOMOTIVE
                }
                if (activity.cycling == true){
                    activitytype = .CYCLING
                }
                if (activity.unknown == true) {
                    activitytype = .UNKNOWN
                }
                self.m_activitytype = activitytype
            });
        }

        if(!CMPedometer.isStepCountingAvailable()){
            return
        }

        m_pedometer = CMPedometer()
        m_pedometer?.startPedometerUpdatesFromDate(NSDate(), withHandler: {
            [unowned self] data, error in
            dispatch_async(dispatch_get_main_queue(), {
                if error != nil {
                    // エラー
                }
                else {
                    // 歩数
                    self.m_steps = data.numberOfSteps.integerValue
                    // 距離
                    self.m_distance = data.distance.doubleValue
                    // 上った回数
                    self.m_floorsAscended = data.floorsAscended.integerValue
                    // 降りた回数
                    self.m_floorsDescended = data.floorsDescended.integerValue
                }
            })
        })
    }

    func stop() {
        m_motionactivitymanager?.stopActivityUpdates()
        m_pedometer?.stopPedometerUpdates()
    }
}

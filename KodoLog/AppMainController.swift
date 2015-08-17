//
//  AppMainController.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/20.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit

enum AppMode {
    case INVALID
    case FOREGROUND
    case BACKGROUND
}

class AppMainController: NSObject {
    private var m_sensormanager: SensorManager
    private var m_fileuploader: FileUploader
    private var m_appmode:AppMode = .INVALID

    override init() {
        m_sensormanager = SensorManager.sharedInstance;
        m_fileuploader = FileUploader();
        super.init()
    }

    func setAppMode(mode: AppMode) {
        
    }
}

//
//  AppMainController.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/20.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit

class AppMainController: NSObject {
    private var m_sensormanager: SensorManager?
    private var m_fileuploader: FileUploader?

    override init() {
        super.init()

        m_sensormanager = SensorManager();
        m_fileuploader = FileUploader();
    }
}

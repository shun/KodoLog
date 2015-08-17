//
//  FileUploader.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/20.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit

enum UPLOAD_DEST: Int {
    case DROPBOX
}

class FileUploader: NSObject {
    class func getUploader(dest: UPLOAD_DEST) -> FileUploader? {
        return nil;
    }
}

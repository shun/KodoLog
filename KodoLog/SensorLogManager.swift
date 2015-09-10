//
//  SensorLogManager.swift
//  KodoLog
//
//  Created by KudoShunsuke on 8/17/15.
//  Copyright (c) 2015 KudoShunsuke. All rights reserved.
//

import UIKit

struct S_LOGDATA {
    var latitude: String = ""
    var longitude: String = ""
    var haccuracy: String = ""
}

class SensorLogManager: NSObject {
    class var sharedInstance:SensorLogManager {
        struct Static {
            static let instance = SensorLogManager()
        }
        return Static.instance
    }

    func getDateList(filter: String) ->[String] {
        var datelist: [String] = []
        let docpath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as? String
        let filemanager = NSFileManager.defaultManager()

        let direnums = filemanager.enumeratorAtPath(docpath! + "/logs")

        let filterlen = count(filter)
        while let element = direnums?.nextObject() as? String {
            let filename = element.componentsSeparatedByString(".")[0] as NSString
            if (filename.substringToIndex(filterlen) == filter) {
                datelist.append(filename as String)
            }
        }
        return datelist
    }

    func getLoglist(date:String) -> [String] {
        var loglist: [String] = []

        let docpath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as? String
        let filemanager = NSFileManager.defaultManager()

        let direnums = filemanager.enumeratorAtPath(docpath! + "/logs")

        while let element = direnums?.nextObject() as? String {
            let filename = element.componentsSeparatedByString(".")[0] as NSString
            if (filename == date) {
                // 1つしか存在しないはず
                loglist.append(docpath! + "/logs/" + element)
                break;
            }
        }
        return loglist
    }

    func getLoglist() -> [String] {
        var loglist: [String] = []

        let docpath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as? String
        let filemanager = NSFileManager.defaultManager()

        let direnums = filemanager.enumeratorAtPath(docpath! + "/logs")

        while let element = direnums?.nextObject() as? String {
            loglist.append(docpath! + "/logs/" + element)
        }
        return loglist
    }
}

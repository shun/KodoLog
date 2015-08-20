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

    func loadLogData(path:String) -> [S_LOGDATA] {
        LogTrace.sharedInstance.info(format: "%@", arguments: path)

        var data: [S_LOGDATA] = []
        var lastlat:String = ""
        var lastlng:String = ""
        var latidx:Int = -1
        var lngidx:Int = -1
        var haccuracyidx:Int = -1
        let rawdata = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) as! String
        var logitem:S_LOGDATA = S_LOGDATA()

        LogTrace.sharedInstance.debug(format: "start")
#if true
        var rawdata2:NSData = NSData.dataWithContentsOfMappedFile(path) as! NSData
        var lines = NSString(data: rawdata2, encoding: NSUTF8StringEncoding)?.componentsSeparatedByString("\n")
    var elements:[String]
    for var i = 0; i < lines?.count; i++ {
        let line = lines?[i] as! String
        elements = line.componentsSeparatedByString(",")
        if (elements.count < 2) {
            break
        }

        if (elements[0] == "Time") {
            for (var idx:Int = 0; idx < elements.count; idx++) {
                if (elements[idx] == "Latitude") {
                    latidx = idx
                }
                else if (elements[idx] == "Longitude") {
                    lngidx = idx
                }
                else if (elements[idx] == "HAccuracy") {
                    haccuracyidx = idx
                }
            }
        }
        else {
            if (((elements[latidx]) != lastlat) || ((elements[lngidx]) != lastlng)) {
                lastlat = elements[latidx]
                lastlng = elements[lngidx]
                //                    data.append(logitem)
            }
        }

    }
#else
            rawdata.enumerateLines { (line, stop) -> () in
            let elements: [String] = split( line, allowEmptySlices: true, isSeparator: { $0 == "," } )
            if (elements[0] == "Time") {
                for (var idx:Int = 0; idx < elements.count; idx++) {
                    if (elements[idx] == "Latitude") {
                        latidx = idx
                    }
                    else if (elements[idx] == "Longitude") {
                        lngidx = idx
                    }
                    else if (elements[idx] == "HAccuracy") {
                        haccuracyidx = idx
                    }
                }
            }
            else {
                if (((elements[latidx]) != lastlat) || ((elements[lngidx]) != lastlng)) {
                    lastlat = elements[latidx]
                    lastlng = elements[lngidx]
//                    data.append(logitem)
                }
            }
        }
#endif

        LogTrace.sharedInstance.debug(format: "count : %d", arguments: data.count)
        return data
    }
}

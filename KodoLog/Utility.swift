//
//  Utility.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/14.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit

class Utility: NSObject {
    class func getDateTimeString(date: NSDate, format: String) -> String{
        let dateFormatter = NSDateFormatter()                       // フォーマットの取得
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")  // JPロケール
        dateFormatter.dateFormat = format                           // フォーマットの指定
        return dateFormatter.stringFromDate(date)
    }
}

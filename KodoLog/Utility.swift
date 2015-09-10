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

    class func getColorByRGB(rgba:UInt) ->UIColor {
        return UIColor(
            red:    CGFloat((rgba & 0xFF000000) >> 24) / 255.0,
            green:  CGFloat((rgba & 0x00FF0000) >> 16) / 255.0,
            blue:   CGFloat((rgba & 0x0000FF00) >> 8) / 255.0,
            alpha:  CGFloat(rgba & 0x000000ff) / 255.0
        )
    }

    class func getColorByRGB(r:UInt, g:UInt, b:UInt) ->UIColor {
        return getColorByRGB(r, g: g, b: b, a: 255)
    }

    class func getColorByRGB(r:UInt, g:UInt, b:UInt, a:UInt) ->UIColor {
        let rgba = (r << 24) | (g << 16) | (b << 8) | a
        return getColorByRGB(rgba)
    }
}

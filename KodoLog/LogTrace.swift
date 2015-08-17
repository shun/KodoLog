//
//  LogTrace.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/27.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit

enum TRACE_LVL: Int {
    case VERB
    case INFO
    case DEBUG
    case WARN
    case ERROR
    case UNKNOWN
}

class LogTrace: NSObject {
    private var m_tracelevel: TRACE_LVL
    var tracelevel: TRACE_LVL {
        get {return self.m_tracelevel}
        set {self.m_tracelevel = newValue}
    }
    class var sharedInstance:LogTrace {
        struct Static {
            static let instance = LogTrace()
        }
        return Static.instance
    }

    private var m_docrootpath:String

    override init() {
#if DEBUG
    self.m_tracelevel = .VERB
#else
    self.m_tracelevel = .WARN
#endif
        m_docrootpath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        super.init()
    }

    func verb(filepath: String = __FILE__, funcname:String = __FUNCTION__, lineno:Int = __LINE__) {
        self.verb(filepath: filepath, funcname: funcname, lineno: lineno, format: "")
    }

    func verb(filepath: String = __FILE__, funcname:String = __FUNCTION__, lineno:Int = __LINE__, format:String, arguments:CVarArgType...) {
        let values = getVaList(arguments)
        let str = NSString(format: format, arguments: values) as String

        self.trace(.VERB, filepath: filepath, funcname: funcname, lineno: lineno, contents: str)
    }

    func info(filepath: String = __FILE__, funcname:String = __FUNCTION__, lineno:Int = __LINE__) {
        self.info(filepath: filepath, funcname: funcname, lineno: lineno, format: "")
    }

    func info(filepath: String = __FILE__, funcname:String = __FUNCTION__, lineno:Int = __LINE__, format:String, arguments:CVarArgType...) {
        let values = getVaList(arguments)
        let str = NSString(format: format, arguments: values) as String

        self.trace(.INFO, filepath: filepath, funcname: funcname, lineno: lineno, contents: str)
    }

    func debug(filepath: String = __FILE__, funcname:String = __FUNCTION__, lineno:Int = __LINE__) {
        self.debug(filepath: filepath, funcname: funcname, lineno: lineno, format: "")
    }

    func debug(filepath: String = __FILE__, funcname:String = __FUNCTION__, lineno:Int = __LINE__, format:String, arguments:CVarArgType...) {
        let values = getVaList(arguments)
        let str = NSString(format: format, arguments: values) as String

        self.trace(.DEBUG, filepath: filepath, funcname: funcname, lineno: lineno, contents: str)
    }

    func warn(filepath: String = __FILE__, funcname:String = __FUNCTION__, lineno:Int = __LINE__) {
        self.warn(filepath: filepath, funcname: funcname, lineno: lineno, format: "")
    }

    func warn(filepath: String = __FILE__, funcname:String = __FUNCTION__, lineno:Int = __LINE__, format:String, arguments:CVarArgType...) {
        let values = getVaList(arguments)
        let str = NSString(format: format, arguments: values) as String

        self.trace(.WARN, filepath: filepath, funcname: funcname, lineno: lineno, contents: str)
    }

    func error(filepath: String = __FILE__, funcname:String = __FUNCTION__, lineno:Int = __LINE__) {
        self.error(filepath: filepath, funcname: funcname, lineno: lineno, format: "")
    }

    func error(filepath: String = __FILE__, funcname:String = __FUNCTION__, lineno:Int = __LINE__, format:String, arguments:CVarArgType...) {
        let values = getVaList(arguments)
        let str = NSString(format: format, arguments: values) as String

        self.trace(.ERROR, filepath: filepath, funcname: funcname, lineno: lineno, contents: str)
    }

    func trace(tracelevel:TRACE_LVL, filepath: String, funcname:String, lineno:Int, contents:String) {
        if (tracelevel.rawValue  < self.tracelevel.rawValue) {
            return
        }

        var log:String = ""
        let now = Utility.getDateTimeString(NSDate(), format: "yyyy-MM-dd HH:mm:ss.SSSS")
        let filename = filepath.lastPathComponent
        let tracelabel = [  "[VERB]  ",
                            "[INFO]  ",
                            "[DEBUG] ",
                            "[WARN]  ",
                            "[ERROR] "
        ]

#if false //ENABLE_LOG_ON_FILE
        var ofs:NSOutputStream
        ofs = NSOutputStream(toFileAtPath: m_docrootpath + "/log.txt", append: true)!
        ofs.open()
        log = "\(now) \(tracelabel[tracelevel.rawValue])\(filename)(\(lineno)): \(funcname): \(contents)\n"
        ofs.write(log, maxLength: count(log))
        ofs.close()
#else   // ENABLE_LOG_ON_FILE
#if ENABLE_XCODECOLORS
        let ESCAPE = "\u{001b}["

        let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
        let RESET_BG = ESCAPE + "bg;" // Clear any background color
        let RESET = ESCAPE + ";"   // Clear any foreground or background color


        let tracecolors = [ "fg0,0,0;",             // VERB
                            "fg0,0,0;",             // INFO
                            "fg0,191,255;",         // DEBUG
                            "fg255,165,0;",         // WARN
                            "fg255,0,0;"]           // ERROR

        switch (tracelevel) {
//            case .VERB:
//            case .INFO:
            case .DEBUG:
                fallthrough
            case .WARN:
                fallthrough
            case .ERROR:
                log = "\(ESCAPE)\(tracecolors[tracelevel.rawValue])\(now) \(tracelabel[tracelevel.rawValue])\(filename)(\(lineno)): \(funcname): \(contents)\(RESET)"

            default:
                log = "\(now) \(tracelabel[tracelevel.rawValue])\(filename)(\(lineno)): \(funcname): \(contents)"
        }

        println(log)
#else
    println("\(now) \(tracelabel[tracelevel.rawValue])\(filename)(\(lineno)): \(funcname): \(contents)")
#endif  // ENABLE_XCODECOLORS
#endif  // ENABLE_LOG_ON_FILE
    }
}

//
//  CustomButton.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/08/02.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit

@IBDesignable class CustomButton: UIButton {
    @IBInspectable var textColor: UIColor?
    @IBInspectable var togglests: Bool = false

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }

    @IBInspectable var toggleOnColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.backgroundColor = toggleOnColor.CGColor
        }
    }

    @IBInspectable var toggleOffColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.backgroundColor = toggleOffColor.CGColor
        }
    }

    required init(coder aDecoder: NSCoder) {
        LogTrace.sharedInstance.info()
        super.init(coder: aDecoder)
        layer.backgroundColor = toggleOffColor.CGColor
    }

    func toggle() {
        if (togglests) {
            layer.backgroundColor = toggleOffColor.CGColor
        }
        else {
            layer.backgroundColor = toggleOnColor.CGColor
        }

        togglests = !togglests
    }
}

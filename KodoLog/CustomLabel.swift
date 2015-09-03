//
//  CustomLabel.swift
//  KodoLog
//
//  Created by KudoShunsuke on 9/2/15.
//  Copyright (c) 2015 KudoShunsuke. All rights reserved.
//

import UIKit

@IBDesignable class CustomLabel: UILabel {
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
}

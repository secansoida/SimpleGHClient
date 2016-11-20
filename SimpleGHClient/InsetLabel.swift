//
//  InsetLabel.swift
//  SimpleGHClient
//
//  Created by Justyna Dolińska on 20/11/16.
//  Copyright © 2016 secansoida. All rights reserved.
//

import UIKit

@IBDesignable
class InsetLabel: UILabel {

    var edgeInsets = UIEdgeInsets.zero {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var leftInset : CGFloat {
        set {
            self.edgeInsets.left = newValue
        }
        get {
            return self.edgeInsets.left
        }
    }

    @IBInspectable var rightInset : CGFloat {
        set {
            self.edgeInsets.right = newValue
        }
        get {
            return self.edgeInsets.right
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, self.edgeInsets))
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize;
        size.width += self.edgeInsets.left + self.edgeInsets.right
        size.height += self.edgeInsets.top + self.edgeInsets.bottom
        return size
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {

        let horizontalInsets = self.edgeInsets.left + self.edgeInsets.right;
        let verticalInsets =  self.edgeInsets.top + self.edgeInsets.bottom;
        var insetSize = size;
        insetSize.width = max(0, size.width - horizontalInsets)
        insetSize.height = max(0, size.height - verticalInsets)
        let baseSize = super.sizeThatFits(insetSize)
        return CGSize(width: baseSize.width + horizontalInsets,
                      height: baseSize.height + verticalInsets)
    }

}

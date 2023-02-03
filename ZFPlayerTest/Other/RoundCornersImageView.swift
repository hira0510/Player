//
//  RoundConerImageView.swift
//
//
//  Created by. on 2018/4/10.
//  Copyright © 2018年 Lazy. All rights reserved.
//

import UIKit

class RoundCornersImageView: UIImageView {

    private var firstInit: Bool = false

    /**
     左上角圓角
     */
    @IBInspectable var LeftTop: Bool = false

    /**
     左下角圓角
     */
    @IBInspectable var LeftBotton: Bool = false

    /**
     右上角圓角
     */
    @IBInspectable var RightTop: Bool = false

    /**
     右下角圓角
     */
    @IBInspectable var RightBottom: Bool = false

    /**
     圓角比例，預設為0.5，代表正圓形
     */
    @IBInspectable var RoundCornersRatio: CGFloat = 0.5

    /**
     邊框寬度
     要大於0才會有邊框效果
     */
    @IBInspectable var BorderWidths: CGFloat = 0

    /**
     邊框顏色
     */
    @IBInspectable var BorderColors: UIColor = UIColor.clear

    /**
     圓角的遮罩Layer
     */
    private var roundCornersMask: CAShapeLayer? = nil

    /**
     邊框Layer
     */
    private var borderLayer: CAShapeLayer? = nil

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()

        let cornerRadii = self.bounds.height * RoundCornersRatio

        var RoundingCorners: UInt = 0

        if LeftTop {
            RoundingCorners = RoundingCorners | UIRectCorner.topLeft.rawValue
        }

        if LeftBotton {
            RoundingCorners = RoundingCorners | UIRectCorner.bottomLeft.rawValue
        }

        if RightTop {
            RoundingCorners = RoundingCorners | UIRectCorner.topRight.rawValue
        }

        if RightBottom {
            RoundingCorners = RoundingCorners | UIRectCorner.bottomRight.rawValue
        }

        //第一次初始化
        if firstInit == false {
            roundCornersMask = CAShapeLayer()

            if let roundCornersMask = roundCornersMask {
                roundCornersMask.path = UIBezierPath(roundedRect: self.bounds,
                                                     byRoundingCorners: UIRectCorner.init(rawValue: RoundingCorners),
                                                     cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)).cgPath

                if BorderWidths > 0 {
                    borderLayer = CAShapeLayer()

                    if let borderLayer = borderLayer {
                        borderLayer.path = roundCornersMask.path
                        borderLayer.fillColor = UIColor.clear.cgColor
                        borderLayer.strokeColor = BorderColors.cgColor
                        borderLayer.lineWidth = BorderWidths

                        self.layer.addSublayer(borderLayer)
                    }
                }
            }

            self.layer.mask = roundCornersMask

            firstInit = true
        }

        //第二次之後調用的話，只改變圓角遮罩與邊框遮罩的Path還有PressMask的Bounds
        //需要這樣做是因為Autolayout會多次調整大小並調用layoutSubviews
        if let roundCornersMask = roundCornersMask {
            roundCornersMask.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: UIRectCorner.init(rawValue: RoundingCorners), cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)).cgPath

            if let borderLayer = borderLayer {
                borderLayer.path = roundCornersMask.path
            }
        }
    }

}

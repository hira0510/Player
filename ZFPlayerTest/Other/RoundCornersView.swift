//
// avnight
// GlobalUtil 建立時間：2019/5/28 5:06 PM
//
// 使用的Swift版本：5.0
//      


//
// Copyright © 2019 com. All rights reserved.

import Foundation
import UIKit
@IBDesignable class RoundCornersView: UIView {
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

    @IBInspectable var MasksToBounds: Bool {
        get {
           return self.layer.masksToBounds
        }
        
        set {
            layer.masksToBounds = newValue
        }
    }

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

    /// 起始顏色
    @IBInspectable var startColor: UIColor = .clear {
        didSet { updateColors() }
    }

    /// 結束顏色
    @IBInspectable var endColor: UIColor = .clear {
        didSet { updateColors() }
    }

    /// 起始位置
    @IBInspectable var startLocation: Double = 0.05 {
        didSet { updateLocations() }
    }

    /// 結束位置
    @IBInspectable var endLocation: Double = 0.95 {
        didSet { updateLocations() }
    }

    @IBInspectable var horizontalMode: Bool = false {
        didSet { updatePoints() }
    }

    @IBInspectable var diagonalMode: Bool = false {
        didSet { updatePoints() }
    }

    override class var layerClass: AnyClass { return CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }

    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }

    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()

        updatePoints()
        updateLocations()
        updateColors()

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
            roundCornersMask.path = UIBezierPath(roundedRect: self.bounds,
                                                 byRoundingCorners: UIRectCorner.init(rawValue: RoundingCorners),
                                                 cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)).cgPath

            if let borderLayer = borderLayer {
                borderLayer.path = roundCornersMask.path

            }
        }
    }

}

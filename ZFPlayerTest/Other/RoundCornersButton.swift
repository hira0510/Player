//
//  RoundCornersButton.swift
//  
//
//  Created by  on 2017/1/5.
//  Copyright © 2017年 LIN YUN-SHIUAN. All rights reserved.
//

import UIKit

@IBDesignable class RoundCornersButton: UIButton {

    /**
    就是Row
     */
    public var row: Int?
    /**
    就是Section
     */
    public var section: Int?

    public var indexPath: IndexPath?

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);

        self.addTarget(self, action: #selector(unpressed), for: .touchUpInside); //按下放開
        self.addTarget(self, action: #selector(press), for: .touchDown); //按下
        self.addTarget(self, action: #selector(unpressed), for: .touchDragExit); //按住後手指離開

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    private var firstInit: Bool = false;

    /**
     左上角圓角
     */
    @IBInspectable var LeftTop: Bool = false;

    /**
     左下角圓角
     */
    @IBInspectable var LeftBotton: Bool = false;

    /**
     右上角圓角
     */
    @IBInspectable var RightTop: Bool = false;

    /**
     右下角圓角
     */
    @IBInspectable var RightBottom: Bool = false;

    /**
     圓角比例，預設為0.5，代表正圓形
     */
    @IBInspectable var RoundCornersRatio: CGFloat = 0.5;

    /**
     邊框寬度
     要大於0才會有邊框效果
     */
    @IBInspectable var BorderWidths: CGFloat = 0;

    /**
     邊框顏色
     */
    @IBInspectable var BorderColors: UIColor = UIColor.clear {
        didSet {
            borderLayer?.strokeColor = BorderColors.cgColor
        }
    }

    /**
     圓角的遮罩Layer
     */
    private var roundCornersMask: CAShapeLayer? = nil;

    /**
     遮罩修改前的
     透明度
     */
    private var pressAlphaOriginal: CGFloat = 0;

    /**
     遮罩
     透明度
     */
    @IBInspectable var pressAlpha: CGFloat = 0;

    /**
     按下去的遮罩Layer
     */
    private var pressMask: CALayer? = nil;

    /**
     邊框Layer
     */
    private var borderLayer: CAShapeLayer? = nil;

    override func layoutSubviews() {
        super.layoutSubviews();
        self.layoutIfNeeded();

        let cornerRadii = self.bounds.height * RoundCornersRatio;

        var RoundingCorners: UInt = 0;

        if LeftTop
        {
            RoundingCorners = RoundingCorners | UIRectCorner.topLeft.rawValue;
        }

        if LeftBotton
        {
            RoundingCorners = RoundingCorners | UIRectCorner.bottomLeft.rawValue;
        }

        if RightTop
        {
            RoundingCorners = RoundingCorners | UIRectCorner.topRight.rawValue;
        }

        if RightBottom
        {
            RoundingCorners = RoundingCorners | UIRectCorner.bottomRight.rawValue;
        }

        //第一次初始化
        if firstInit == false
        {
            roundCornersMask = CAShapeLayer();

            if let roundCornersMask = roundCornersMask
            {
                roundCornersMask.path = UIBezierPath(roundedRect: self.bounds,
                                                     byRoundingCorners: UIRectCorner.init(rawValue: RoundingCorners),
                                                     cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)).cgPath;

                if BorderWidths > 0
                {
                    borderLayer = CAShapeLayer();

                    if let borderLayer = borderLayer
                    {
                        borderLayer.path = roundCornersMask.path;
                        borderLayer.fillColor = UIColor.clear.cgColor;
                        borderLayer.strokeColor = BorderColors.cgColor;
                        borderLayer.lineWidth = BorderWidths;

                        self.layer.addSublayer(borderLayer);
                    }
                }
            }

            self.layer.mask = roundCornersMask;

            pressMask = CALayer();

            if let pressMask = pressMask
            {
                //這邊要長寬*2才是正確的尺寸，但是不知道原因！
                pressMask.bounds = CGRect.init(x: 0, y: 0, width: self.bounds.width * 2, height: self.bounds.height * 2);
                pressMask.backgroundColor = PressMaskColor.cgColor;
                pressMask.borderColor = UIColor.red.cgColor
                pressMask.isHidden = true;
                self.layer.addSublayer(pressMask);
            }

            firstInit = true;
        }

        //第二次之後調用的話，只改變圓角遮罩與邊框遮罩的Path還有PressMask的Bounds
        //需要這樣做是因為Autolayout會多次調整大小並調用layoutSubviews
        if let roundCornersMask = roundCornersMask
        {
            roundCornersMask.path = UIBezierPath(roundedRect: self.bounds,
                                                 byRoundingCorners: UIRectCorner.init(rawValue: RoundingCorners),
                                                 cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)).cgPath;

            if let borderLayer = borderLayer
            {
                borderLayer.path = roundCornersMask.path;
            }

            if let pressMask = pressMask
            {
                //這邊要長寬*2才是正確的尺寸，但是不知道原因！
                pressMask.bounds = CGRect.init(x: 0, y: 0, width: self.bounds.width * 2, height: self.bounds.height * 2);

                //初始化時先隱藏遮罩
//                pressMask.isHidden = true;

            }
        }
    }

    /**
     按下時的背景顏色
     */
    @IBInspectable var PressBackgroundColor: UIColor = UIColor.clear;

    /**
     按下時的邊框顏色
     */
    @IBInspectable var PressBorderColor: UIColor = UIColor.clear;

    @IBInspectable var PressMaskColor: UIColor = UIColor.clear;

    private var backgroundColorTemp: UIColor? = nil;

    @objc private func press()
    {
        if let borderLayer = borderLayer
        {
            if PressBorderColor != UIColor.clear
            {
                borderLayer.strokeColor = PressBorderColor.cgColor;
            }
        }

        if PressBackgroundColor != UIColor.clear
        {
            backgroundColorTemp = backgroundColor;
            backgroundColor = PressBackgroundColor;
        }

        if let pressMask = pressMask
        {
            pressMask.isHidden = false;
        }

        if (pressAlpha > 0)
        {
            pressAlphaOriginal = self.alpha
            self.alpha = pressAlpha
        }

    }

    @objc private func unpressed()
    {
        if let borderLayer = borderLayer
        {
            if PressBorderColor != UIColor.clear
            {
                borderLayer.strokeColor = BorderColors.cgColor;
            }
        }

        if PressBackgroundColor != UIColor.clear
        {
            if let backgroundColorTemp = backgroundColorTemp
            {
                backgroundColor = backgroundColorTemp;
            }
        }

        if let pressMask = pressMask
        {
            pressMask.isHidden = true;
        }

        if (pressAlpha > 0)
        {
            self.alpha = pressAlphaOriginal
        }
    }
}

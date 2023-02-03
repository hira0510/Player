//
// avnight
// UIColorExtension 建立時間：2019/7/4 1:28 PM
//
// 使用的Swift版本：5.0
//      


//
// Copyright © 2019 com. All rights reserved.
	

import Foundation
import UIKit

extension UIColor {
    
    /// 從Hex色碼建立實體 , ARGB 模式
    ///
    /// - Parameter argb: 4 byte ARGB
    convenience init(argb: Int) {
        let red: CGFloat = CGFloat((argb >> 16) & 0xff) / 255.0
        let green: CGFloat = CGFloat((argb >> 8) & 0xff) / 255.0
        let blue: CGFloat = CGFloat(argb & 0xff) / 255.0
        let alpha: CGFloat = CGFloat((argb >> 24) & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     從Hex色碼建立實體
     
     @param netHex Hex色碼，例如0xFFFFFF
     @param alpha 不透明度0 ~ 1
     */
    convenience init(_ netHex: Int, alpha: CGFloat = 1.0) {
        
        let red: CGFloat = CGFloat((netHex >> 16) & 0xff) / 255.0
        let green: CGFloat = CGFloat((netHex >> 8) & 0xff) / 255.0
        let blue: CGFloat = CGFloat(netHex & 0xff) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// NavigationBar底線的顏色
    ///
    /// - Parameter argb: none
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = unwrap(UIGraphicsGetImageFromCurrentImageContext(), UIImage())
        UIGraphicsEndImageContext()
        return image
    }
}

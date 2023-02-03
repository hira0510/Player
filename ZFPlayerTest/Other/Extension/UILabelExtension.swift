//
// avnight
// UILabelExtension 建立時間：2019/5/29 12:11 PM
//
// 使用的Swift版本：5.0
//      


//
// Copyright © 2019 com. All rights reserved.


import Foundation
import UIKit

extension UILabel {

    /// Html轉換成String
    ///
    /// - Parameter htmlText: String（Html）
    func setHTMLFromString(htmlText: String) {
        let attrStr = try! NSAttributedString(data: htmlText.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)

        self.attributedText = attrStr
    }

    /// 改變文字間距
    ///
    /// - Parameter space: CGFloat（距離單位）
    func changeWordSpace(space: CGFloat) {
        guard let texts = self.text, self.text != "" else { return }
        let attributedString = NSMutableAttributedString.init(string: texts, attributes: [NSAttributedString.Key.kern: space])
        let paragraphStyle = NSMutableParagraphStyle()
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: texts.count))
        self.attributedText = attributedString
        self.sizeToFit()
    }

    /// 改變文字上下間距
    ///
    /// - Parameter space: CGFloat（距離單位）
    func changeLineSpace(space: CGFloat) {
        guard let texts = self.text, self.text != "" else { return }
        let font = self.font
        let attributedString = NSMutableAttributedString(string: texts, attributes: [.font: font!])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = space
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: texts.count))
        self.attributedText = attributedString
        self.sizeToFit()
    }

    /// 改變文字大小
    ///
    /// - Parameter size: CGFloat（字體大小）
    func setupFontSizeForSE(size: CGFloat) {
        if UIScreen.main.bounds.height <= 568 {
            self.font = self.font.withSize(size - 2.0)
        }
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = unwrap(self.text, "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height / charSize))
        return linesRoundedUp
    }
}

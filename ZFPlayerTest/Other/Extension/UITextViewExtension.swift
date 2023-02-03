//
// avnight
// UITextViewExtension 建立時間：2019/5/29 12:13 PM
//
// 使用的Swift版本：5.0
//
// Copyright © 2019 com. All rights reserved.

import Foundation
import UIKit

extension UITextView {

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
        guard let font = UIFont(name: "PingFangTC-Regular", size: unwrap(self.font?.pointSize, 16)) else { return }
        let attributedString = NSMutableAttributedString(string: texts, attributes: [.font: font])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = space
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: texts.count))
        self.attributedText = attributedString
        self.sizeToFit()
    }

    func scrollToBottom() {
        let textCount: Int = text.lengthOfBytes(using: String.Encoding.utf8)
        guard textCount >= 1 else { return }
        scrollRangeToVisible(NSMakeRange(textCount - 1, 1))
    }
}

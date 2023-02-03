//
// avnight
// GlobalUtil 建立時間：2019/5/23 5:06 PM
//
// 使用的Swift版本：5.0
//


//
// Copyright © 2019 com. All rights reserved.


import Foundation
import UIKit
//TF打開---------------------------
//import Kingfisher
//import OpenMediation
//import Firebase
//import UserNotifications
//import Flurry_iOS_SDK
//import Firebase
//--------------------------------

class GlobalUtil {

    /// 計算高等比放大縮小
    ///
    /// - Parameter width: 被計算的高
    /// - Returns: 回傳CGFloat
    static func calculateHeightScaleWithSize(height: CGFloat) -> CGFloat {
        let scale = height / CGFloat(667)
        let result = UIScreen.main.bounds.height * scale
        return result
    }

    /// 計算寬等比放大縮小
    ///
    /// - Parameter width: 被計算的寬
    /// - Returns: 回傳CGFloat
    static func calculateWidthScaleWithSize(width: CGFloat) -> CGFloat {
        let scale = width / CGFloat(375)
        let result = UIScreen.main.bounds.width * scale
        return result
    }

    /// 計算高等比放大縮小
    /// 667:375
    /// - Parameters:
    ///   - width: 物件寬
    ///   - height: 物件高
    /// - Returns: 回傳CGFloat(等比放大後的高)
    static func calculateHeightScaleWithSize(width: CGFloat, height: CGFloat) -> CGFloat {
        let scale = width / CGFloat(375)
        let itemScale = height / width
        let result = UIScreen.main.bounds.width * scale * itemScale
        return result
    }

    /// 計算螢幕打橫時寬等比放大縮小
    ///
    /// - Parameter width: 被計算的寬
    /// - Returns: 回傳CGFloat
    static func calculateWidthHorizontalScaleWithSize(width: CGFloat) -> CGFloat {
        let scale = width / CGFloat(667)
        let result = UIScreen.main.bounds.width * scale
        return result
    }

    /// 計算高等比放大縮小
    /// 667:375
    /// - Parameters:
    ///   - width: 物件寬
    ///   - height: 物件高
    /// - Returns: 回傳CGFloat(等比放大後的寬)
    static func calculateHeightＨorizontalScaleWithSize(width: CGFloat, height: CGFloat) -> CGFloat {
        let scale = width / CGFloat(667)
        let itemScale = height / width
        let result = UIScreen.main.bounds.width * scale * itemScale
        return result
    }

    /// 計算高等比放大縮小
    ///
    /// - Parameters:
    ///   - height: 要被等比放大的高
    ///   - standardHeight: 設計稿的範例高
    /// - Returns: Returns: 回傳CGFloat（高）
    static func calculateHeightScaleWithSize(height: CGFloat, standardHeight: CGFloat) -> CGFloat {
        let scale = height / CGFloat(standardHeight)
        let result = UIScreen.main.bounds.height * scale
        return result
    }

    /// 計算寬度等比放大縮小(播放器專用)
    ///
    /// - Parameter width: 設計稿的寬
    /// - Returns: 回傳CGFloat
    static func calculateWidthScaleWithSizePlayer(width: CGFloat) -> CGFloat {
        var scale: CGFloat = 0.0
        switch UIScreen.main.bounds.width {
        case 428:
            scale = width / CGFloat(428)
        case 390:
            scale = width / CGFloat(390)
        case 414:
            scale = width / CGFloat(414)
        case 375:
            scale = width / CGFloat(375)
        case 320:
            scale = width / CGFloat(320)
        default:
            scale = width / CGFloat(375)
        }
        let result = UIScreen.main.bounds.height * scale
        return result
    }

    /// 計算cell的寬
    static func calculateCellWidth(str: String, width: CGFloat, size: CGFloat) -> CGSize {
        let textFont = UIFont(name: "PingFangTC-Regular", size: size)!
        let textString = str
        let textMaxSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let textLabelSize = textString.textSize(font: textFont, maxSize: textMaxSize)
        return textLabelSize
    }

    /// 狀態欄高度
    ///
    /// - Returns: 回傳Float
    static func statusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }

    /// 數量文字邏輯
    static func countUnitConvert(count: Int) -> String {
        guard count > 9999 else {
            return String(count)
        }

        guard count > 999999 else {
            let result = Double(count) / 10000
            if count % 10 == 0 {
                return String(format: "\(Int(result))万")
            } else {
                if String(format: "\(String(format: "%.1f", result))万").contains(".0") {
                    return String(format: "\(Int(result) + 1)万")
                } else {
                    return String(format: "\(String(format: "%.1f", result))万")
                }
            }
        }

        let result = Double(count) / 10000
        ceil(result)
        return String(format: "\(Int(result))万")
    }

    static func isIphoneXLastDevice() -> Bool {

        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return false }

        if #available(iOS 11.0, *) {
            //  非 X 系列 bottom 為20
            if window.safeAreaInsets.bottom == 34 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    static func getCurrentDeviceCountry() -> Bool {
        guard let regionCode = Locale.current.regionCode else { return false }

        switch regionCode {
        case "SG", "US", "IE":
            return true
        default:
            return false
        }
    }
    
    /// 回傳當前時間
    ///
    /// - Returns: TimeInterval（秒數）
    static func getCurrentTime() -> TimeInterval {
        return Date().timeIntervalSince1970
    }

    static func currentTimeInterval() -> Int {
        let timeInterval: TimeInterval = NSDate().timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return timeStamp
    }

    ///  指定時間戳的西元年月日時
    ///
    /// - Parameter timeInterval: 指定時間戳
    /// - Returns: 回傳西元年String
    static func specificTimeIntervalStr(timeInterval: TimeInterval, format: String) -> (String) {
        let timeInterval: TimeInterval = TimeInterval(timeInterval)
        let date: Date = Date(timeIntervalSince1970: timeInterval)

        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.dateFormat = format
        dateFormat.locale = Locale(identifier: "zh_Hans_CN")
        dateFormat.timeZone = TimeZone(identifier: "Asia/Shanghai")
        let dateFormatStr = String(dateFormat.string(from: date))

        return dateFormatStr
    }

    // FeedBack回傳時間
    static var timer = 0

    // member倒數時間
    static var memberTimer = 0
    
    // 再次測速時間
    static var speedTestTimer = 0

    // 線上現在時間戳+8
    static var realTime = 0

    static func happyWay(justNumer: Int) -> Bool {
        if judgeRun(justNumer: justNumer) {
            appDelegates()
            return true
        } else {
            let vc = UIStoryboard.loadFirstVC()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            DispatchQueue.main.async {
                appDelegate.window?.rootViewController = vc
            }
            return false
        }
    }


    static func appDelegates() {
        //TF打開
//        Defaults[.isDisPlayPointView] = false
//        FirebaseApp.configure()
//        ImageCache.default.maxMemoryCost = 10
//        // Flurry記錄使用者行為
//        let sessionBuilder = FlurrySessionBuilder()
//            .withLogLevel(FlurryLogLevelDebug)
//            .withCrashReporting(true)
//            .withAppVersion(SystemInfo.getVersion())
//        Flurry.trackPreciseLocation(true)
//        Flurry.startSession(AVNightInfo.flurryAPIKey, with: sessionBuilder)
    }

    /// 回傳true代表現在時間超過設定時間了
    static func judgeRun(justNumer: Int) -> Bool {
        if getCurrentDeviceCountry() || self.realTime < justNumer || UIDevice().modelName == "Simulator" {
            return false
        } else {
            return true
        }
    }
    
    /// 檢查是否是Apple公司的ip
    static func userIpCheck(_ ip: String) -> Bool {
        if let index = ip.firstIndex(of: ".") {
            let greeting = ip[ip.startIndex..<index]
            if greeting == "17" {
                let vc = UIStoryboard.loadFirstVC()
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                DispatchQueue.main.async {
                    appDelegate?.window?.rootViewController = vc
                }
                return false
            }
        }
        return true
    }

    /// 更換AppIcon
    static func updataNew(folderName: String) {
        UIViewController.dismissFirstAlertChangeIcon()
        if #available(iOS 10.3, *) {
            guard UIApplication.shared.supportsAlternateIcons else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIApplication.shared.setAlternateIconName(folderName) { (error) in
                    if error != nil {
                        updataNew(folderName: "default_logo")
                    }
                }
            }
        }
    }
}

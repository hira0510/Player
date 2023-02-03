//
// avnight
// UIStoryboardExtension 建立時間：2019/5/29 10:48 AM
//
// 使用的Swift版本：5.0
//


//
// Copyright © 2019 com. All rights reserved.


import Foundation
import UIKit
import ConnectSDK

extension UIStoryboard {

    /// 載入殼
    ///
    /// - Returns: 回傳UIViewController
    static func loadFirstVC() -> PreviewViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        return vc
    }
    
    /// 載入遙控器
    ///
    /// - Returns: 回傳AirplayControlViewController
    static func loadAirplayControlVC(model: PlayerDLNAModel) -> AirplayControlViewController {
        let vc = UIStoryboard(name: "DLNA", bundle: nil).instantiateViewController(withIdentifier: "AirplayControlViewController") as! AirplayControlViewController
        vc.videoModel = model
        return vc
    }
}

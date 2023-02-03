//
// avnight
// UIViewControllerExtension 建立時間：2019/5/29 11:20 AM
//
// 使用的Swift版本：5.0
//      


//
// Copyright © 2019 com. All rights reserved.
	

import Foundation
import UIKit

extension UIViewController {
    
    /// 把吐司或pop丟在最上層
    func addSubViewOnMostTop(_ view: UIView) {
        if let tabbar = self.tabBarController {
            tabbar.view.addSubview(view)
        } else if let nav = self.navigationController {
            nav.view.addSubview(view)
        } else {
            self.view.addSubview(view)
        }
    }
    
    /// 計算BottomToastView的高&Y
    /// - Parameter height:吐司的高
    /// - Returns: 0:Y 1:高
    func getBottomToastViewHeightY(_ height: CGFloat) -> (CGFloat, CGFloat) {
        let viewHeight: CGFloat = GlobalUtil.calculateWidthScaleWithSize(width: height)
        let isiPhoneX: CGFloat = UIDevice.current.isiPhoneXDevice() ? 40 : 5
        let tabHeight: CGFloat = unwrap(tabBarController?.tabBar.isHidden, true) ? isiPhoneX : unwrap(tabBarController?.tabBar.frame.height, 0) + 5
        return ((UIScreen.main.bounds.height - viewHeight - tabHeight), viewHeight)
    }
    
    /// 找出最上層VC
    func topMostController() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            return nil
        }

        var topController: UIViewController = rootViewController

        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }

        return topController
    }
    
    /// 加入子VC
    func addChildVC(child: UIViewController, selfVC: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: selfVC)
    }
    
    /// 移除自己VC
    func removeSelf() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    public class func dismissFirstAlertChangeIcon() {
        if self != UIViewController.self {
            return
        }
        DispatchQueue.once(token: "ChangeIcon") {
            let orignal = class_getInstanceMethod(self, #selector(UIViewController.present(_: animated: completion:)))
            let swizzling = class_getInstanceMethod(self, #selector(UIViewController.jt_present(_: animated: completion:)))
            if let old = orignal, let new = swizzling {
                method_exchangeImplementations(old, new)
            }
        }
    }
    @objc private func jt_present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if viewControllerToPresent is UIAlertController {
            let alertTitle = (viewControllerToPresent as! UIAlertController).title
            let alertMessage = (viewControllerToPresent as! UIAlertController).message
            if alertTitle == nil && alertMessage == nil {
                return
            }
        }
        self.jt_present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    /// 找出自己類別的名稱
//    func className() -> String {
//        let describing = String(describing: self)
//        if let dotIndex = describing.firstIndex(of: "."), let commaIndex = describing.firstIndex(of: ":") {
//            let afterDotIndex = describing.index(after: dotIndex)
//            if(afterDotIndex < commaIndex) {
//                return String(describing[afterDotIndex ..< commaIndex])
//            }
//        }
//        return describing
//    }
}

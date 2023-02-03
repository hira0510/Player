//
// avnight
// BaseViewController 建立時間：2019/5/29 12:46 PM
//
// 使用的Swift版本：5.0
//
// Copyright © 2019 com. All rights reserved.

import UIKit
import ZFPlayer
import RxSwift

class BaseUIViewController: UIViewController {

    deinit {
        NSLog("\(self.className)釋放")
    }
    /// 螢幕高
    internal var screenHeight: CGFloat = UIScreen.main.bounds.height
    /// 螢幕寬
    internal var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    /// 回收袋子
    internal lazy var bag: DisposeBag! = {
        return DisposeBag()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addPanGestureRecognizer()
    }
    /// 權限自訂窗,前往開啟權限
    internal func openAuthorizedPop(title: String, msg: String, btn1: String? = nil, btn2: String? = nil, cancel: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        if let firstBtnStr = btn1 {
            let settingsAction = UIAlertAction(title: firstBtnStr, style: .default, handler: cancel)
            alertController.addAction(settingsAction)
        }
        if let secondBtn2 = btn2 {
            let settingsAction = UIAlertAction(title: secondBtn2, style: .default, handler: {
                (action) -> Void in
                let url = URL(string: UIApplication.openSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in })
                }
            })
            alertController.addAction(settingsAction)
        }
        return alertController
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    //MARK: - 方法

    /// 加入返回上一頁的手勢
    private func addPanGestureRecognizer() {
        guard let target = self.navigationController?.interactivePopGestureRecognizer?.delegate else { return }
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: target, action: Selector(("handleNavigationTransition:")))
        self.view.addGestureRecognizer(pan)

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        pan.delegate = self
    }

    //MARK: - @objc
    /// Pop回上個頁面
    @objc func previousBack() {
        navigationController?.popViewController(animated: true)
    }

    /// 畫面消失
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate - 返回上一頁手勢
extension BaseUIViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let movePoint: CGPoint = pan.translation(in: self.view)
        let absX: CGFloat = abs(movePoint.x)
        let absY: CGFloat = abs(movePoint.y)
        guard absX > absY, movePoint.x > 0, unwrap(self.navigationController?.children.count, 0) > 1 else { return false }
        return true
    }
}

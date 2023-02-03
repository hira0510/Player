//
// avnight
// UIViewExtension 建立時間：2019/5/30 3:18 PM
//
// 使用的Swift版本：5.0
//
// Copyright © 2019 com. All rights reserved.

import Foundation
import UIKit

extension UIView {

    /// 加入點擊事件
    ///
    /// - Parameters:
    ///   - target: 目標
    ///   - selector: 方法
    ///   - tapsTimes: 點擊次數
    ///   - numberOfFinger: 幾根手指
    func addTouchEvent(target: Any?, selector: Selector, tapsTimes: Int, numberOfFinger: Int) {
        let tap = UITapGestureRecognizer(target: target, action: selector)
        tap.numberOfTapsRequired = tapsTimes
        tap.numberOfTouchesRequired = numberOfFinger
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
    }

    func addSwipeGesture(target: Any?, selector: Selector, numberOfFinger: Int, direction: UISwipeGestureRecognizer.Direction) {
        let tap = UISwipeGestureRecognizer(target: target, action: selector)
        tap.direction = direction
        tap.numberOfTouchesRequired = numberOfFinger
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
    }

    // 拿到被點擊元件的父層（也就是cell）
    func getClickTableViewCell(tableView: UITableView) -> UITableViewCell? {
        let point = self.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return nil }
        return tableView.cellForRow(at: indexPath)
    }

    // 拿到被點擊元件的父層（也就是cell）
    func getClickCollectionViewCell(collectionView: UICollectionView) -> UICollectionViewCell? {
        let point = self.convert(CGPoint.zero, to: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return nil }
        return collectionView.cellForItem(at: indexPath)
    }

    /// 加入
    func addViewAnimate() {
        self.alpha = 0
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
            self.alpha = 1
        }, completion: nil)
    }

    /// 消失
    func removeView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0.0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}

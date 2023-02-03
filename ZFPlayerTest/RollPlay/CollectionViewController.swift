//
//  CollectionViewController.swift
//  ZFPlayerTest
//
//  Created by  on 2022/9/21.
//

//****************這個是滑動播放****************//

import UIKit
import AVFoundation

class CollectionViewController: BasePlayerViewController {
    @IBOutlet weak var mCollectionView: UICollectionView!
    
    let videoStrUrlAry = [
        "https://v.kdianbo.com/20220919/4MRd4Mp5/index.m3u8", "", "", "", "",
        "https://v.kdianbo.com/20220913/qNAIYiYy/index.m3u8", "", "", "", "",
        "https://v.kdianbo.com/20220906/SUiWGXa4/index.m3u8", "", "", "", "",
        "https://v.kdianbo.com/20220829/ynCJlf6L/index.m3u8", "", "", "", "",
        "https://v.kdianbo.com/20220822/6eEPnvE8/index.m3u8", "", "", "", "",
        "https://v.kdianbo.com/20220816/VPSrqZDC/index.m3u8", "", "", "", "",
        "https://v.kdianbo.com/20220808/y08EC8EF/index.m3u8", "", "", "", "",
        "https://v.kdianbo.com/20220906/r25B39az/index.m3u8", "", "", "", "",
        "https://v.kdianbo.com/20220906/NOg0Jj1y/index.m3u8", "", "", "", "",
        "https://v.kdianbo.com/20220906/5F3aqIPB/index.m3u8", "", "", "", "",
        "https://v.kdianbo.com/20220906/6U060gtD/index.m3u8", "", "", "", ""
    ]
    
    // 上一次滑動的ContentOffset
    var historyContentOffset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewAndRegisterXib()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        allCellVideoPlay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        allCellVideoStop()
    }

    // MARK: - private
    /// 設定UI
    private func setupCollectionViewAndRegisterXib() {
        mCollectionView.dataSource = self
        mCollectionView.delegate = self
        mCollectionView.register(cellType: LittleCell.self)
        mCollectionView.register(cellType: BigCell.self)
        mCollectionView.reloadData()
    }
    
    /// 所有當前的cell重新播放(要完整cell出現才播)
    private func allCellVideoPlay() {
        for cell in mCollectionView.visibleCells {
            guard let mCell = cell as? BigCell else { return }
            var visibleRect = CGRect()
            visibleRect.origin = mCollectionView.contentOffset
            visibleRect.size = mCollectionView.bounds.size
            // 要cell完整出現才播
            guard mCell.frame.minY > visibleRect.minY && visibleRect.maxY > mCell.frame.maxY else { return }
            mCell.initPlayerAndPlay(type: .vcAppear(mCell.tag))
            break
        }
    }
    
    /// 所有當前的cell暫停
    private func allCellVideoStop() {
        mCollectionView.visibleCells.forEach { cell in
            guard let mCell = cell as? BigCell, mCell.playerView.getPlayerAssets() != nil else { return }
            mCell.cellEndDisplay(.allStop(mCell.tag))
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoStrUrlAry.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item % 5 == 0 {
            let cell = collectionView.dequeueReusableCell(with: BigCell.self, for: indexPath)
            cell.configCell(index: indexPath.item, urlStr: videoStrUrlAry[indexPath.item], type: .first, vc: self)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(with: LittleCell.self, for: indexPath)
            cell.configCell(index: indexPath.item)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("[Debug][CellPlayer]🟠 點擊\(indexPath.item)")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestViewController") as! TestViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.item % 5 == 0 ? CGSize(width: GlobalUtil.calculateWidthScaleWithSize(width: 345), height: GlobalUtil.calculateWidthScaleWithSize(width: 255)) : CGSize(width: GlobalUtil.calculateWidthScaleWithSize(width: 168), height: GlobalUtil.calculateWidthScaleWithSize(width: 136))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let left = screenWidth - (GlobalUtil.calculateWidthScaleWithSize(width: 168) * 2 + 10)
        return UIEdgeInsets(top: 20, left: left / 2, bottom: 20, right: left / 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == mCollectionView else { return }
        let pan: UIPanGestureRecognizer = scrollView.panGestureRecognizer
        // 滑動方向
        let velocity = pan.velocity(in: scrollView).y
        
        var visibleRect = CGRect()
        visibleRect.origin = scrollView.contentOffset
        visibleRect.size = scrollView.bounds.size
        
        // 偏移的point
        var visiblePoint: CGPoint = CGPoint.zero
        // 使用者是否向上滑動
        let scrollDirectionIsUp: Bool = velocity < -10 || historyContentOffset < visibleRect.origin.y
        // 使用者是否向下滑動
        let scrollDirectionIsDown: Bool = velocity > 10 || historyContentOffset > visibleRect.origin.y
        
        // GlobalUtil.calculateWidthScaleWithSize(width: 255)是影片cell完整出來的大小
        if scrollDirectionIsDown {
            visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.minY + GlobalUtil.calculateWidthScaleWithSize(width: 255))
        } else if scrollDirectionIsUp {
            visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.maxY - GlobalUtil.calculateWidthScaleWithSize(width: 255))
        }
        
        /* 用偏移的point來計算當前cell是哪個indexPath(有分滑動上下)
            cell整個出來才播放(有分滑動上下) */
        if let mIndex = mCollectionView.indexPathForItem(at: visiblePoint)?.item, let cell = self.mCollectionView.cellForItem(at: IndexPath(item: mIndex, section: 0)) as? BigCell, mCollectionView.visibleCells.contains(cell), cell.playerView.getPlayerAssets() == nil, mIndex == cell.tag {
            allCellVideoStop()
            cell.initPlayerAndPlay(type: .scrollPlay(mIndex))
        }
        historyContentOffset = scrollView.contentOffset.y
    }
}

extension CollectionViewController: BasePlayerViewControllerProtocol {
    func playerReadyToPlay(player: ZFPlayerMediaPlayback, assets: URL) {
        guard let index = videoStrUrlAry.firstIndex(of: assets.absoluteString) else { return }
        print("[Debug][CellPlayer]✈️ 播放第\(index)部")
    }
}

class DomainConfig {
    // 與API溝通時組好的字串
    static var apiToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhdm5pZ2h0IiwiZXhwIjoxNjY0MzM5MDM1LCJpcCI6IjEzNC4xNzUuOS4xMzAiLCJwbGF0Zm9ybSI6ImlvcyIsInJlZ2lzdGVyX2lkIjoiMWE1YTNlN2I0NThmYzkxMTE2N2ZmM2JhMDRhOTFmNjZhYjZkNTI2Nzg5ZjAwYTJmODcyZWI3Y2U3NGUyZDRmMiIsInN5c3RlbV90aW1lIjoxNjYzOTA3MDM1LCJtZW1iZXJfaWQiOjEwOSwiYWNjb3VudCI6ImFhQGFhLmFhIiwicGFzc3dvcmQiOiJhYWFhYWEiLCJib3VnaHRfdmlwX2JlZm9yZSI6MSwidmlwX3RpbGwiOjQyOTQ5NjcyOTUsInZpcF9sZXZlbCI6MTAsImRyaW5rIjoxMjI1NTEsImZhbnMiOjE5LCJmYXZvcml0ZV9saW1pdCI6OTk5OTksImZvbGRlcl9saW1pdCI6OTk5OSwiZm9sbG93IjoyMCwiaGVhZCI6Imh0dHBzOi8vOXFjbC55YW5nZ3VhbmdpbmcuY29tL2hlYWQvaW1nLzEwOS8yMDIxLTA1LTA3LzA2NjRlYzM5MTcxN2RlNDY0YzdhNTdlNmFkMzU3MzRlNDQ0Mzc3ZjMtMyIsImhpZ2hfZG93bmxvYWRfY291bnQiOjEyMDA0OSwiaGlnaF9kb3dubG9hZF91bmxpbWl0ZWQiOnRydWUsIm5vcm1hbF9kb3dubG9hZF9jb3VudCI6Miwibm9ybWFsX2Rvd25sb2FkX3VubGltaXRlZCI6dHJ1ZSwiaW1wb3J0X2xpbWl0Ijo5OTksIm1lbWJlcl9wYWdlIjp0cnVlLCJuYW1lIjoiaGhoVGVzdCIsInBvaW50IjoyMjU3Miwic3RhdHVzIjp0cnVlLCJzdWJzY3JpYmVfbGltaXQiOjk5OTk5LCJmcmVlX2NvbGxlY3RfZXhwaXJhdGlvbl9kYXRlIjoxNjUzNDc3MjU0LCJpc19zaWduIjpmYWxzZSwibGl2ZV92aXBfbGV2ZWwiOjIsImFjY3VtdWxhdGVkX2Ftb3VudCI6MCwiZnJlZV9saXZlX3ZpcF90aWxsIjowLCJ3YXRjaF9jb3VudCI6MCwiY25fbGl2ZV93YXRjaF9jb3VudCI6MCwidGltZV9saW1pdGVkX2ZyZWUiOmZhbHNlfQ.YTUJq7bCwF57LPZ6x5VUJNt-iWYaVlNmJvb6OjVuUx4"
}

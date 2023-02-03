//
//  BigCell.swift
//  ZFPlayerTest
//
//  Created by  on 2022/9/21.
//

import UIKit
import AVFoundation

class BigCell: UICollectionViewCell {

    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playerView: ForCellPlayerView!
    @IBOutlet weak var mImageView: UIImageView!
    
    var firstPlay: Bool = true
    var urlStr: String = ""
    weak var parentVc: CollectionViewController? = nil
    
    static var nib: UINib {
        return UINib(nibName: "BigCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loading.startAnimating()
        loading.isHidden = true
    }
    
    public func configCell(index: Int, urlStr: String, type: CellPlayerStatusType, vc: CollectionViewController? = nil) {
        titleLabel.text = "我是第\(index)部影片"
        self.tag = index
        self.urlStr = urlStr
        self.parentVc = vc
        
        // 如果是第一部的話我們要先播，因為沒有滑動
        if firstPlay && self.tag == 0 {
            initPlayerAndPlay(type: type)
        }
        firstPlay = false
    }
    
    public func initPlayerAndPlay(type: CellPlayerStatusType) {
        self.playerView.initPlayer(index: self.tag, cell: self, player: parentVc)
        self.playerView.zfPlayerSetUrlPlay(urlStr: urlStr, type: type)
        mImageView.isHidden = true
        loading.isHidden = false
    }
}

extension BigCell: CellPlayerViewDelegate {
    
    /// 播放器成功播放後
    func playSuccess() {
        mImageView.isHidden = true
        loading.isHidden = true
    }
    /// 播放器停止後
    func playEnd() {
        mImageView.isHidden = false
        loading.isHidden = true
    }
    /// 播放器停止(雙向使用)
    func cellEndDisplay(_ type: CellPlayerStatusType) {
        self.playerView.playerStop(type)
        self.playEnd()
    }
}

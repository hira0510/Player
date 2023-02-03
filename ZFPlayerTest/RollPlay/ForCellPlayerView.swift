//
//  ForCellPlayerView.swift
//  ZFPlayerTest
//
//  Created by Hira on 2022/9/21.
//

import UIKit
import AVFoundation
import ZFPlayer

enum CellPlayerStatusType {
    case first
    case scrollPlay(_ tag: Int)
    case vcAppear(_ tag: Int)
    case playEnd(_ tag: Int)
    case allStop(_ tag: Int)
    case urlFail(_ tag: Int, _ url: String)
    
    var value: (msg: String, tag: Int) {
      switch self {
      case .first:
        return ("[Debug][CellPlayer]🟢 第一個影片播放", 0)
      case .scrollPlay(let tag):
        return ("[Debug][CellPlayer]🟢 \(tag) 滑動播放", tag)
      case .vcAppear(let tag):
        return ("[Debug][CellPlayer]🟢 \(tag) vc從別的頁面回來播放", tag)
      case .playEnd(let tag):
        return ("[Debug][CellPlayer]❌ \(tag) 15s播放結束", tag)
      case .allStop(let tag):
        return ("[Debug][CellPlayer]❌ \(tag) 結束播放", tag)
      case .urlFail(let tag, let url):
        return ("[Debug][CellPlayer]❌ \(tag) url錯誤: \(url)", tag)
      }
    }
}

/// 此View通知Cell
protocol CellPlayerViewDelegate: AnyObject {
    func playSuccess()
    func playEnd()
    func cellEndDisplay(_ type: CellPlayerStatusType)
}

class ForCellPlayerView: UIView {
    /// 播放器的delegate
    private weak var playerDelegate: BasePlayerViewControllerProtocol?
    /// Cell的delegate
    private weak var cellDelegate: CellPlayerViewDelegate?
    /// 從哪裡開始播放
    private var playerStartTime: TimeInterval = 0.0

    /// 播放器的UI控制層
    private lazy var zfControlView: ZFPlayerControlView = ZFPlayerControlView()
    /// 播放器的VC
    private lazy var zfPlayer: ZFPlayerController = ZFPlayerController()
    /// 播放器的核心（播放開始、暫停等等邏輯層）
    private lazy var zfPlayerManager: ZFAVPlayerManager = ZFAVPlayerManager()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSelf()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSelf()
    }

    /// 初始化播放器跟協定
    func initPlayer(index: Int, cell cellDelegate: CellPlayerViewDelegate?, player playerDelegate: BasePlayerViewControllerProtocol?) {
        setupPlayerWithContentViews(index)
        setPlayerHandler()
        playerViewConfig(cellDelegate: cellDelegate, playerDelegate: playerDelegate)
    }
    
    /// 設定url並播放
    func zfPlayerSetUrlPlay(urlStr: String, type: CellPlayerStatusType) {
        guard zfPlayer.assetURLs == nil else { return }
        guard let url = URL(string: urlStr) else {
            cellDelegate?.cellEndDisplay(.urlFail(type.value.tag, urlStr))
            return
        }
        print(type.value.msg)
        zfPlayer.assetURLs = [url]
        zfPlayer.playTheIndex(0)
    }

    /// 播放器停止
    func playerStop(_ type: CellPlayerStatusType) {
        print(type.value.msg)
        self.cellDelegate?.playEnd()
        self.zfPlayer.stop()
        self.zfPlayer.isViewControllerDisappear = true
        self.zfPlayer = ZFPlayerController()
        self.zfPlayerManager = ZFAVPlayerManager()
        self.zfControlView = ZFPlayerControlView()
        self.playerStartTime = 0
        self.cellDelegate = nil
        self.playerDelegate = nil
    }
    
    func getPlayerAssets() -> [URL]? {
        return zfPlayer.assetURLs
    }
    
    private func initSelf() {
        self.backgroundColor = .black
    }

    /// 配置一般播放器
    private func setupPlayerWithContentViews(_ index: Int) {
        var authorization = [String: Any]()
        authorization["Authorization"] = DomainConfig.apiToken
        self.zfPlayerManager.requestHeader = authorization
        self.zfPlayerManager.isMuted = true
        self.zfPlayer = ZFPlayerController(playerManager: self.zfPlayerManager, containerView: self)
        self.zfPlayer.containerView.tag = index
        self.zfPlayer.containerView.isUserInteractionEnabled = false
        self.zfControlView.isHidden = true
        self.zfPlayer.gestureControl.disableTypes = .all
        self.zfPlayer.controlView = self.zfControlView
    }

    /// 協定
    private func playerViewConfig(cellDelegate: CellPlayerViewDelegate?, playerDelegate: BasePlayerViewControllerProtocol?) {
        self.cellDelegate = cellDelegate
        self.playerDelegate = playerDelegate
    }

    /// 跳轉播放
    private func randonRangePlay(_ totalTime: TimeInterval) {
        guard totalTime > 0, self.playerStartTime <= 0 else { return }
        var startTime: TimeInterval = 0.0
        if totalTime < 360 { // 5分鐘以內從頭開始播
            startTime = 0
        } else if 360 <= totalTime && totalTime < 1800 { // 6~30分鐘內 20%開始
            startTime = totalTime * 0.2
        } else { // 30分鐘以上 50%開始
            startTime = totalTime * 0.5
        }

        self.playerStartTime = startTime

        guard startTime > 0 else {
            self.cellDelegate?.playSuccess()
            return
        }

        self.zfPlayerManager.seek(toTime: startTime) { [weak self] _ in
            guard let `self` = self else { return }
            self.cellDelegate?.playSuccess()
        }
    }

    /// 播放15秒停止
    private func play15sStop(_ currentTime: TimeInterval) {
        guard currentTime > self.playerStartTime + 15 else { return }
        playerStop(.playEnd(self.tag))
    }

    /// 播放器Handler
    private func setPlayerHandler() {
        zfPlayer.playerReadyToPlay = { [weak self] player, assets in
            guard let `self` = self else { return }
            self.randonRangePlay(player.totalTime ?? 0)
            self.playerDelegate?.playerReadyToPlay?(player: player, assets: assets)
        }

        zfPlayer.playerPlayTimeChanged = { [weak self] player, currentTime, totalTime in
            guard let `self` = self else { return }
            self.playerDelegate?.playerPlayTimeChanged?(player: player, currentTime: currentTime, totalTime: totalTime)
            self.play15sStop(currentTime)
        }

        zfPlayer.playerPlayStateChanged = { [weak self] player, status in
            guard let `self` = self else { return }
            self.playerDelegate?.playerPlayStateChanged?(player: player)
        }
    }
}

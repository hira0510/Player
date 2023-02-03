//
//  BasePlayerViewController.swift
//  avnight
//
//  Copyright © 2021 com. All rights reserved.
//

import UIKit

/// 可選方法
@objc protocol BasePlayerViewControllerProtocol: AnyObject {
    /// player準備播放
    @objc optional func playerReadyToPlay(player: ZFPlayerMediaPlayback, assets: URL)
    /// player橫式直式已改變
    @objc optional func orientationDidChanged(player: ZFPlayerController, isFull: Bool)
    /// player橫式直式將改變
    @objc optional func orientationWillChange(player: ZFPlayerController, isFull: Bool)
    /// player時間改變
    @objc optional func playerPlayTimeChanged(player: ZFPlayerMediaPlayback, currentTime: TimeInterval, totalTime: TimeInterval)
    /// player拖拉時間
    @objc optional func playerDraggedTimeChanged(draggedTime: TimeInterval)
    /// player拖拉時間停止
    @objc optional func playerDraggedTimeChangedStop()
    /// player播放狀態改變
    @objc optional func playerPlayStateChanged(player: ZFPlayerMediaPlayback)
    ///
    @objc optional func willResignActive(notification: ZFPlayerNotification)
    /// 點擊左上角返回
    @objc optional func backBtnClickCallback()
    /// 點擊回直式
    @objc optional func exitFullScreenBtnClickCallback()
    /// 點擊全螢幕
    @objc optional func fullScreenBtnClickCallback()
}

class BasePlayerViewController: BaseUIViewController {

    /// 播放器的UI控制層
    internal lazy var zfControlView: ZFPlayerControlView = ZFPlayerControlView()
    /// 播放器的VC
    internal lazy var zfPlayer: ZFPlayerController = ZFPlayerController()
    /// 播放器的核心（播放開始、暫停等等邏輯層）
    internal lazy var zfPlayerManager: ZFAVPlayerManager = ZFAVPlayerManager()
//    /// 直播播放器的核心（播放開始、暫停等等邏輯層）
    internal lazy var livePlayerManager: ZFIJKPlayerManager = ZFIJKPlayerManager()
    /// 當前影片畫質（預設標清）
    internal lazy var currentVideoQuality: String = "SD标清"
    /// 影片畫質的序列
    internal lazy var videoQualitySequence: [String] = []
    /// 播放器的delegate
    internal weak var playerDelegate: BasePlayerViewControllerProtocol?
    internal let basePlayerViewModel = BasePlayerViewModel()

    // 播放器返回按鈕
    internal lazy var backParentVCBtn: UIButton = {
        let width = GlobalUtil.calculateWidthScaleWithSize(width: 70)
        let height = GlobalUtil.calculateHeightScaleWithSize(width: 70, height: 70)
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        btn.addTarget(self, action: #selector(previousBack), for: .touchUpInside)
        return btn
    }()

    // 播放器返回圖片
    internal lazy var backParentVCImage: UIImageView = {
        let width = GlobalUtil.calculateWidthScaleWithSize(width: 10)
        let height = GlobalUtil.calculateHeightScaleWithSize(width: 10, height: 20)
        let imageView = UIImageView(frame: CGRect(x: 20, y: 28, width: width, height: height))
        imageView.image = UIImage(named: "basic_icon_arrow_left_white")
        return imageView
    }()

    /// 全屏切換畫質按鈕
    internal lazy var fullPlayerSelectQualityButton: UIButton = {
        let width: CGFloat = 45
        let height: CGFloat = 25
        let rightConstraint: CGFloat = UIDevice.current.isiPhoneXDevice() ? 47 : 13
        let topConstraint: CGFloat = 13
        let button = UIButton(frame: CGRect(x: self.screenHeight - width - rightConstraint, y: topConstraint, width: width, height: height))
        button.backgroundColor = .clear
        currentVideoQuality.contains("标清") ? button.setTitle("标清", for: .normal) : button.setTitle("高清", for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangTC", size: 16)
        return button
    }()

    /// 全屏切換倍速按鈕
    internal lazy var fullPlayerSelectRateButton: UIButton = {
        let width: CGFloat = 55
        let height: CGFloat = 25
        let rightConstraint: CGFloat = UIDevice.current.isiPhoneXDevice() ? 47 : 13
        let topConstraint: CGFloat = 13
        let button = UIButton(frame: CGRect(x: self.screenHeight - (2 * width) - rightConstraint - 15, y: topConstraint, width: width, height: height))
        button.backgroundColor = .clear
        button.setTitle("倍速", for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangTC", size: 16)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - func

    /// 配置一般播放器
    ///
    /// - Parameter contentView: 播放器放置的地方
    internal func setupPlayerWithContentView(contentView: UIView, playerUIHiddenTime: TimeInterval) {
        var authorization = [String: Any]()
        authorization["Authorization"] = "AVNightInfo.apiToken"
        zfPlayerManager.requestHeader = authorization

        self.zfPlayer = ZFPlayerController(playerManager: self.zfPlayerManager, containerView: contentView)
        self.zfControlView.autoHiddenTimeInterval = playerUIHiddenTime
        self.zfControlView.portraitControlView.topToolView.addSubview(backParentVCImage)
        self.zfControlView.portraitControlView.topToolView.addSubview(backParentVCBtn)
        self.zfControlView.landScapeControlView.topToolView.addSubview(fullPlayerSelectQualityButton)
        self.zfControlView.landScapeControlView.topToolView.addSubview(fullPlayerSelectRateButton)
        self.zfControlView.landScapeControlView.backTo10Btn.addTarget(self, action: #selector(didClickBackTo10BtnBtn), for: .touchUpInside)
        self.zfControlView.landScapeControlView.nextTo10Btn.addTarget(self, action: #selector(didClickNextTo10BtnBtn), for: .touchUpInside)
        self.zfPlayer.controlView = self.zfControlView
    }

    /// 配置專題播放器
    ///
    /// - Parameter contentView: 播放器放置的地方
    internal func setupTopicPlayerWithContentView(contentView: UIView, playerUIHiddenTime: TimeInterval) {
        var authorization = [String: Any]()
        authorization["Authorization"] = "AVNightInfo.apiToken"
        zfPlayerManager.requestHeader = authorization

        self.zfPlayer = ZFPlayerController(playerManager: self.zfPlayerManager, containerView: contentView)
        self.zfControlView.autoHiddenTimeInterval = playerUIHiddenTime
        self.zfControlView.portraitControlView.topToolView.addSubview(backParentVCImage)
        self.zfControlView.portraitControlView.topToolView.addSubview(backParentVCBtn)
        self.zfPlayer.controlView = self.zfControlView
    }

    /// 配置直播播放器
    ///
    /// - Parameter contentView: 播放器放置的地方
    internal func setupLivePlayerWithContentView(contentView: UIView, playerUIHiddenTime: TimeInterval, isUrlM3u8: Bool = false) {
//        self.livePlayerManager.options.setFormatOptionValue("AVNight_iOS_test", forKey: "user-agent")
        if isUrlM3u8 {
            var authorization = [String: Any]()
            authorization["Authorization"] = "AVNightInfo.apiToken"
            zfPlayerManager.requestHeader = authorization

            self.zfPlayer = ZFPlayerController(playerManager: self.zfPlayerManager, containerView: contentView)
        } else {
            self.livePlayerManager.options.setFormatOptionValue("AVNightInfo.apiToken", forKey: "Authorization")
            self.zfPlayer = ZFPlayerController(playerManager: self.livePlayerManager, containerView: contentView)
        }
        self.zfControlView.autoHiddenTimeInterval = playerUIHiddenTime
        self.zfControlView.portraitControlView.topToolView.addSubview(backParentVCImage)
        self.zfControlView.portraitControlView.topToolView.addSubview(backParentVCBtn)
        
        self.zfControlView.portraitControlView.topToolView.isHidden = true
        self.zfControlView.portraitControlView.bottomToolView.isHidden = true
        self.zfControlView.portraitControlView.playOrPauseBtn.isHidden = true
        self.zfControlView.landScapeControlView.bottomToolView.isHidden = true
        self.zfControlView.landScapeControlView.playOrPauseBtn.isHidden = true
        self.zfControlView.failBtn.isHidden = true
        self.zfControlView.bottomPgrogress.sliderHeight = 0
        
        self.zfPlayer.gestureControl.disableTypes = .init(arrayLiteral: .doubleTap, .pinch, .pan)
        self.zfPlayer.controlView = self.zfControlView
    }
    
    /// 配置直播TableView播放器
    ///
    /// - Parameter contentView: 播放器放置的地方
    internal func setupLivePlayerWithTableView(tableView: UITableView, tag: Int, playerUIHiddenTime: TimeInterval) {
        self.livePlayerManager.options.setFormatOptionValue("AVNightInfo.apiToken", forKey: "Authorization")
        self.zfPlayer = ZFPlayerController.init(scrollView: tableView, playerManager: livePlayerManager, containerViewTag: tag)
        self.zfControlView.autoHiddenTimeInterval = playerUIHiddenTime
        self.zfControlView.portraitControlView.topToolView.addSubview(backParentVCImage)
        self.zfControlView.portraitControlView.topToolView.addSubview(backParentVCBtn)
        
        self.zfControlView.portraitControlView.topToolView.isHidden = true
        self.zfControlView.portraitControlView.bottomToolView.isHidden = true
        self.zfControlView.portraitControlView.playOrPauseBtn.isHidden = true
        self.zfControlView.landScapeControlView.bottomToolView.isHidden = true
        self.zfControlView.landScapeControlView.playOrPauseBtn.isHidden = true
        self.zfControlView.failBtn.isHidden = true
        self.zfControlView.bottomPgrogress.sliderHeight = 0
        
        self.zfPlayer.gestureControl.disableTypes = .init(arrayLiteral: .doubleTap, .pinch, .pan)
        self.zfPlayer.controlView = self.zfControlView
    }
    
    /// 配置一般播放器
     func setupPlayerWithContentViews(contentView: UIView) {
        var authorization = [String: Any]()
        authorization["Authorization"] = DomainConfig.apiToken
        zfPlayerManager.requestHeader = authorization
         self.zfPlayer = ZFPlayerController(playerManager: self.zfPlayerManager, containerView: contentView)
        self.zfPlayer.shouldAutoPlay = true
        self.zfControlView.prepareShowLoading = true
        self.zfControlView.portraitControlView.topToolView.isHidden = true
        self.zfControlView.portraitControlView.bottomToolView.isHidden = true
        self.zfControlView.portraitControlView.playOrPauseBtn.isHidden = true
        self.zfControlView.landScapeControlView.bottomToolView.isHidden = true
        self.zfControlView.landScapeControlView.playOrPauseBtn.isHidden = true
        self.zfControlView.failBtn.isHidden = true
        self.zfControlView.bottomPgrogress.sliderHeight = 0
        self.zfPlayer.gestureControl.disableTypes = .init(arrayLiteral: .doubleTap, .pinch, .pan)
        self.zfPlayer.controlView = self.zfControlView
    }

    /// 播放器Handler
    internal func setPlayerHandler() {
        zfPlayer.playerReadyToPlay = { [weak self] player, assets in
            guard let `self` = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { //不知道為啥不能直接改rate所以設在1秒後
                self.zfPlayerManager.rate = self.basePlayerViewModel.rateChooseFloat
            }
            
            self.playerDelegate?.playerReadyToPlay?(player: player, assets: assets)
        }

        zfPlayer.orientationDidChanged = { [weak self] player, isFull in
            guard let `self` = self else { return }
            self.playerDelegate?.orientationDidChanged?(player: player, isFull: isFull)
        }

        zfPlayer.orientationWillChange = { [weak self] player, isFull in
            guard let `self` = self else { return }
            self.playerDelegate?.orientationWillChange?(player: player, isFull: isFull)
        }

        zfPlayer.playerPlayTimeChanged = { [weak self] player, currentTime, totalTime in
            guard let `self` = self else { return }
            self.playerDelegate?.playerPlayTimeChanged?(player: player, currentTime: currentTime, totalTime: totalTime)
        }

        zfPlayer.playerPlayStateChanged = { [weak self] player, status in
            guard let `self` = self else { return }
            self.playerDelegate?.playerPlayStateChanged?(player: player)
        }

        zfPlayer.notification.willResignActive = { [weak self] notification in
            guard let `self` = self else { return }
            self.playerDelegate?.willResignActive?(notification: notification)
        }

        zfControlView.backBtnClickCallback = { [weak self] in
            guard let `self` = self else { return }
            self.playerDelegate?.backBtnClickCallback?()
        }

        zfControlView.exitFullScreenBtnClickCallback = { [weak self] in
            guard let `self` = self else { return }
            self.playerDelegate?.exitFullScreenBtnClickCallback?()
        }

        zfControlView.fullScreenBtnClickCallback = { [weak self] in
            guard let `self` = self else { return }
            self.playerDelegate?.fullScreenBtnClickCallback?()
        }
        
        zfControlView.playerDraggedTimeChanged = { [weak self] draggedTime in
            guard let `self` = self else { return }
            self.playerDelegate?.playerDraggedTimeChanged?(draggedTime: draggedTime)
        }
        
        zfControlView.playerDraggedTimeChangedStop = { [weak self] in
            guard let `self` = self else { return }
            self.playerDelegate?.playerDraggedTimeChangedStop?()
        }
    }
    
    //MARK: - @objc

    /// 點擊快進Btn
    @objc func didClickNextTo10BtnBtn() {
        //目前找不到方法能寫在外面，故寫在內部，並參考點擊兩下快進快退的方法
        self.zfControlView.didClickNext10Btn()
    }

    /// 點擊快退Btn
    @objc func didClickBackTo10BtnBtn() {
        self.zfControlView.didClickBack10Btn()
    }
}

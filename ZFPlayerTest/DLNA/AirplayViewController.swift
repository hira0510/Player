//
//  AirplayViewController.swift
//  ZFPlayerTest
//
//  Created by Hira on 2022/11/28.
//

import UIKit
import ConnectSDK

class AirplayViewController: BasePlayerViewController {


    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playVideoBtn: UIButton!

    /// 影片ID
    public var mVideoId = "test11"
//    /// 影片UrlStr
//    public var mVideoUrlStr240 = "https://apiw.huabai-liquor.com/v3/FGAN-014/cloudfront/240.m3u8?k=da274a40e603c04414a80aca164c25b0&t=1670220546&token=bearer%20eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJtZW1iZXJfaWQiOjIxNTc5Mjk1LCJwbGF0Zm9ybSI6ImlvcyIsImFjY291bnQiOiJhYUBhYS5hYSIsInZpZGVvX2lkIjoiRkdBTi0wMTQiLCJpcCI6IjYxLjIyMS4xNTUuMTAxIn0.pvRv5R80SJwkDCB8H3qLOYvqEg68zr9Ttruh-_Cl3bQ"
//    /// 影片UrlStr
//    public var mVideoUrlStr480 = "https://apiw.huabai-liquor.com/v3/FGAN-014/cloudfront/480.m3u8?k=dcf1396118e62f172f741b72f6b7eb2a&t=1670220546&token=bearer%20eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJtZW1iZXJfaWQiOjIxNTc5Mjk1LCJwbGF0Zm9ybSI6ImlvcyIsImFjY291bnQiOiJhYUBhYS5hYSIsInZpZGVvX2lkIjoiRkdBTi0wMTQiLCJpcCI6IjYxLjIyMS4xNTUuMTAxIn0.pvRv5R80SJwkDCB8H3qLOYvqEg68zr9Ttruh-_Cl3bQ"
//    //有加密的公司影片1hr
    public var mVideoUrlStr240 = "https://dekm6v70x775h.cloudfront.net/RCTD-500/240/RCTD-500.m3u8?md5=tXdO3oYSPs_wMrrtzNYSNA&expires=1673524515"
    //一般測試影片
//    public var mVideoUrlStr240 = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
    //有加密的公司影片
    public var mVideoUrlStr480 = "https://d2qf7yjeohvf2o.cloudfront.net/RSWAG/RSWAG-2919/h264/RSWAG-2919-480.m3u8"
    /// 影片名稱
    public var mVideoTitle = "思わず勃起してしまう もろパン美少女 りか 美甘りか"
    /// 影片封面
    public var mVideoImage = "https://lcl.njfushun.com/data/adult-videos/FGAN-014/cover/dc008240-b098-44b9-abf6-3d37da6da4c8"

    private let viewModel = BasePlayerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let aa = UserDefaults.standard.string(forKey: "haha") {
            playVideoBtn.setTitle(aa, for: .normal)
        }
        setupPlayerWithContentView(contentView: playerView, playerUIHiddenTime: 10)
        setupPlayerAssetsWithPlayerUI()
        playerDelegate = self
        setPlayerHandler()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        zfPlayer.isViewControllerDisappear = true
        zfPlayer.stop()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tabBarController?.tabBar.isHidden = true
    }

    // MARK: - 私有

    /// 設定Player
    private func setupPlayerAssetsWithPlayerUI() {

//        let path = Bundle.main.path(forResource: "test", ofType: "mp4")!
//        zfPlayer.assetURLs = [URL(fileURLWithPath: path)]
        zfPlayerManager.seekTime = viewModel.mTemporaryPlayerTime
        zfPlayer.assetURLs = [URL(string: mVideoUrlStr240)!, URL(string: mVideoUrlStr480)!]

        playVideoBtn.addTarget(self, action: #selector(didClickVideoPlayBtn), for: .touchUpInside)
    }

    /// 點擊播放按鈕後的設定
    private func didPlayVideoPlayer() {
        zfPlayerManager.seekTime = viewModel.mTemporaryPlayerTime
        unwrap(self.zfPlayer.assetURLs?.count, 0) > 1 ? (zfPlayer.playTheIndex(1)) : (zfPlayer.playTheIndex(0))
    }

    /// 點擊播放按鈕
    @objc private func didClickVideoPlayBtn() {
        didPlayVideoPlayer()
    }
    
    @IBAction func didClickBtn(_ sender: Any) {
        let videoModel = PlayerDLNAModel(videoId: mVideoId, urlAry: [URL(string: mVideoUrlStr240)!, URL(string: mVideoUrlStr480)!], title: mVideoTitle, img: mVideoImage)
        let vc = UIStoryboard.loadAirplayControlVC(model: videoModel)
        self.present(vc, animated: true)
    }
}

// MARK: - BasePlayerViewControllerProtocol - 播放器delegate
extension AirplayViewController: BasePlayerViewControllerProtocol {

    func playerReadyToPlay(player: ZFPlayerMediaPlayback, assets: URL) {
        zfControlView.portraitControlView.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + self.viewModel.mPlayerControllerViewHiddenTime, execute: {
            self.zfControlView.portraitControlView.hide()
        })
    }
    
    func playerPlayTimeChanged(player: ZFPlayerMediaPlayback, currentTime: TimeInterval, totalTime: TimeInterval) {
        viewModel.mTemporaryPlayerTime = currentTime
    }

    func willResignActive(notification: ZFPlayerNotification) {
        zfPlayer.stop()
    }

    func orientationDidChanged(player: ZFPlayerController, isFull: Bool) { }
    func orientationWillChange(player: ZFPlayerController, isFull: Bool) { }
    func playerDraggedTimeChanged(draggedTime: TimeInterval) { }
    func playerDraggedTimeChangedStop() { }
}

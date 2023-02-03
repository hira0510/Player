//
//  ViewController.swift
//  ZFPlayerTest
//
//  Created by Hira on 2022/8/2.
//

/********************影片預覽功能**********************/

import UIKit
import Kingfisher
import KingfisherWebP
import AVFoundation

enum VideoQuality {
    case lowQuality
    case highQuality
}

class PreviewViewController: BasePlayerViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var testImgView: UIImageView!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var playVideoBtn: UIButton!

    /// 影片ID
    public var mVideoId = ""
    /// 影片名稱
    public var mVideoTitle = ""
    /// 影片封面
    public var mVideoImage = ""
    /// 返回是否用dismiss
    public var mBackDismiss: Bool = false

    private let viewModel = BasePlayerViewModel()
    
//    var generator: ACThumbnailGenerator!
    
    var testImageAry: [UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
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

        zfPlayerManager.seekTime = viewModel.mTemporaryPlayerTime
        let path = Bundle.main.path(forResource: "test", ofType:"mp4")!
        zfPlayer.assetURLs = [URL(fileURLWithPath: path)]
        
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
}

// MARK: - BasePlayerViewControllerProtocol - 播放器delegate
extension PreviewViewController: BasePlayerViewControllerProtocol {

    func playerReadyToPlay(player: ZFPlayerMediaPlayback, assets: URL) {
        zfControlView.portraitControlView.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + self.viewModel.mPlayerControllerViewHiddenTime, execute: {
                self.zfControlView.portraitControlView.hide()
        })
        setImg()
        
        
        /* 🟠嘗試直接從影片拿截圖，結論是圖片拿的太慢了，不採用，直接像YT一樣跟後端拿集大成的圖片去裁切比較快
//        generator = ACThumbnailGenerator(url: assets, vc: self)
//        guard let url = URL(string: "https://cel.xewall.com/584AD-091/240/ts/584AD-091-35.ts?k=d4712ac3bb25c846d311b06689f0a82b&t=1658997983") else { return }
//        generator = ACThumbnailGenerator(url: url, vc: self)
//        generateThumbnail(path: assets, time: Int64(zfPlayer.totalTime))
//        self.mView.testImgView.loadBase64Image(url: "https://appdev.icu/av9/group.webp", placeholder: nil, options: [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]) { image, error, imageURL in
//            print("ok")
//        }
         */
    }

    func orientationDidChanged(player: ZFPlayerController, isFull: Bool) {
        
    }

    func orientationWillChange(player: ZFPlayerController, isFull: Bool) {
        
    }

    func playerPlayTimeChanged(player: ZFPlayerMediaPlayback, currentTime: TimeInterval, totalTime: TimeInterval) {
        viewModel.mTemporaryPlayerTime = currentTime
    }
    
    func playerDraggedTimeChanged(draggedTime: TimeInterval) {
        
        let imgIndex = Int(draggedTime) / 10
        guard testImageAry.count > imgIndex else { return }
        self.testView.isHidden = false
        self.testImgView.image = testImageAry[imgIndex]
        
        let scale = draggedTime / zfPlayer.totalTime
        let startW = self.testView.frame.width + 20
        let allW = screenWidth - startW
        let scaleW = allW * scale
        UIView.animate(withDuration: 0.1) {
            self.testView.frame.origin.x = 10 + scaleW
        }
    }
    
    func playerDraggedTimeChangedStop() {
        self.testView.isHidden = true
    }
    
    // 設定截圖圖片
    func setImg() {
        let videoTime = Int(zfPlayer.totalTime)
        let allImgCount = videoTime / 10
        for i in 0...allImgCount/100 {
            
            /* 如果是網路上的webp就用這個方法
            UIImageView().loadBase64Image(url: "https://appdev.icu/av9/M\(i)c1.webp", options: .cacheSerializer(WebPSerializer.default)])
            */
            
            
            /* 如果是本地的webp就用這個方法
            let path = Bundle.main.path(forResource: "M\(i)", ofType:"webp")!
            if let img = UIImage(contentsOfFile: path) {}
             */
            print("videoTime:\(videoTime), i:\(i)")
            let imgUrl =  "https://i.ytimg.com/sb/1kPyIooxIGE/storyboard3_L1/M\(i).jpg?sqp=-oaymwENSDfyq4qpAwVwAcABBqLzl_8DBgjz8I-XBg==&sigh=rs%24AOn4CLCvHLTcMQCF_896XKEMEfRQVnw9rA"
            UIImageView().loadBase64Image(url: imgUrl, options: nil) { [weak self] image, error, imageURL in
                guard let `self` = self else { return }
                if let image = image {
                    let imgCount = (i+1) * 100 > allImgCount ? allImgCount % 100: 100
                    let imgWidthCount = imgCount > 9 ? 10 : imgCount
                    let imgHeightCount = imgCount > 90 ? 10 : imgCount / 10 + (imgCount % 10 > 0 ? 1: 0)
                    let aImgWidth = image.size.width / CGFloat(imgWidthCount)
                    let aImgHeight = image.size.height / CGFloat(imgHeightCount)
                    for j in 0..<imgCount {
                        let x: CGFloat = 0 + aImgWidth * CGFloat(j%10)
                        let y: CGFloat = 0 + aImgHeight * CGFloat(j/10)
                        let frame = CGRect(x: x, y: y, width: aImgWidth, height: aImgHeight)
                        print("index:\(j), frame:\(frame)\n")
                        self.testImageAry.append(self.crop(image: image, frame: frame))
                    }
                }
            }
        }
    }
    
    //将图片裁剪成指定比例（多余部分自动删除）
    //图片绘制区域 frame
    func crop(image: UIImage, frame: CGRect) -> UIImage {
        guard let imageRef = image.cgImage?.cropping(to: frame) else { return UIImage() }
        return UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    }
    
    func willResignActive(notification: ZFPlayerNotification) {
        zfPlayer.stop()
    }
}

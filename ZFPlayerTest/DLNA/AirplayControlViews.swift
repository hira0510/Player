//
//  AirplayControlViews.swift
//  ZFPlayerTest
//
//  Created by  on 2022/12/6.
//

import UIKit
import Lottie

class AirplayControlViews: NSObject {

    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var waitImageView: UIImageView!
    @IBOutlet weak var notFindDeviceView: UIView!
    @IBOutlet weak var changeHlsButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var videoPlayTimeLabel: UILabel!
    @IBOutlet weak var videoTotalTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playTimeSlider: UISlider!
    @IBOutlet weak var prev30Button: UIButton!
    @IBOutlet weak var next30Button: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mScrollViewIndicatorBg: UIView!
    let animationView = AnimationView(name: "DLNAWait")
    lazy var mScrollViewIndicator: UIView! = {
        let view = UIView(frame: mScrollViewIndicatorBg.frame)
        view.frame.origin.x = 0
        view.frame.origin.y = 0
        view.backgroundColor = UIColor(0xcaac67)
        view.cornerRadius = 3
        view.isHidden = true
        return view
    }()

    /// 添加滑動桿
    func addScrollViewIndicator() {
        mScrollViewIndicatorBg.addSubview(mScrollViewIndicator)
    }

    /// 設定slider的滑桿大小
    func setSliderSize() {
        let size = GlobalUtil.calculateWidthScaleWithSize(width: 15)
        volumeSlider.setSliderThumbTintColor(size: CGSize(width: size, height: size), color: .white)
        playTimeSlider.setSliderThumbTintColor(size: CGSize(width: size, height: size), color: UIColor(0xd9c082))
    }

    /// 添加搜尋中lottie
    func addAnimationView() {
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.frame = CGRect(x: 0, y: 0, width: waitImageView.frame.width, height: waitImageView.frame.height)
        waitImageView.addSubview(animationView)
    }

    /// 更變時間UI
    func changePostionTimeUI(text: String, slider: Float) {
        videoPlayTimeLabel.text = text
        playTimeSlider.value = slider
    }

    /// 搜尋中與否UI調整
    func searchDevice(searching: Bool) {
        waitImageView.isHidden = !searching
        reloadButton.isHidden = searching
    }

    /// 找到裝置與否UI調整
    func findDevice(isFind: Bool) {
        mTableView.isHidden = !isFind
        notFindDeviceView.isHidden = isFind
    }

    /// 設定高標清按鈕
    func setupHlsBtn(urls: [URL]?) {
        if unwrap(urls?.count, 0) > 1 {
            changeHlsButton.isUserInteractionEnabled = true
        } else {
            changeHlsButton.isUserInteractionEnabled = false
        }
    }
}

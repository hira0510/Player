//
//  AirplayControlViewController.swift
//  ZFPlayerTest
//
//  Created by  on 2022/12/5.
//

import UIKit
import ConnectSDK
import RxCocoa
import RxSwift

typealias PlayerDLNAModel = (videoId: String, urlAry: [URL], title: String, img: String)

class AirplayControlViewController: BasePlayerViewController {
    
    @IBOutlet var views: AirplayControlViews!
    
    /// 影片
    public var videoModel: PlayerDLNAModel?
    
    private let viewModel: AirplayControlViewModel = AirplayControlViewModel()
    private let DLNAManager: DLNAConnectManager = DLNAConnectManager.share
    /// 關閉VC的回調
    public var closeVcCallBack: (() -> Void)? = { }

    override func viewDidLoad() {
        setupUI()
        bindUI()
        startSearchDevice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localNetworkAuthorization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        self.DLNAManager.disconnectDevice()
        self.closeVcCallBack?()
    }
    
    /// iOS14以上要請求權限才能使用偵測設備, 14以下不用但會有點秀逗, 可能無法解決
    func localNetworkAuthorization() {
        if #available(iOS 14.0, *) {
            LocalNetworkAuthorization().requestAuthorization { [weak self] isAgree in
                guard let `self` = self else { return }
                DispatchQueue.main.async(execute: { () -> Void in
                    if !isAgree {
                        let alert = self.openAuthorizedPop(title: "無法使用投屏功能", msg: "请允许连接区域网络\n才能链接投屏设备", btn1: "取消", btn2: "前往") { [weak self] _ in
                            guard let `self` = self else { return }
                            self.dismissBtn()
                        }
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    /// UI設定
    private func setupUI() {
        let hintTouch = UITapGestureRecognizer(target: self, action: #selector(openHintBtn))
        views.hintView.addGestureRecognizer(hintTouch)
        views.removeButton.addTarget(self, action: #selector(dismissBtn), for: .touchUpInside)
        views.hintButton.addTarget(self, action: #selector(openHintBtn), for: .touchUpInside)
        views.reloadButton.addTarget(self, action: #selector(startSearchDevice), for: .touchUpInside)
        views.prev30Button.addTarget(self, action: #selector(prev30Btn), for: .touchUpInside)
        views.next30Button.addTarget(self, action: #selector(next30tn), for: .touchUpInside)
        views.playButton.addTarget(self, action: #selector(playBtn), for: .touchUpInside)
        views.changeHlsButton.addTarget(self, action: #selector(changeHlsBtn), for: .touchUpInside)
        views.muteButton.addTarget(self, action: #selector(muteBtn), for: .touchUpInside)
        views.playTimeSlider.addTarget(self, action: #selector(playProgressEdit(_:for:)), for: .valueChanged)
        views.volumeSlider.addTarget(self, action: #selector(volumeProgressEdit(_:for:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        views.setSliderSize()
        views.addScrollViewIndicator()
        views.addAnimationView()
        views.setupHlsBtn(urls: videoModel?.urlAry)
        
        views.mTableView.delegate = self
        views.mTableView.dataSource = self
        views.mTableView.register(AirplayDeviceTableViewCell.nib, forCellReuseIdentifier: "AirplayDeviceTableViewCell")
    }
    
    /// UI綁定
    private func bindUI() {
        // 音量
        DLNAManager.getVolume().subscribe(onNext: { [weak self] (value) in
            guard let `self` = self else { return }
            DispatchQueue.main.async() {
                self.DLNAManager.debugMsg(.device(.volume), setSuc: true, start: false)
                self.views.volumeSlider.value = value
            }
        }).disposed(by: bag)
        
        // 靜音
        DLNAManager.getVolumeIsMute().subscribe(onNext: { [weak self] (mute) in
            guard let `self` = self else { return }
            DispatchQueue.main.async() {
                self.DLNAManager.debugMsg(.device(.mute), setSuc: true, start: false, value: mute)
                let volume = mute ? 0 : self.DLNAManager.getVolume().value
                self.views.muteButton.isSelected = !mute
                self.views.volumeSlider.value = volume
            }
        }).disposed(by: bag)
        
        // 影片總時間
        DLNAManager.getTotalTime().subscribe(onNext: { [weak self] (timeDouble) in
            guard let `self` = self else { return }
            DispatchQueue.main.async() {
                self.DLNAManager.debugMsg(.video(.duration), setSuc: true, start: false, value: timeDouble)
                self.views.videoTotalTimeLabel.text = self.viewModel.setPlayerTime(timeDouble)
            }
        }).disposed(by: bag)
        
        // 影片播放進度
        DLNAManager.getPositionTime().subscribe(onNext: { [weak self] positionT in
            guard let `self` = self else { return }
            DispatchQueue.main.async() {
                self.DLNAManager.debugMsg(.video(.position), setSuc: true, start: false, value: positionT)
                let totalTime = self.DLNAManager.getTotalTime().value
                let changeHlsTime = self.DLNAManager.getChangeHlsSeekTime()
                let isPlay = totalTime > 10 && positionT > 1
                let positionTime = positionT >= totalTime ? totalTime: positionT
                let isChangedStatus = self.DLNAManager.getDeviceDatas().value.filter { $0.status == .Success }
                
                //更換畫質跳轉
                if isPlay, changeHlsTime > 0 {
                    let seekTime = changeHlsTime > totalTime ? totalTime: changeHlsTime
                    self.DLNAManager.timerStop(play: true, media: true)
                    self.DLNAManager.seekTo(seekTime)
                    self.DLNAManager.debugMsg(.video(.changeHls), start: true, value: seekTime)
                } else if isPlay { //設定播放時間UI
                    self.views.changePostionTimeUI(text: self.viewModel.setPlayerTime(positionTime), slider: Float(positionTime / totalTime))
                }
                
                //偵測已經開始播放
                if let device = self.DLNAManager.getDevice(), isPlay, isChangedStatus.count == 0 {
                    self.DLNAManager.changeConnectStatus(device, .Success)
                    self.enableMediaControlComponents()
//                    FlurryManager.sendEvents(EventsName: "投屏功能", Events: ["功能點擊": "投屏成功"])
                }
            }
        }).disposed(by: bag)
        
        // 裝置狀態改變
        DLNAManager.getDeviceDatas().subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            DispatchQueue.main.async() {
                self.views.mTableView.reloadData()
                self.DLNAManager.debugMsg(.device(.changeStatus), setSuc: true, start: false, value: "Reload")
            }
        }).disposed(by: bag)
        
        // 是否播放標清
        DLNAManager.getIsPlayUrl240().subscribe(onNext: { [weak self] (urlIs240) in
            guard let `self` = self, let is240 = urlIs240 else { return }
            DispatchQueue.main.async() {
                self.DLNAManager.debugMsg(.video(.hls), setSuc: true, value: is240 ? "標清": "高清")
                self.views.changeHlsButton.isSelected = !is240
            }
        }).disposed(by: bag)
        
        // 是否以連接到裝置準備播放
        DLNAManager.getIsStartPlay().subscribe(onNext: { [weak self] result in
            guard let `self` = self, result else { return }
            DispatchQueue.main.async() {
                self.DLNAManager.getPlayState()
            }
        }).disposed(by: bag)
        
        // 是否播放狀態
        DLNAManager.getPlayStatus().subscribe(onNext: { [weak self] playStatus in
            guard let `self` = self else { return }
            DispatchQueue.main.async() {
                switch playStatus {
                case .Play:
                    self.views.playButton.isSelected = false
                case .NotPlay, .End, .Other:
                    self.views.playButton.isSelected = true
                }
            }
        }).disposed(by: bag)
    }
    
    /// 支援功能設定UI
    private func enableMediaControlComponents() {
        self.views.playButton.isUserInteractionEnabled = true
        self.views.prev30Button.isUserInteractionEnabled = true
        self.views.next30Button.isUserInteractionEnabled = true
        self.views.playTimeSlider.isUserInteractionEnabled = true
        self.views.volumeSlider.isUserInteractionEnabled = true
    }
    
    /// 從背景回來animationView會暫停
    @objc func willEnterForeground() {
        views.animationView.play()
        localNetworkAuthorization()
    }
    
    /// 點擊關閉按鈕
    @objc private func dismissBtn() {
        self.DLNAManager.debugMsg(.UI(.close))
        self.navigationController?.popViewController(animated: true)
    }
    
    /// 點擊提示
    @objc private func openHintBtn() {
        views.hintView.isHidden = !views.hintView.isHidden
    }
    
    /// 開始搜尋裝置
    @objc private func startSearchDevice() {
        self.DLNAManager.closeDiscovery()
        self.DLNAManager.startDiscoveryTV(vc: self)
        self.views.searchDevice(searching: true)
        self.views.findDevice(isFind: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            guard let `self` = self else { return }
            if let _ = self.DLNAManager.getDiscoveryManager() {
                self.DLNAManager.closeDiscovery()
            }
            let isFindDevice = self.DLNAManager.getDeviceDatas().value.count > 0
            self.views.findDevice(isFind: isFindDevice)
            self.views.searchDevice(searching: false)
            self.DLNAManager.debugMsg(.discovery(.search), start: false, value: "超過60s關閉")
        }
    }
    
    /// 點擊畫質
    @objc private func changeHlsBtn(sender: UIButton) {
        let is240 = !sender.isSelected
        guard let device = DLNAManager.getDevice(), let model = videoModel else { return }
        self.DLNAManager.debugMsg(.UI(.hls), value: "是240:\(!is240)")
        self.DLNAManager.devicePlayVideo(device: device, is240: !is240, video: model, changeHls: true)
    }
    
    /// 點擊倒退30秒
    @objc private func prev30Btn() {
        guard self.DLNAManager.getPlayStatus().value != .End else { return }
        let positionTime = DLNAManager.getPositionTempTime().value
        let seekToTime = positionTime >= 30 ? (positionTime - 30): 0
        self.DLNAManager.debugMsg(.UI(.position), value: "快退至: \(seekToTime)")
        self.DLNAManager.timerStop(play: true, media: true)
        self.DLNAManager.setPositionTime(position: seekToTime, temp: seekToTime)
        self.perform(#selector(nextAndPrevToSec), with: nil, afterDelay: 1.5)
        AirplayControlViewController.cancelPreviousPerformRequests(withTarget: nextAndPrevToSec)
    }
    
    /// 點擊快進30秒
    @objc private func next30tn() {
        guard self.DLNAManager.getPlayStatus().value != .End else { return }
        let positionTime = DLNAManager.getPositionTempTime().value
        let totalTime = DLNAManager.getTotalTime().value
        let seekToTime = positionTime < (totalTime - 30) ? (positionTime + 30): totalTime
        self.DLNAManager.debugMsg(.UI(.position), value: "快進至: \(seekToTime)")
        self.DLNAManager.timerStop(play: true, media: true)
        self.DLNAManager.setPositionTime(position: seekToTime, temp: seekToTime)
        self.perform(#selector(nextAndPrevToSec), with: nil, afterDelay: 1.5)
        AirplayControlViewController.cancelPreviousPerformRequests(withTarget: nextAndPrevToSec)
    }
    
    /// 快進快退調整進度
    @objc private func nextAndPrevToSec() {
        guard let _ = DLNAManager.getMediaControl() else { return }
        self.DLNAManager.seekTo(DLNAManager.getPositionTempTime().value)
    }
    
    /// 進度滑動
    @objc private func playProgressEdit(_ slider: UISlider?, for event: UIEvent?) {
        guard let _ = self.DLNAManager.getMediaControl() else { return }
        let totalTime: TimeInterval = DLNAManager.getTotalTime().value
        guard totalTime > 0 else { return }
        let position = totalTime * Double(slider?.value ?? 0)
        
        let touchEvent = event?.allTouches?.first
        switch touchEvent?.phase {
        case .began:
            self.DLNAManager.debugMsg(.UI(.position), value: "开始拖动")
            self.DLNAManager.timerStop(play: true, media: true)
        case .moved:
//            self.DLNAManager.debugMsg(.UI(.position), value: "正在拖动：\(self.viewModel.setPlayerTime(position))")
            self.views.videoPlayTimeLabel.text = self.viewModel.setPlayerTime(position)
            self.DLNAManager.timerStop(play: true, media: true)
        case .ended:
            let seekPosition = position == totalTime ? totalTime - 1: position
            self.DLNAManager.seekTo(seekPosition)
        default:
            break
        }
    }
    
    /// 點擊播放/暫停
    @objc private func playBtn(sender: UIButton) {
        if self.DLNAManager.getPlayStatus().value == .End {
            guard let model = videoModel else { return }
            self.views.changePostionTimeUI(text: self.viewModel.setPlayerTime(0), slider: 0)
            self.DLNAManager.setPositionTime(position: 0, temp: 0)
            self.DLNAManager.devicePlayVideo(device: DLNAManager.getDevice(), video: model) // 重新播放
        } else {
            self.DLNAManager.playPause(isToPlay: sender.isSelected) {
                sender.isSelected = !sender.isSelected
            }
        }
    }
    
    /// 點擊靜音
    @objc private func muteBtn() {
        let isMute = DLNAManager.getVolumeIsMute().value
        let originalVolume = DLNAManager.getVolume().value
        self.DLNAManager.debugMsg(.UI(.mute), value: isMute)
        self.DLNAManager.setVolumeMute(mute: !isMute)
        self.DLNAManager.setVolumeUpDown(value: !isMute ? 0: originalVolume, fromMute: !isMute)
    }
    
    /// 音量滑動
    @objc private func volumeProgressEdit(_ slider: UISlider?, for event: UIEvent?) {
        let volume: Float = slider?.value.rounded(digits: 2) ?? 0.0
        guard self.DLNAManager.getVolume().value != volume || self.DLNAManager.getVolumeIsMute().value else { return }
           let touchEvent = event?.allTouches?.first
           switch touchEvent?.phase {
           case .began:
               self.DLNAManager.debugMsg(.UI(.volume), value: "开始拖动")
           case .moved: break
//               self.DLNAManager.debugMsg(.UI(.volume), value: "正在拖动：\(Int(volume * 100))")
           case .ended:
               self.DLNAManager.debugMsg(.UI(.volume), value: "調整到：\(volume)")
               self.DLNAManager.setVolumeUpDown(value: volume)
           default:
               break
           }
       }
}

// MARK: - DiscoveryManagerDelegate - 搜尋可連接裝置
extension AirplayControlViewController: DiscoveryManagerDelegate {
    func discoveryManager(_ manager: DiscoveryManager!, didFind device: ConnectableDevice!) {
        self.DLNAManager.debugMsg(.discovery(.status), value: "didFind")
        self.DLNAManager.discoveryResult(manager)
        self.views.findDevice(isFind: true)
    }
    func discoveryManager(_ manager: DiscoveryManager!, didUpdate device: ConnectableDevice!) {
        self.DLNAManager.debugMsg(.discovery(.status), value: "didUpdate")
        self.DLNAManager.discoveryResult(manager)
        self.views.findDevice(isFind: true)
    }
    func discoveryManager(_ manager: DiscoveryManager!, didLose device: ConnectableDevice!) {
        self.DLNAManager.debugMsg(.discovery(.status), value: "didLose")
        let isFindDevice = DLNAManager.getDeviceDatas().value.count > 0
        self.views.findDevice(isFind: isFindDevice)
        self.views.searchDevice(searching: false)
    }
    func discoveryManager(_ manager: DiscoveryManager!, didFailWithError error: Error!) {
        self.DLNAManager.debugMsg(.discovery(.status), value: "didError", value2: error)
        let isFindDevice = DLNAManager.getDeviceDatas().value.count > 0
        self.views.findDevice(isFind: isFindDevice)
        self.views.searchDevice(searching: false)
    }
}

// MARK: - ConnectableDeviceDelegate - 連接裝置
extension AirplayControlViewController: ConnectableDeviceDelegate {
    
    func connectableDeviceReady(_ device: ConnectableDevice!) {
        self.DLNAManager.debugMsg(.device(.status), getSuc: true, value: "Ready")
        guard let model = videoModel else { return }
        self.DLNAManager.devicePlayVideo(device: device, video: model)
        self.DLNAManager.getDeviceVolume()
    }

    func connectableDeviceDisconnected(_ device: ConnectableDevice!, withError error: Error!) {
        self.DLNAManager.debugMsg(.device(.status), getSuc: true, value: "Disconnected:", value2: device.friendlyName)
    }
    
    func connectableDevice(_ device: ConnectableDevice!, connectionFailedWithError error: Error!) {
        self.DLNAManager.debugMsg(.device(.status), getSuc: true, value: "Error:", value2: device.friendlyName)
    }
}

extension AirplayControlViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DLNAManager.getDeviceDatas().value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: AirplayDeviceTableViewCell.self, for: indexPath)
        guard DLNAManager.getDeviceDatas().value.count > indexPath.row else { return cell }
        let deviceData = DLNAManager.getDeviceDatas().value[indexPath.row]
        cell.configCell(device: deviceData.device.friendlyName)
        cell.connectUISetup(deviceData.status)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.DLNAManager.getDeviceDatas().value.count > indexPath.row else { return }
        let device = self.DLNAManager.getDeviceDatas().value[indexPath.row].device
        self.DLNAManager.debugMsg(.UI(.device), value: device.friendlyName)
        self.DLNAManager.connectDevice(device: device, vc: self)
        self.DLNAManager.changeConnectStatus(device, .Waiting)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GlobalUtil.calculateWidthScaleWithSize(width: 40)
    }
}

// MARK: - UIScrollViewDelegate
extension AirplayControlViewController: UITextViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let verticalIndicator = scrollView.subviews.last?.subviews.first else { return }
        verticalIndicator.isHidden = true
        self.setIndicatorHeight(scrollView: scrollView)
        self.setIndicatorOffset(scrollView: scrollView)
    }
    
    private func setIndicatorHeight(scrollView: UIScrollView) {
        guard scrollView.contentSize.height > scrollView.bounds.height else {
            self.views.mScrollViewIndicator.frame.size.height = scrollView.frame.height
            self.views.mScrollViewIndicator.isHidden = false
            return
        }
        let scrollBarHeight = pow(scrollView.bounds.height, 2) / scrollView.contentSize.height
        self.views.mScrollViewIndicator.frame.size.height = scrollBarHeight
        self.views.mScrollViewIndicator.isHidden = false
    }
    
    private func setIndicatorOffset(scrollView: UIScrollView) {
        guard views.mScrollViewIndicator.isHidden == false else { return }
        let fact = scrollView.contentOffset.y / (scrollView.contentSize.height - scrollView.frame.height)
        let y = (views.mScrollViewIndicatorBg.frame.height - views.mScrollViewIndicator.frame.height) * fact
        self.views.mScrollViewIndicator.frame.origin.y = y
    }
}

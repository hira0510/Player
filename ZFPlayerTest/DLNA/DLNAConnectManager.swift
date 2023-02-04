//
//  DLNAConnectManager.swift
//  ZFPlayerTest
//
//  Created by  on 2022/12/5.
//

import UIKit
import ConnectSDK
import RxCocoa

typealias DeviceModel = (device: ConnectableDevice, status: ConnectStatus)

enum DebugType: Equatable {
    case discovery(_ type: discoveryType)
    case device(_ type: deviceType)
    case video(_ type: videoType)
    case UI(_ type: uiType)
    
    enum discoveryType: String {
        case search = "[搜尋裝置][搜尋]"
        case status = "[搜尋裝置][搜尋狀態]"
        case result = "[搜尋裝置][搜尋結果]"
        case changeStatus = "[搜尋裝置][更換狀態]"
    }
    
    enum deviceType: String {
        case mute = "[設備][靜音]"
        case volume = "[設備][音量]"
        case status = "[設備][狀態]"
        case changeStatus = "[設備][轉換狀態]"
    }
    
    enum videoType: String {
        case hls = "[影片][畫質]"
        case seek = "[影片][播放進度]"
        case play = "[影片][影片播放]"
        case status = "[影片][播放狀態]"
        case position = "[影片][播放頭]"
        case duration = "[影片][總時間]"
        case bind = "[影片][播放狀態][綁定]"
        case changeHls = "[影片][更換畫質調整進度]"
        case changeHls2 = "[影片][更換畫質調整進度][記錄時間]"
    }
    
    enum uiType: String {
        case mute = "[面板][靜音]"
        case close = "[面板][關閉]"
        case volume = "[面板][音量]"
        case hls = "[面板][更換畫質]"
        case device = "[面板][設備]"
        case position = "[面板][調整播放進度]"
    }
    
    static func getMsg(_ type: DebugType) -> String {
        switch type {
        case .device(let type): return type.rawValue
        case .discovery(let type): return type.rawValue
        case .video(let type): return type.rawValue
        case .UI(let type): return type.rawValue
        }
    }
}

enum ConnectStatus {
    case NotSelect
    case Fail
    case Success
    case Waiting
}

enum PlayStatus {
    case NotPlay
    case Play
    case End
    case Other //Unknown, Idle, Paused, Bufferin
}

class DLNAConnectManager {

    private static var instance: DLNAConnectManager? = nil
    public static var share: DLNAConnectManager {
        get {
            objc_sync_enter(DLNAConnectManager.self)
            if instance == nil {
                instance = DLNAConnectManager()
            }
            objc_sync_exit(DLNAConnectManager.self)
            return instance!
        }
    }
    
    /// 開啟Debug模式
    private var DEBUGMODE = true
    /// 搜尋裝置
    private var mDiscoveryManager: DiscoveryManager?
    /// 搜尋到的設備
    private var mDeviceDatas: BehaviorRelay<[DeviceModel]> = BehaviorRelay<[DeviceModel]>(value: [])
    /// 連接到的設備
    private var mDevice: ConnectableDevice?
    /// 音量
    private var mVolume: BehaviorRelay<Float> = BehaviorRelay<Float>(value: 0)
    /// 靜音
    private var mVolumeIsMute: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    /// 播放狀態
    private var mPlayStatus: BehaviorRelay<PlayStatus> = BehaviorRelay<PlayStatus>(value: .NotPlay)
    /// 是否開始播放
    private var mIsStartPlay: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    /// 播放物件
    private var mLaunchObject: MediaLaunchObject?
    /// 播放控制物件
    private var mMediaControl: MediaControl?
    /// 音量控制物件
    private var mVolumeControl: VolumeControl?
    /// 影片總時間(秒)
    private var mTotalTime: BehaviorRelay<Double> = BehaviorRelay<Double>(value: 0)
    /// 影片播放進度(秒)
    private var mPositionTime: BehaviorRelay<Double> = BehaviorRelay<Double>(value: 0)
    /// 影片播放進度,暫存的,跟現在進度比對用(秒)
    private var mPositionTempTime: BehaviorRelay<Double> = BehaviorRelay<Double>(value: 0)
    /// 影片播放進度,暫存的,切換畫質用的(秒)
    private var mChangeHlsSeekTime: BehaviorRelay<Double> = BehaviorRelay<Double>(value: 0)
    /// 正在播的是不是標清
    private var mIsPlayUrl240: BehaviorRelay<Bool?> = BehaviorRelay<Bool?>(value: nil)
    /// 播放時間Timer
    private var mPlayTimer: Timer?
    /// 影片資訊Timer
    private var mMediaInfoTimer: Timer?
    
    /// 拿搜尋Manager
    public func getDiscoveryManager() -> DiscoveryManager? {
        return mDiscoveryManager
    }
    
    /// 拿搜尋到的設備
    public func getDeviceDatas() -> BehaviorRelay<[DeviceModel]> {
        return mDeviceDatas
    }
    
    /// 拿取播放裝置
    public func getDevice() -> ConnectableDevice? {
        return self.mDevice
    }
    
    /// 拿取播放控制物件
    public func getMediaControl() -> MediaControl? {
        return self.mMediaControl
    }
    
    /// 拿取音量控制物件
    public func getVolumeControl() -> VolumeControl? {
        return self.mVolumeControl
    }
    
    /// 拿取是否靜音
    public func getVolumeIsMute() -> BehaviorRelay<Bool> {
        return self.mVolumeIsMute
    }
    
    /// 拿是否開始播放
    public func getIsStartPlay() -> BehaviorRelay<Bool> {
        return self.mIsStartPlay
    }
    
    /// 拿取播放狀態
    public func getPlayStatus() -> BehaviorRelay<PlayStatus> {
        return self.mPlayStatus
    }
    
    /// 拿取音量
    public func getVolume() -> BehaviorRelay<Float> {
        return self.mVolume
    }
    
    /// 拿取影片總時間
    public func getTotalTime() -> BehaviorRelay<Double> {
        return self.mTotalTime
    }
    
    /// 拿取播放播放進度
    public func getPositionTime() -> BehaviorRelay<Double> {
        return self.mPositionTime
    }
    
    /// 拿取暫時播放播放進度
    public func getPositionTempTime() -> BehaviorRelay<Double> {
        return self.mPositionTempTime
    }
    
    /// 拿取切換畫質播放進度
    public func getChangeHlsSeekTime() -> Double {
        return self.mChangeHlsSeekTime.value
    }
    
    /// 拿正在播的是不是標清
    public func getIsPlayUrl240() -> BehaviorRelay<Bool?> {
        return mIsPlayUrl240
    }
     
    /// 設定播放、暫時播放進度
    public func setPositionTime(position: Double? = nil, temp: Double? = nil, hls: Double? = nil) {
        if let hls = hls {
            self.mChangeHlsSeekTime.accept(hls)
        }
        if let position = position {
            self.mPositionTime.accept(position)
        }
        if let temp = temp {
            self.mPositionTempTime.accept(temp)
        }
    }
    
    /// 停止搜尋裝置
    public func closeDiscovery() {
        mDiscoveryManager?.stopDiscovery()
        mDiscoveryManager = nil
        self.debugMsg(.discovery(.search), start: false)
    }
    
    /// 初始化搜尋裝置
    public func startDiscoveryTV<vc: UIViewController>(vc: vc) where vc: AirplayControlViewController {
        let isFirstInit = mDiscoveryManager == nil
        if isFirstInit {
            // 限制只能搜尋到DLNA
            DiscoveryManager.shared().registerDeviceService(DLNAService.self, withDiscovery: SSDPDiscoveryProvider.self)
            mDiscoveryManager = DiscoveryManager.shared()
        }
        AirPlayService.setAirPlayServiceMode(AirPlayServiceModeMedia)
        DIALService.registerApp("AVNight")
        
        mDiscoveryManager?.delegate = vc
        mDiscoveryManager?.pairingLevel = DeviceServicePairingLevelOn
        mDiscoveryManager?.startDiscovery()
        self.debugMsg(.discovery(.search), start: true)
    }
    
    /// 搜尋結果
    public func discoveryResult(_ manager: DiscoveryManager!) {
        guard let deviceDatas: [AnyHashable : ConnectableDevice] = manager.allDevices() as? [AnyHashable : ConnectableDevice] else { return }
        let newDevice = [ConnectableDevice](deviceDatas.values)
        var newDeviceData: [DeviceModel] = newDevice.map { ($0, ConnectStatus.NotSelect) }
        let oldDeviceDatas = self.mDeviceDatas.value
        let oldDeviceAddress = oldDeviceDatas.map { $0.device.address }
        
        for (newIndex, deviceData) in newDeviceData.enumerated() {
            if let oldIndex = oldDeviceAddress.firstIndex(of: deviceData.device.address) {
                newDeviceData[newIndex].status = oldDeviceDatas[oldIndex].status
                self.debugMsg(.discovery(.changeStatus), setSuc: true, value: deviceData.device.friendlyName, value2: "\(newDeviceData[newIndex].status)->\(oldDeviceDatas[oldIndex].status)")
            }
        }
        self.debugMsg(.discovery(.result), getSuc: true)
        self.mDeviceDatas.accept(newDeviceData)
    }
    
    /// 連接裝置
    public func connectDevice<vc: UIViewController>(device: ConnectableDevice, vc: vc) where vc: AirplayControlViewController {
        if let mediaControl = getMediaControl() {
            mediaControl.stop(success: nil, failure: nil)
        }
        mDevice?.disconnect()
        mDevice = device
        mVolumeControl = device.volumeControl()
        mDevice?.delegate = vc
        mDevice?.setPairingType(DeviceServicePairingTypeFirstScreen)
        mDevice?.connect()
    }
    
    /// 設定播放控制物件
    private func setLaunchObject(object: MediaLaunchObject?) {
        self.mLaunchObject = object
        self.mMediaControl = object?.mediaControl
    }
    
    /// 設備轉換狀態
    public func changeConnectStatus(_ device: ConnectableDevice, _ status: ConnectStatus) {
        let deviceAry = getDeviceDatas().value.map { $0.device }
        var deviceData = self.mDeviceDatas.value
        self.debugMsg(.device(.changeStatus), start: true)
        for (i, value) in deviceAry.enumerated() {
            if value == device {
                deviceData[i].status = status
                self.debugMsg(.device(.changeStatus), setSuc: true, value: value.friendlyName, value2: status)
            } else {
                deviceData[i].status = .NotSelect
                self.debugMsg(.device(.changeStatus), setSuc: true, value: value.friendlyName, value2: deviceData[i].status)
            }
        }
        self.mDeviceDatas.accept(deviceData)
    }
    
    /// 播放/暫停
    public func playPause(isToPlay: Bool, success:()->()) {
        guard let mediaControl = self.mMediaControl else { return }
        if isToPlay {
            self.debugMsg(.video(.play), setSuc: true, value: "繼續")
            mediaControl.play(success: nil, failure: nil)
        } else {
            self.debugMsg(.video(.play), setSuc: true, value: "暫停")
            mediaControl.pause(success: nil, failure: nil)
        }
        success()
    }
    
    /// 調整播放進度
    public func seekTo(_ sec: Double) {
        guard let mediaControl = self.mMediaControl else { return }
        self.setPositionTime(hls: 0)
        mediaControl.seek(sec) { [weak self] _ in
            guard let `self` = self else { return }
            print("重點測試🟢2 sec:\(sec)")
            self.setPositionTime(position: sec, temp: sec)
            self.timerAddFunc()
            self.debugMsg(.video(.seek), setSuc: true, value: sec)
        } failure: { [weak self] error in
            guard let `self` = self else { return }
            self.debugMsg(.video(.seek), setSuc: false, value: error)
        }
    }
    
    /// 影片播放狀態
    private func mediaPlayStateSucBlock() -> MediaPlayStateSuccessBlock {
        let block: MediaPlayStateSuccessBlock = { [weak self] playState in
            guard let `self` = self else { return }
            switch playState {
            case .init(rawValue: 2): // Playing
                self.debugMsg(.video(.status), getSuc: true, value: "Playing")
                self.timerAddFunc()
                self.mPlayStatus.accept(.Play)
            case .init(rawValue: 5): // Finished
                self.debugMsg(.video(.status), getSuc: true, value: "Finished")
                self.mPlayStatus.accept(.End)
            default: // 0:Unknown, 1:Idle, 3:Paused, 4: Bufferin
                self.debugMsg(.video(.status), getSuc: true, value: playState)
                self.timerStop(play: true)
                self.mPlayStatus.accept(.Other)
            }
        }
        return block
    }
    
    /// 新增Timer
    public func timerAddFunc() {
        self.timerStop(play: true, media: true)
        self.mMediaInfoTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateMediaInfo), userInfo: nil, repeats: true)
        self.mPlayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updatePlayerPlayTime), userInfo: nil, repeats: true)
    }
    
    /// 停止Timer
    public func timerStop(play: Bool = false, media: Bool = false) {
        if play, self.mPlayTimer != nil {
            self.mPlayTimer?.invalidate()
        }
        if media, self.mMediaInfoTimer != nil {
            self.mMediaInfoTimer?.invalidate()
        }
    }
    
    /// 重新整理影片資訊
    @objc private func updateMediaInfo() {
        mMediaControl?.getPlayState(success: mediaPlayStateSucBlock(), failure: nil)
        
        getDeviceVolume(fromTimer: true)
        
        mMediaControl?.getDurationWithSuccess({ [weak self] duration in
            guard let `self` = self, duration > 0 else { return }
            self.mTotalTime.accept(duration)
        }, failure: { [weak self] error in
            guard let `self` = self else { return }
            self.debugMsg(.video(.duration), getSuc: false, value: error)
        })
        
        mMediaControl?.getPositionWithSuccess({ [weak self] position in
            guard let `self` = self, position > 0 else { return }
            if let timer = self.mPlayTimer, timer.isValid {
                self.setPositionTime(temp: position)
            } else {
                self.setPositionTime(position: position, temp: position)
            }
        }, failure: { [weak self] error in
            guard let `self` = self else { return }
            self.debugMsg(.video(.position), getSuc: false, value: error)
        })
    }
    
    /// 設定播放頭秒數
    @objc private func updatePlayerPlayTime() {
        setPositionTime(position: mPositionTempTime.value + 1)
    }
    
    /// 拿取影片播放狀態
    public func getPlayState() {
        if let device = self.mDevice, let mediaControl = mMediaControl, device.hasCapability(kMediaControlPlayStateSubscribe) {
            mediaControl.subscribePlayState(success: self.mediaPlayStateSucBlock()) { [weak self] error in
                guard let `self` = self else { return }
                self.debugMsg(.video(.play), getSuc: false, value: error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    guard let `self` = self else { return }
                    self.getPlayState()
                }
            }
        } else {
            self.debugMsg(.video(.play), getSuc: false, value: "無綁定")
            self.timerAddFunc()
        }
    }
    
    /// 影片播放
    public func devicePlayVideo(device: ConnectableDevice?, is240: Bool? = nil, video: PlayerDLNAModel, changeHls:Bool = false) {
        guard let device = device else { return }
        let is240Video: Bool = is240 ?? mIsPlayUrl240.value ?? true
        guard let mediaURL = is240Video ? video.urlAry.first: video.urlAry.last else {
            changeConnectStatus(device, .Fail)
            return
        }
        let iconURL = URL(string: video.img)
        let mimeType = "video/m3u8" // audio/* for audio files

        let mediaInfo = MediaInfo(url: mediaURL, mimeType: mimeType)
        mediaInfo?.title = video.title
        mediaInfo?.description = video.videoId
        let imageInfo = ImageInfo(url: iconURL, type: UInt(ImageTypeThumb))
        mediaInfo?.addImage(imageInfo)

        // 字幕
        if device.hasCapability(kMediaPlayerSubtitleWebVTT) {
            let subtitleInfo = SubtitleInfo(url: mediaURL) { builder in
                builder.mimeType = "text/vtt"
                builder.language = "Chinese"
                builder.label = video.videoId
            }
            mediaInfo?.subtitleInfo = subtitleInfo
        }


        guard let mediaPlayer = device.mediaPlayer() else { return }
        self.debugMsg(.video(.changeHls2), setSuc: true, value: mPositionTime.value)
        print("重點測試🟢2 hls:\(mPositionTime.value), bef: \(mChangeHlsSeekTime.value)")
        if mPositionTime.value > 3 {
            self.setPositionTime(hls: mPositionTime.value)
        }
        self.setPositionTime(position: 0, temp: 0)
        
        mediaPlayer.playMedia(with: mediaInfo, shouldLoop: false, success: { [weak self] mediaLaunchObject in
            guard let  `self` = self else { return }
            self.debugMsg(.video(.play), setSuc: true)
            // save the object reference to control media playback
            self.setLaunchObject(object: mediaLaunchObject)
            // enable your media control UI elements here
            self.mIsStartPlay.accept(true)
            self.mIsPlayUrl240.accept(is240Video)
        }, failure: { [weak self] error in
            guard let  `self` = self else { return }
            self.changeConnectStatus(device, .Fail)
            self.debugMsg(.video(.play), setSuc: false, value: error)
        })
    }
    
    /// 更改靜音
    public func setVolumeMute(mute: Bool) {
        guard let volumeControl = mVolumeControl, self.mVolumeIsMute.value != mute else { return }
        volumeControl.setMute(mute, success: { [weak self] _ in
            guard let `self` = self else { return }
            self.debugMsg(.device(.mute), setSuc: true, value: mute)
            self.mVolumeIsMute.accept(mute)
        }, failure: nil)
    }
    
    /// 更改音量
    public func setVolumeUpDown(value: Float? = nil, fromMute: Bool = false) {
        guard let volumeControl = mVolumeControl else { return }
        if let volume = value {
            let volume = volume.rounded(digits: 2)
            volumeControl.setVolume(volume) { [weak self] _ in
                guard let `self` = self, !fromMute else { return }
                self.getDeviceVolume(volume)
                self.debugMsg(.device(.volume), setSuc: true, value: volume)
            } failure: { _ in }
        }
    }
    
    /// 獲取音量
    public func getDeviceVolume(_ setValue: Float? = nil, fromTimer: Bool = false) {
        guard let volumeControl = mVolumeControl else { return }
        volumeControl.getVolumeWithSuccess { [weak self] volume in
            guard let `self` = self else { return }
            // 有些裝置無法獲得音量，但卻可以設定
            let newVolume = setValue == nil ? volume: (setValue ?? 0)
            let isSeek = self.mVolume.value != newVolume
            //點靜音不調音量。靜音時調動音量、遙控器調動音量、單純調動音量>要調音量
            if (isSeek && !fromTimer) || (isSeek && fromTimer && self.mPlayStatus.value != .End) || (self.mVolumeIsMute.value && isSeek) {
                self.mVolume.accept(newVolume)
            }
            
            // 獲取音量是否靜音 測mac剛開始沒辦法判斷靜音，一律用音量判斷靜音
            let isMute = newVolume < 0.01
            if self.mVolumeIsMute.value != isMute {
                self.setVolumeMute(mute: isMute)
            }
        } failure: { [weak self] error in
            guard let `self` = self else { return }
//            self.mVolume.accept(0)
//            self.setVolumeMute(mute: true)
            self.debugMsg(.device(.volume), getSuc: false, value: error)
        }
    }
    
    /// 點擊關閉投屏退出頁面後不在播放 資料全重置
    public func disconnectDevice() {
        if let device = mDevice {
            device.disconnect()
        }
        if let mediaControl = mMediaControl {
            mediaControl.stop(success: nil, failure: nil)
        }
        
        self.closeDiscovery()
        self.mDevice = nil
        self.mLaunchObject = nil
        self.mMediaControl = nil
        self.mVolumeControl = nil
        //timer
        self.timerStop(play: true, media: true)
        self.mPlayTimer = nil
        self.mMediaInfoTimer = nil
        
        // UI
        self.setPositionTime(position: 0, temp: 0, hls: 0)
        self.mDeviceDatas.accept([])
        self.mTotalTime.accept(0)
        self.mPlayStatus.accept(.NotPlay)
        self.mVolume.accept(0)
        self.mIsPlayUrl240.accept(nil)
        self.mVolumeIsMute.accept(true)
        self.mIsStartPlay.accept(false)
        self.debugMsg(.device(.changeStatus), setSuc: true, value: "關閉投屏")
    }
    
    /// debug文字
    public func debugMsg(_ type: DebugType, getSuc: Bool? = nil, setSuc: Bool? = nil, start: Bool? = nil, value: Any? = nil, value2: Any? = nil) {
        guard DEBUGMODE else { return }
        var title = "🟠[DLNA]"
        title.append(DebugType.getMsg(type))
        if let isGetSuc = getSuc {
            title.append("[Get]\(isGetSuc ? "[Suc]": "[Err]")")
        }
        if let isSetSuc = setSuc {
            title.append("[Set]\(isSetSuc ? "[Suc]": "[Err]")")
        }
        if let isStart = start {
            title.append("\(isStart ? "[Start]": "[End]")")
        }
        if let msgValue = value {
            title.append(" \(msgValue)")
        }
        if let msgValue2 = value2 {
            title.append(" \(msgValue2)")
        }
        print(title)
    }
}

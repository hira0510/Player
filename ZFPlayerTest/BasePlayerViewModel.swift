//
//  BasePlayerViewModel.swift
//  avnight
//
//  Created by  on 2021/3/8.
//  Copyright © 2021 com. All rights reserved.
//

import UIKit

class BasePlayerViewModel {
    
    /// 影片速度倍率Str
    public lazy var rateChoose: String = "1 X"
    /// 影片速度倍率Float
    public lazy var rateChooseFloat: Float = 1.0
    public var mPlayerControllerViewHiddenTime: TimeInterval = 5
    /// 播放時間
    public lazy var playTime: Int = GlobalUtil.currentTimeInterval()

    internal lazy var isWatched: Bool = false
    internal lazy var mTemporaryPlayerTime: TimeInterval = 0.0
    internal lazy var mIsFullScreen: Bool = false
    internal lazy var mIsFirstDiplayPlayerAd: Bool = true
}

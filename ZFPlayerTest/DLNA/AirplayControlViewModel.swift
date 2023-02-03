//
//  AirplayControlViewModel.swift
//  ZFPlayerTest
//
//  Created by  on 2022/12/15.
//

import UIKit

class AirplayControlViewModel: BasePlayerViewModel {
    
    func setPlayerTime(_ time: Double) -> String {
        var timeStr: String = "00:00"
        let timeInt = Int(time)
        let seconds = timeInt % 60
        let hour = timeInt / 3600
        let minute = timeInt > 3600 ? (timeInt / 60 - (60*hour)): timeInt / 60
        if hour <= 0 {
            timeStr = minute < 10 ? "0\(minute)": "\(minute)"
            timeStr += seconds < 10 ? ":0\(seconds)": ":\(seconds)"
        } else {
            timeStr = hour < 10 ? "0\(hour)": "\(hour)"
            timeStr += minute < 10 ? ":0\(minute)": ":\(minute)"
            timeStr += seconds < 10 ? ":0\(seconds)": ":\(seconds)"
        }
        return timeStr
    }
}

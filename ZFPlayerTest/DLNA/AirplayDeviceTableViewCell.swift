//
//  AirplayDeviceTableViewCell.swift
//  ZFPlayerTest
//
//  Created by  on 2022/12/5.
//

import UIKit
import Lottie

class AirplayDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var waitImageView: UIImageView!
    @IBOutlet weak var connectSucImageView: UIImageView!
    
    static var nib: UINib {
        return UINib(nibName: "AirplayDeviceTableViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let animationView = AnimationView(name: "DLNAWait")
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.frame = CGRect(x: 0, y: 0, width: waitImageView.frame.width, height: waitImageView.frame.height)
        waitImageView.addSubview(animationView)
        
        commonInit()
    }
    
    public func configCell(device: String) {
        deviceLabel.text = device
    }
    
    /// 更變連線狀態UI
    public func connectUISetup(_ status: ConnectStatus) {
        switch status {
        case .NotSelect:
            self.connectNotSelect()
        case .Fail:
            self.connectSuccessOrFail(suc: false)
        case .Success:
            self.connectSuccessOrFail(suc: true)
        case .Waiting:
            self.connectWait()
        }
    }
    
    private func commonInit() {
        waitImageView.isHidden = true
        connectSucImageView.isHidden = true
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        self.selectedBackgroundView = bgColorView
    }
    
    private func connectNotSelect() {
        connectSucImageView.isHidden = true
        waitImageView.isHidden = true
        deviceLabel.textColor = UIColor(0x8e8e8e)
    }
    
    private func connectWait() {
        connectSucImageView.isHidden = true
        waitImageView.isHidden = false
        deviceLabel.textColor = .white
    }
    
    private func connectSuccessOrFail(suc: Bool) {
        connectSucImageView.isHidden = false
        waitImageView.isHidden = true
        deviceLabel.textColor = suc ? UIColor.white: UIColor(0x8e8e8e)
    }
}

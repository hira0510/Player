//
//  TestViewController.swift
//  ZFPlayerTest
//
//  Created by Hira on 2022/9/21.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var playerView: ForCellPlayerView!
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        playerView.initPlayer(urlStr: "https://v.kdianbo.com/20220919/4MRd4Mp5/index.m3u8", index: 0)
//        playerView.zfPlayerSetUrlPlay("https://v.kdianbo.com/20220919/4MRd4Mp5/index.m3u8", 0)
    }
}

//
//  LittleCell.swift
//  ZFPlayerTest
//
//  Created by Hira on 2022/9/21.
//

import UIKit

class LittleCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    static var nib: UINib {
        return UINib(nibName: "LittleCell", bundle: Bundle(for: self))
    }
    
    public func configCell(index: Int) {
        titleLabel.text = "我是第\(index)部影片"
    }

}

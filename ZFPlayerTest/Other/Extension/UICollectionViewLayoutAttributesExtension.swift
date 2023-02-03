//
//  UICollectionViewLayoutAttributesExtension.swift
//  avnight
//
//  Created by  on 12/4/21.
//  Copyright © 2021 com. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewLayoutAttributes {
    func leftAlignFrame(with sectionInset: UIEdgeInsets){
        var tempFrame = frame
        tempFrame.origin.x = sectionInset.left
        frame = tempFrame
    }
}

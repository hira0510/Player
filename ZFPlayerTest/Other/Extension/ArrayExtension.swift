//
//  ArrayExtension.swift
//  avnight
//
//  Created by  on 2022/7/7.
//  Copyright © 2022 com. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
  func removingDuplicates() -> [Element] {
      var addedDict = [Element: Bool]()
      return filter {
        addedDict.updateValue(true, forKey: $0) == nil
      }
   }
   mutating func removeDuplicates() {
      self = self.removingDuplicates()
   }
}

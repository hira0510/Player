//
//  ProtocolExtension.swift
//  avnight
//
//  Copyright © 2020 com. All rights reserved.
//

import Foundation

protocol NGSBaseCodable: Codable {
    /// 轉換成Data
    func encode() -> Data?
}

extension NGSBaseCodable {
    func encode() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}
extension Float {
    func rounded(digits: Int) -> Float {
        let multiplier = pow(10.0, Float(digits))
        return (self * multiplier).rounded() / multiplier
    }
}

//
//  Data.swift
//  TrojanX
//
//  Created by Sakurai on 2020/1/5.
//  Copyright © 2020 Sakurai. All rights reserved.
//

import CommonCrypto
import Foundation

extension Data {
    func sha1() -> String {
        let data = self
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1((data as NSData).bytes, CC_LONG(data.count), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined(separator: "")
    }
}

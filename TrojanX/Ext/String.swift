//
//  String.swift
//  TrojanX
//
//  Created by Sakurai on 2020/01/04.
//  Copyright © 2020 Sakurai. All rights reserved.
//

import CommonCrypto
import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", comment: "")
    }
    
    func localized(comment: String) -> String {
        return NSLocalizedString(self, tableName: "Localizable", comment: comment)
    }
    
    func md5() -> String {
        let data = Data(utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

        data.withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }

        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}

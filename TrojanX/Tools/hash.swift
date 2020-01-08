//
//  hash.swift
//  TrojanX
//
//  Created by Sakurai on 2020/1/5.
//  Copyright © 2020 Sakurai. All rights reserved.
//

import Foundation


func getFileSha1Sum(_ filepath: String) -> String {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: filepath)) {
        return data.sha1()
    }
    return ""
}

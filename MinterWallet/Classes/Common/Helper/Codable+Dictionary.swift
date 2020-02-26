//
//  Codable+Dictionary.swift
//  MinterWallet
//
//  Created by Roman Slysh on 20.02.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import Foundation

extension Encodable {
	func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }

  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

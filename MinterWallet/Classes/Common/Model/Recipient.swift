//
//  Recipient.swift
//  MinterWallet
//
//  Created by Roman Slysh on 26.02.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import Foundation

struct Recipient: Equatable, Codable {
	let title: String
	let address: String
	
	public static func == (lhs: Recipient, rhs: Recipient) -> Bool {
		return lhs.title == rhs.title && lhs.address == rhs.address
	}
}

//
//  UserNetworkData.swift
//  MinterWallet
//
//  Created by Roman Slysh on 20.03.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import Foundation

struct UserNetworkData {
	var currentBlock: Int
	let delegatedBIP: Decimal
	let totalDelegatedBIP: Decimal
	let blockSpeed24h: Double
	let bipPerBlock: Decimal
}

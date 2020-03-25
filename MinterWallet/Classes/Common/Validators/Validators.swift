//
//  Validators.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 06/02/2019.
//  Copyright © 2019 Minter. All rights reserved.
//

import Foundation
import MinterCore

class BaseValidator {
	static let rundax = UIApplication.realAppDelegate()?.isTestnet ?? false ? "Mpa3c16ffc2af26f199dd23c52932ce22441f848aa3ab2b7015de01e2f9c293464" : "Mp31d08d6f64f7a8a528ed2df77de2a02e4d8cefae93c771eb0b7de97322901215"
}

class AmountValidator : BaseValidator {

	class func isValid(amount: Decimal) -> Bool {
		return amount >= 1/TransactionCoinFactorDecimal || amount == 0
	}
}

class CoinValidator : BaseValidator {

	class func isValid(coin: String?) -> Bool {
		return (coin?.count ?? 0) >= 3
	}
}

class UsernameValidator : BaseValidator {

	class func isValid(username: String?) -> Bool {
		return (username?.count ?? 0) >= 5
	}
}

class PasswordValidator : BaseValidator {

	class func isValid(password: String?) -> Bool {
		return (password?.count ?? 0) >= 6
	}
	
}

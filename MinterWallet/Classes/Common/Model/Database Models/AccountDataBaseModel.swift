//
//  AccountDataBaseModel.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 15/05/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import Foundation
import RealmSwift
import BigInt
import MinterCore
import MinterMy


class AccountDataBaseModel : Object, DatabaseStorageModel {
	
	@objc dynamic var address: String = ""
	@objc dynamic var encryptedBy: String = ""
	@objc dynamic var isMain: Bool = false
	@objc dynamic var lastPrice: Double = 0
	
	//MARK: -
	
	func substitute(with account: Account) {
		self.encryptedBy = account.encryptedBy.rawValue
		self.address = account.address
		self.isMain = account.isMain
	}

}

class UserDataBaseModel : Object, DatabaseStorageModel {
	@objc dynamic var id: Int = -1
	@objc dynamic var username: String = ""
	@objc dynamic var email: String = ""
	@objc dynamic var phone: String = ""
	
	//MARK: -
	
	func substitute(with user: User) {
		self.id = user.id ?? -1
		self.username = user.username ?? ""
		self.email = user.email ?? ""
//		self.phone = user.phone ?? ""
	}
	
	
}


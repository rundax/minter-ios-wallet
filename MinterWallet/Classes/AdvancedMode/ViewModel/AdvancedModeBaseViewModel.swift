//
//  AdvancedModeBaseViewModel.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 30/05/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import Foundation
import MinterCore
import MinterMy

class AccountantBaseViewModel: BaseViewModel {

	let accountManager = AccountManager()
	private let databaseStorage = RealmDatabaseStorage.shared

    func saveAccount(id: Int, mnemonic: String, isLocal: Bool = true, pairedCode: String? = nil) -> Account? {

		guard
			let seed = accountManager.seed(mnemonic: mnemonic, passphrase: ""),
			let account = accountManager.account(id: id,
																					 seed: seed,
																					 encryptedBy: isLocal ? .me : .bipWallet) else {
				return nil
		}

		var password = accountManager.password()

		if nil == password {
			accountManager.save(password: accountManager.generateRandomPassword(length: 32))
			password = accountManager.password()
		}

		guard nil != password else {
			assert(true)
			return nil
		}

		//save mnemonic
		do {
            try accountManager.save(mnemonic: mnemonic, password: password!, pairedCode: pairedCode)
		} catch {
			return nil
		}

		let accounts = databaseStorage.objects(class: AccountDataBaseModel.self) as? [AccountDataBaseModel]
		let hasObjects = !(accounts?.count == 0)

		//No repeated accounts allowed
		guard (accounts ?? []).filter({ (acc) -> Bool in
			return acc.address == account.address
		}).count == 0 else {
			return nil
		}

		let dbModel = AccountDataBaseModel()
		dbModel.address = account.address
		dbModel.encryptedBy = account.encryptedBy.rawValue
		dbModel.isMain = !hasObjects
		databaseStorage.add(object: dbModel)

		SessionHelper.reloadAccounts()
			
		let alert = BaseAlertController(title: "Save public address to keychain?".localized(), message: "It allows you easily paste your address in our web services", preferredStyle: .alert)
		let yesAction = UIAlertAction(title: "SAVE".localized(), style: .default) { action in
			self.accountManager.saveToSharedKeychain(address: "Mx" + account.address)
		}

		let cancelAction = UIAlertAction(title: "NO".localized(), style: .cancel)
		alert.addAction(yesAction)
		alert.addAction(cancelAction)
		alert.view.tintColor = UIColor.mainColor()
				
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}

			topController.present(alert, animated: true)
		}
		return account
	}

}

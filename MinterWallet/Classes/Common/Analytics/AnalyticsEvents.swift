//
//  AnalyticsEvents.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 05/09/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import Foundation
import YandexMobileMetrica

protocol AnalyticsProvider : class {
	func track(event: Analytics.Event, params: [String: Any]?)
}

class Analytics {

	enum Event: String {
		//Screens
		case coinsScreen
		case sendScreen
		case sendCoinPopupScreen
		case sentCoinPopupScreen
		case receiveScreen
		case settingsScreen
		case giftsScreen
		case transactionsScreen
		case convertSpendScreen
		case convertGetScreen
		case addressesScreen
		case usernameEditScreen
		case emailEditScreen
		case passwordEditScreen
		case rawTransactionScreen
		case twoFAModeScreen

		//Coins
		case coinsUsernameButton

		//Events
		//Transaction list
		case transactionDetailsButton
		case transactionExplorerButton

		//Send Coin
		case sendCoinsChooseCoinButton
		case sendCoinsClearAmountButton
		case sendCoinsSendButton
		case sendCoinsQRButton
		case sendCoinsGiftButton
		case sendCoins10Button
		case sendCoins100Button
		case sendCoins200Button
		case sendCoins500Button
		case sendCoins1000Button
		case sendCoinsUseMaxButton

		//SendCoinPopup
		case sendCoinPopupSendButton
		case sendCoinPopupCancelButton

		//SentCoinPopupScreen
		case sentCoinPopupViewTransactionButton
		case sentCoinPopupShareTransactionButton
		case sentCoinPopupCloseButton

		//ReceiveScreen
		case receiveShareButton

		//Settings
		case settingsChangeUserpicButton
		case settingsAddAccountButton
		case settingsLogoutButton

		//Addresses
		case addressesCopyButton
		case addressesAddAddressButton
		case addressesEditAddressButton
		case addressesDelete

		//ConvertSpend
		case convertSpendUseMaxButton
		case convertSpendExchangeButton

		//ConvertGet
		case convertGetExchangeButton

		//RawTransactionScreen
		case rawTransactionPopupViewTransactionButton
		case rawTransactionPopupShareTransactionButton
		case rawTransactionPopupCloseButton
		
		//2faModeScreen
		case twoFAModeActivateButton
		case twoFAModeSecretCodeButton
	}

	// MARK: -

	private var providers: [AnalyticsProvider] = []

	init(providers: [AnalyticsProvider]) {
		self.providers = providers
	}

	// MARK: -

	func track(event: Analytics.Event, params: [String: Any]? = nil) {
		self.providers.forEach { (provider) in
			provider.track(event: event, params: params)
		}
	}
}

class AppMetricaAnalyticsProvider: AnalyticsProvider {

	// MARK: - Analytics Provider

	func track(event: Analytics.Event, params: [String : Any]?) {
		YMMYandexMetrica
			.reportEvent(event.rawValue, parameters: params) { (error) in
			//error
		}
	}

	init() {
		YMMYandexMetrica.activate(with: YMMYandexMetricaConfiguration.init(apiKey: "a64c888f-e08e-42f5-97d9-d925da1bf4ae")!)
	}
}

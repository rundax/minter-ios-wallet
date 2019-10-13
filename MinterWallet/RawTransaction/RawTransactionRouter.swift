//
//  RawTransactionRouter.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 16/09/2019.
//  Copyright © 2019 Minter. All rights reserved.
//

import Foundation
import MinterCore
import BigInt

class RawTransactionRouter: BaseRouter {

	static var patterns: [String] {
		return ["tx"]
	}

	static func viewController(path: [String], param: [String: Any]) -> UIViewController? {
		guard Session.shared.isLoggedIn.value || Session.shared.accounts.value.count > 0 else {
			return nil
		}

		if let tx = param["d"] as? String {
			var nonce: BigUInt?
			var chainId: BigUInt?
			var gasPrice: BigUInt?
			var gasCoin: String = Coin.baseCoin().symbol!
			var type: RawTransactionType = .sendCoin
			var txData: Data?
			var payload: String?
			var serviceData: Data?
			var signatureType: Data?

			guard
				let rlpItem = RLP.decode(tx),
				let content = rlpItem[0]?.content
			else { return nil }

			switch content {
			case .noItem:
				break

			case .list(let items, let count, let data):
				//Full tx version
				if items.count == 9 || items.count == 10 {
					guard
						let nonceData = items[safe: 0]?.data,
						let chainIdData = items[safe: 1]?.data,
						let gasPriceData = items[safe: 2]?.data,
						let gasCoinData = items[safe: 3]?.data,
						let typeData = items[safe: 4]?.data,
						let txDataData = RLP.decode(items[safe: 5]?.data ?? Data())?.data,
						let payloadData = items[safe: 6]?.data,
						let serviceDataData = items[safe: 7]?.data,
						let signatureTypeData = items[safe: 8]?.data
					else { return nil }

					nonce = BigUInt(nonceData)
					chainId = BigUInt(chainIdData)
					gasPrice = BigUInt(gasPriceData)
					if let newGasCoin = String(data: gasCoinData, encoding: .utf8)?
						.replacingOccurrences(of: "\0", with: "") {
						gasCoin = newGasCoin
					}
					let typeBigInt = BigUInt(typeData)
					guard let txType = RawTransactionType.type(with: typeBigInt) else {
						return nil
					}
					type = txType
					txData = txDataData
					payload = String(data: payloadData, encoding: .utf8)
					serviceData = serviceDataData
					signatureType = signatureTypeData
				} else if items.count >= 3 {//shortened version
					guard
						let typeData = items[safe: 0]?.data,
						let txDataData = RLP.decode(items[safe: 1]?.data ?? Data())?.data,
						let payloadData = items[safe: 2]?.data
					else { return nil }

					let nonceData = items[safe: 3]?.data ?? Data()
					let gasPriceData = items[safe: 4]?.data ?? Data()
					let gasCoinData = items[safe: 5]?.data ?? Data()

					let nonceValue = BigUInt(nonceData)
					nonce = nonceValue > 0 ? nonceValue : nil

					let gasPriceValue = BigUInt(gasPriceData)
					gasPrice = gasPriceValue > 0 ? gasPriceValue : nil
					if let newGasCoin = String(coinData: gasCoinData) {
						gasCoin = (newGasCoin == "") ? Coin.baseCoin().symbol! : newGasCoin
					}
					let typeBigInt = BigUInt(typeData)
					guard let txType = RawTransactionType.type(with: typeBigInt) else {
						return nil
					}
					type = txType
					txData = txDataData
					payload = String(data: payloadData, encoding: .utf8)
				}
				break
			case .data(let data):
				break
			}

			let viewModel = RawTransactionViewModel(
				nonce: nonce,
				gasPrice: gasPrice,
				gasCoin: gasCoin,
				type: type,
				data: txData,
				payload: payload,
				serviceData: serviceData,
				signatureType: signatureType)

			let viewController = Storyboards.RawTransaction.instantiateInitialViewController()
			viewController.navigationBar.barStyle = .black
			(viewController.viewControllers.first as? RawTransactionViewController)?.viewModel = viewModel
			return viewController
		}
		return nil
	}
}

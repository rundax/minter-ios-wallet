//
//  Campaign.swift
//  MinterWallet
//
//  Created by Roman Slysh on 20.02.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import Foundation

enum CampaignType: String, Codable {
	case single
	case mass
}

struct Campaign: Codable {
	let campaignId: String
	let type: CampaignType
	let address: String
	let balance: Decimal
	let created: Int
	let coin: String?
	let coinToBip: Decimal
	let url: String
	let name: String?
	let brandName: String?
	let password: String?
	let passwordHint: String?
	let recipientId: String
	let campaignPublicId: String
	let rewardPerUser: Decimal
	let rewardPerUserUsd: Decimal?
	let giftNum: Int?
	let runOutOfGifts: Bool?
	let waitForRefill: Bool
}

struct CampaignData: Codable {
	let name: String
	let brandName: String
	let rewardPerUser: Int?
	let giftNum: Int?
	let password: String?
	let passwordHint: String?
}

//
//  PushManager.swift
//  MinterWallet
//
//  Created by Roman Slysh on 20.02.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import Foundation
import MinterCore
import Alamofire
import RxSwift

enum PushManagerError : Error {
	case wrongResponse
}

class PushManager: BaseManager {

// MARK: -

	static let shared = PushManager(httpClient: APIClient(headers: ["Content-Type": "application/json"]))
	
	private let configuration = Configuration()
	
	func campaign(_ type: CampaignType, uid: String, data: CampaignData? = nil) -> Observable<Campaign?> {
		return Observable.create { [weak self] (observer) -> Disposable in
			self?.campaign(type, uid: uid, data: data) { (campaign, error) in
				if let campaign = campaign {
					observer.onNext(campaign)
					observer.onCompleted()
				} else {
					observer.onError(error ?? PushManagerError.wrongResponse)
				}
			}
			return Disposables.create()
		}
	}
	
	func campaign(_ type: CampaignType, uid: String, data: CampaignData? = nil, completion: ((Campaign?, Error?) -> ())?) {
		guard let url = URL(string: configuration.environment.pushBaseAPIURL + "campaign") else { return }
		let dataDict: [String : Any]
		if let campaignData = data?.dictionary {
			dataDict = campaignData
		} else {
			dataDict = ["brandName": "iOS RUNDAX WALLET"]
		}
		let params: [String : Any] = ["type": type.rawValue,
																	"uid": uid,
																	"data": dataDict]
		
		Alamofire.request(url,
											method: .post,
											parameters: params,
											encoding: JSONEncoding.default)
			.validate()
			.responseJSON { response in
				switch response.result {
				case .success(let json):
					print("Success with JSON: \(json)")
					if let data = response.data {
						do {
							let campaign = try JSONDecoder().decode(Campaign.self, from: data)
							completion?(campaign, nil)
						} catch(let error) {
							print(error)
							completion?(nil, error)
						}
					} else {
						completion?(nil, response.error)
					}
				case .failure(let error):
					print("Request failed with error: \(error)")
					completion?(nil, PushManagerError.wrongResponse)
				}
		}

//		self.httpClient.postRequest(url, parameters: params, completion: { (response, error) in
//			if let resp = response.data as? [String: Any] {
//				print(resp)
//				completion?(resp, nil)
//			} else {
//				completion?(nil, PushManagerError.wrongResponse)
//			}
//		})
	}
}

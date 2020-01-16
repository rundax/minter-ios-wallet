//
//  EmailManager.swift
//  MinterWallet
//
//  Created by Roman Slysh on 12/2/19.
//  Copyright © 2019 Minter. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

struct Recipient: Equatable {
	let email: String
	let address: String
	
	public static func == (lhs: Recipient, rhs: Recipient) -> Bool {
		return lhs.email == rhs.email && lhs.address == rhs.address
	}
}

class EmailManager {
	static func getEmails(email: String) -> Observable<[Recipient]?> {
			return Observable.create { (observer) -> Disposable in
					if email != "", let url = URL(string: "https://api.myminter.net/minter/main/v01/") {
							Alamofire.request(url,
																method: .post,
																parameters: ["email": email])
							.validate()
							.responseJSON { response in
									switch response.result {
									case .success(let JSON):
											print("Success with JSON: \(JSON)")

											if let array = JSON as? Array<[String:String]> {
													var entities: Array<Recipient> = []
													for item in array {
															entities.append(Recipient(email: item["email"]!, address: item["address"]!))
													}
													observer.onNext(entities)
													observer.onCompleted()
											}

									case .failure(let error):
											print("Request failed with error: \(error)")
											observer.onError(error)
									}
							}
					}
					return Disposables.create()
			}
	}
}

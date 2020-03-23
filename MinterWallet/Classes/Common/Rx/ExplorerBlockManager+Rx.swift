//
//  .swift
//  MinterWallet
//
//  Created by Roman Slysh on 19.03.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import Foundation
import RxSwift
import MinterExplorer


extension ExplorerBlockManager {
	func block(height: Int) -> Observable<([String : Any]?)> {
		return Observable.create { (observer) -> Disposable in
			ExplorerBlockManager.default.block(height: height, completion: { (res, err) in
				guard err == nil else {
					observer.onError(err!)
					return
				}
				observer.onNext(res)
			})
			return Disposables.create()
		}
	}
}

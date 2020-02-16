//
//  TabBarController.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 02/04/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit
import RxSwift

class TabBarController: UITabBarController {

	// MARK: -

	let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		Session.shared.accounts.asObservable().distinctUntilChanged().filter({ (val) -> Bool in
			return val.count != 0
		}).subscribe(onNext: { [weak self] _ in

			self?.viewControllers?.forEach({ (vc) in
				if let nav = vc as? UINavigationController {
					let containsAddressScreen = nav.childViewControllers.contains(where: { vc in
						if vc.isKind(of: AddressViewController.self) {
							nav.popToViewController(vc, animated: true)
							return true
						}
						return false
					})
					if !containsAddressScreen {
						nav.popToRootViewController(animated: false)
					}
				}
			})
		}).disposed(by: disposeBag)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tabBar.invalidateIntrinsicContentSize()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: -

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override var childViewControllerForStatusBarStyle: UIViewController? {
		let vc = self.viewControllers?[safe: self.selectedIndex]
		let navVC = vc as? UINavigationController
		guard nil == navVC else {
			return navVC?.visibleViewController
		}

		return vc
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}

}

//
//  DelegatedViewModel.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 07/06/2019.
//  Copyright © 2019 Minter. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MinterCore
import MinterExplorer

class DelegatedViewModel: BaseViewModel, ViewModelProtocol {

	// MARK: -

	private var datasource = [String: [AddressDelegation]]()
	private var validators = [String: [String: Any?]]()
	private var source: [String] {
		let src = datasource.keys.sorted(by: { (del1, del2) -> Bool in
			let leftSum = (datasource[del1] ?? []).reduce(0) { $0 + ($1.bipValue ?? 0.0) }
			let rightSum = (datasource[del2] ?? []).reduce(0) { $0 + ($1.bipValue ?? 0.0) }
			return leftSum > rightSum
		})
		return src
	}
	private var balances = (try? Session.shared.allDelegatedBalance.value()) ?? []
	private let coinFormatter = CurrencyNumberFormatter.coinFormatter

	// MARK: - ViewModelProtocol

	struct Input {
		var viewDidLoad: AnyObserver<Void>
		var willDisplayCell: AnyObserver<WillDisplayCellEvent>
	}
	struct Output {
		var sections: Observable<[BaseTableSectionItem]>
	}
	struct Dependency {}
	var input: DelegatedViewModel.Input!
	var output: DelegatedViewModel.Output!
	var dependency: DelegatedViewModel.Dependency!

	// MARK: -

	private var page = 1
	private var isLoading = false
	private var canLoadMore = true
	private var sections = PublishSubject<[BaseTableSectionItem]>()
	private var viewDidLoad = PublishSubject<Void>()
	private var willDisplayCell = PublishSubject<WillDisplayCellEvent>()

	override init() {
		super.init()

		self.input = Input(viewDidLoad: viewDidLoad.asObserver(),
											 willDisplayCell: willDisplayCell.asObserver())
		self.output = Output(sections: sections.asObservable())
		self.dependency = Dependency()

		viewDidLoad.subscribe(onNext: { [weak self] (_) in
			self?.createSections()
			self?.loadDelegatedBalance()
		}).disposed(by: disposeBag)

		Observable.combineLatest(willDisplayCell.asObservable(),
														 sections.asObservable())
			.subscribe(onNext: { [weak self] (val) in
				let indexPath = val.0.indexPath
				if false == self?.isLoading
					&& true == self?.canLoadMore
					&& indexPath.section >= val.1.count - 5 {
					//should reload now?
					self?.loadDelegatedBalance()
				}
			}).disposed(by: disposeBag)
	}

	func createSections() {
		var sections = [BaseTableSectionItem]()
		datasource = [:]
		balances.sorted(by: { (del1, del2) -> Bool in
			return (del1.publicKey ?? "") > (del2.publicKey ?? "")
		}).forEach { (del) in
//			let newVal = [del.coin ?? "": del.value ?? 0]
			let publicKey = del.publicKey ?? ""
			if nil != datasource[publicKey] {
				datasource[publicKey]?.append(del)
			} else {
				datasource[publicKey] = [del]
			}
			validators[publicKey] = ["name": del.validatorName,
															 "desc": del.validatorDesc,
															 "icon": del.validatorIconURL,
															 "site": del.validatorSiteURL
			]
		}

		source.forEach { (publicKey) in
			var cells = [BaseCellItem]()
			let nodeCell = DelegatedTableViewCellItem(reuseIdentifier: "DelegatedTableViewCell",
																								identifier: "DelegatedTableViewCell_" + publicKey)
			nodeCell.title = validators[publicKey]?["name"] as? String
			nodeCell.iconURL = validators[publicKey]?["icon"] as? URL
			nodeCell.publicKey = publicKey
			cells.append(nodeCell)

			(datasource[publicKey])?.sorted(by: { (del1, del2) -> Bool in
				return (del1.bipValue ?? 0.0) > (del2.bipValue ?? 0.0)
			}).forEach({ (del) in
//				del.keys.forEach({ (key) in
					let separator = SeparatorTableViewCellItem(reuseIdentifier: "SeparatorTableViewCell",
																										 identifier: "SeparatorTableViewCell_" + publicKey + (del.coin ?? "") + String.random())
					cells.append(separator)

				let bal = del.value ?? 0.0
					let cell = TwoTitleTableViewCellItem(reuseIdentifier: "TwoTitleTableViewCell",
																							 identifier: "TwoTitleTableViewCell_" + publicKey + (del.coin ?? ""))
					cell.title = del.coin ?? ""
					cell.subtitle = coinFormatter.string(from: (bal ?? 0.0) as NSNumber)
					cells.append(cell)
//				})
			})

			let separator1 = SeparatorTableViewCellItem(reuseIdentifier: "SeparatorTableViewCell",
																									identifier: "SeparatorTableViewCell_1" + String.random())
			cells.append(separator1)
			let section = BaseTableSectionItem(header: nil, items: cells)
			sections.append(section)
		}
		self.sections.onNext(sections)
	}

	func loadDelegatedBalance() {
		let addresses = Session.shared.accounts.value.compactMap({ (account) -> String? in
			return "Mx" + account.address.stripMinterHexPrefix()
		})

		guard addresses.count > 0 else {
			return
		}
		
		Observable.combineLatest(addresses.map { ExplorerAddressManager.default
			.delegations(address: $0, page: self.page) }).do(onNext: { [weak self] (_) in
			self?.isLoading = false
		}, onError: { [weak self] (_) in
			self?.isLoading = false
		}, onSubscribe: {

		}, onSubscribed: {
			self.isLoading = true
		}).subscribe( { [weak self] values in
			self?.page += 1
			for idx in 0..<addresses.count {
				if let delegation = values.element?[idx].0, delegation.count > 0 {
					if self?.balances.count == 0 {
						self?.balances.append(contentsOf: delegation)
					} else {
						var newDelegations: [AddressDelegation] = []
						for del in delegation {
							var exists = false
							for balance in self?.balances ?? [] {
								if balance.coin == del.coin, balance.publicKey == del.publicKey {
									balance.value = (balance.value ?? 0) + (del.value ?? 0)
									balance.bipValue = (balance.bipValue ?? 0) + (del.bipValue ?? 0)
									exists = true
									continue
								}
							}
							if !exists {
								newDelegations.append(del)
							}
						}
						self?.balances.append(contentsOf: newDelegations)
					}
				}

				if (values.element?[idx].0)?.count == 0 {
					self?.canLoadMore = false
				}
			}
			self?.createSections()
		})
		.disposed(by: disposeBag)
	}

	public func publicKey(for section: Int) -> String? {
		var ii = 0
		for index in source {
			if section == ii {
				return index
			}
			ii += 1
		}
		return nil
	}
}

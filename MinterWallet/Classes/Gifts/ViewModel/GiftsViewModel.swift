//
//  GiftsViewModel.swift
//  MinterWallet
//
//  Created by Roman Slysh on 25/02/2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import RxSwift
import MinterCore
import MinterMy

class GiftsViewModel: BaseViewModel, ViewModelProtocol {
	var title: String {
		get {
			return "Gift links".localized()
		}
	}

	var input: GiftsViewModel.Input!
	var output: GiftsViewModel.Output!

	// MARK: -

	struct Input {
	}

	struct Output {
	}

	struct Dependency {}
	
	private var sections = Variable([BaseTableSectionItem]())
	
	var campaigns: [Campaign] = []
	
	override init() {
		super.init()

		PushManager.shared.campaigns((Session.shared.accounts.value.first(where: {$0.isMain} )?.address ?? "")).subscribe(onNext: { [weak self] campaigns in
			self?.campaigns = campaigns ?? []
			self?.createSections()
		}).disposed(by: disposeBag)
	}
	
	private func createSections() {

		var addressNum = 0
		let sctns = campaigns.map { (campaign) -> BaseTableSectionItem in
			addressNum += 1

			let sectionId = campaign.address

			let separator = SeparatorTableViewCellItem(reuseIdentifier: "SeparatorTableViewCell",
																								 identifier: "SeparatorTableViewCell_1\(sectionId)")
			let separator1 = SeparatorTableViewCellItem(reuseIdentifier: "SeparatorTableViewCell",
																									identifier: "SeparatorTableViewCell_2\(sectionId)")
			let separator2 = SeparatorTableViewCellItem(reuseIdentifier: "SeparatorTableViewCell",
																									identifier: "SeparatorTableViewCell_3\(sectionId)")

			let link = CopyTableViewCellItem(reuseIdentifier: "CopyTableViewCell",
																						 identifier: "CopyTableViewCellItem_\(sectionId)")
			link.title = campaign.url
			link.buttonTitle = "Copy".localized()
			
			let address = AddressTableViewCellItem(reuseIdentifier: "CopyTableViewCell",
																						 identifier: "AddressTableViewCell_\(sectionId)")
			address.address = campaign.address
			address.buttonTitle = "Copy".localized()

			let balance = DisclosureTableViewCellItem(reuseIdentifier: "DisclosureTableViewCell",
																								identifier: "DisclosureTableViewCell_Balance_1\(sectionId)")
			balance.title = "Balance".localized()
			balance.showIndicator = false

			balance.value = "\(campaign.balance) \(campaign.coin ?? "")"
			balance.placeholder = ""

			var section = BaseTableSectionItem()
			section.identifier = sectionId

			section.items = [link, separator, address, separator1, balance, separator2]

			return section
		}
		sections.value = sctns
	}
	
	// MARK: -

	var accountObservable: Observable<[BaseTableSectionItem]> {
		return self.sections.asObservable()
	}

	// MARK: - TableView

	func section(index: Int) -> BaseTableSectionItem? {
		return sections.value[safe: index]
	}

	func sectionsCount() -> Int {
		return sections.value.count
	}

	func rowsCount(for section: Int) -> Int {
		return sections.value[safe: section]?.items.count ?? 0
	}

	func cellItem(section: Int, row: Int) -> BaseCellItem? {
		return sections.value[safe: section]?.items[safe: row]
	}
}

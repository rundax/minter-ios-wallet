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
	var input: GiftsViewModel.Input!
	var output: GiftsViewModel.Output!

	// MARK: -

	struct Input {
		var pin: AnyObserver<String>
	}

	struct Output {
		var showPINController: Observable<(String, String)>
		var hidePINController: Observable<Void>
		var showConfirmPINController: Observable<(String, String)>
		var shakePINError: Observable<Void>
	}

	struct Dependency {}
	
	private var sections: [BaseTableSectionItem] = []

	// MARK: - Rows

	func sectionsCount() -> Int {
		return sections.count
	}

	func rowsCount(for section: Int) -> Int {
		return sections[safe: section]?.items.count ?? 0
	}

	func cellItem(section: Int, row: Int) -> BaseCellItem? {
		return sections[safe: section]?.items[safe: row]
	}

	func section(index: Int) -> BaseTableSectionItem? {
		return sections[safe: index]
	}

}

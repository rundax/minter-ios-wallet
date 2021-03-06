//
//  GiftsViewController.swift
//  MinterWallet
//
//  Created by Roman Slysh on 25/02/2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import UIKit
import RxSwift
import RxAppState
import RxDataSources
import NotificationBannerSwift
import Photos
import MinterMy

class GiftsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
	
	var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>?

	// MARK: - IBOutput

	@IBOutlet weak var tableView: UITableView! {
		didSet {
			tableView?.tableFooterView = UIView()
			tableView.rowHeight = UITableViewAutomaticDimension
			tableView.estimatedRowHeight = 54.0
		}
	}

	// MARK: - ControllerType

	private var disposeBag = DisposeBag()


	// MARK: -

	var viewModel = GiftsViewModel()

	typealias ViewModelType = GiftsViewModel

	func configure(with viewModel: GiftsViewController.ViewModelType) {
		
	}

	// MARK: Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = viewModel.title

		registerCells()

		configure(with: viewModel)

		rxDataSource = RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>(
			configureCell: { [weak self] dataSource, tableView, indexPath, sm in
			guard
				let item = self?.viewModel.cellItem(section: indexPath.section, row: indexPath.row) else {
					return UITableViewCell()
			}

			guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as? BaseCell else {
				if let cll = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) {
					return cll
				}
				return UITableViewCell()
			}

			cell.configure(item: item)
			return cell
		})

		rxDataSource?.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic,
																																	reloadAnimation: .automatic,
																																	deleteAnimation: .automatic)
		
		tableView.rx.setDelegate(self).disposed(by: disposeBag)
		
		viewModel.accountObservable
			.bind(to: tableView.rx.items(dataSource: rxDataSource!))
			.disposed(by: disposeBag)

		if self.shouldShowTestnetToolbar {
			self.view.addSubview(self.testnetToolbarView)
			self.tableView.contentInset = UIEdgeInsets(top: 55,
																								 left: 0,
																								 bottom: 0,
																								 right: 0)
		} else {
			self.tableView.contentInset = UIEdgeInsets(top: -55,
																								 left: 0,
																								 bottom: 0,
																								 right: 0)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		AnalyticsHelper.defaultAnalytics.track(event: .giftsScreen)
	}

	private func registerCells() {
		tableView.register(UINib(nibName: "SeparatorTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "SeparatorTableViewCell")
		tableView.register(UINib(nibName: "CopyTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "CopyTableViewCell")
		tableView.register(UINib(nibName: "DisclosureTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "DisclosureTableViewCell")
	}

	// MARK: - TableView

	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.sectionsCount()
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.rowsCount(for: section)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		guard let item = self.viewModel.cellItem(section: indexPath.section,
																						 row: indexPath.row),
			let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier,
																							 for: indexPath) as? BaseCell else {
			return UITableViewCell()
		}

		cell.configure(item: item)

		return cell
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let section = viewModel.section(index: section) else {
			return UIView()
		}

		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DefaultHeader")
		if let defaultHeader = header as? DefaultHeader {
			defaultHeader.titleLabel.text = section.header
		}
		return header
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.1
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		guard let item = viewModel.cellItem(section: indexPath.section, row: indexPath.row) else {
			return
		}

//		if item.identifier == "DisclosureTableViewCell_Addresses" {
//			self.performSegue(withIdentifier: GiftsViewController.Segue.showAddress.rawValue, sender: self)
//		}
	}
}

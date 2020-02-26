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
import NotificationBannerSwift
import Photos
import MinterMy

class GiftsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

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

		//self.title = viewModel.title

		registerCells()

		configure(with: viewModel)

		if self.shouldShowTestnetToolbar {
			self.view.addSubview(self.testnetToolbarView)
			self.tableView.contentInset = UIEdgeInsets(top: 55,
																								 left: 0,
																								 bottom: 0,
																								 right: 0)
		} else {
			self.tableView.contentInset = UIEdgeInsets(top: -16,
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
		guard let section = viewModel.section(index: section),
			section.header != "" else {

			return 0.1
		}
		return 52
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

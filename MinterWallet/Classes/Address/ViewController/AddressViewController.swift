//
//  AddressViewController.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 20/04/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import NotificationBannerSwift

class AddressViewController: BaseViewController, UITableViewDelegate {

	let disposeBag = DisposeBag()

	var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>?

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		self.hidesBottomBarWhenPushed = true
	}

	// MARK: - IBOutlet

	@IBOutlet var headerView: UIView!
	@IBOutlet weak var headerViewWrapper: UIView!
	@IBOutlet weak var tableHeaderTitle: UILabel!
	@IBOutlet weak var tableView: UITableView! {
		didSet {
			tableView?.tableFooterView = UIView()
			tableView.rowHeight = UITableViewAutomaticDimension
			tableView.estimatedRowHeight = 54.0
			tableView.tableHeaderView = UIView()
		}
	}
	@IBAction func didTapEditAddresses(_ sender: Any) {
		hardImpactFeedbackGenerator.prepare()
		hardImpactFeedbackGenerator.impactOccurred()
		AnalyticsHelper.defaultAnalytics.track(event: .addressesEditAddressButton)
		tableView.setEditing(!tableView.isEditing, animated: true)
	}

	@IBAction func didTapAddNewButton(_ sender: Any) {
		
		guard let advancedMode = Storyboards.AdvancedMode.storyboard.instantiateInitialViewController() as? AdvancedModeViewController else {
			return
		}
		advancedMode.delegate = self
		
		self.navigationController?.pushViewController(advancedMode, animated: true)
	}

	// MARK: -

	var viewModel = AddressViewModel()

	// MARK: Life cycle

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = viewModel.title

		registerCells()

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

			if let switchCell = cell as? SwitchTableViewCell {
				switchCell.delegate = self
			}
			return cell
		})

		rxDataSource?.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic,
																																	reloadAnimation: .automatic,
																																	deleteAnimation: .automatic)

		rxDataSource?.canEditRowAtIndexPath = { dataSource, indexPath in
			if indexPath.row == 0, indexPath.section != self.viewModel.sectionsCount() - 1 {
				return true
			} else {
				return false
			}
		}
		
		tableView.rx.itemDeleted.subscribe(onNext: { [weak self] (indexPath) in
			self?.hardImpactFeedbackGenerator.prepare()
			self?.hardImpactFeedbackGenerator.impactOccurred()
			AnalyticsHelper.defaultAnalytics.track(event: .addressesDelete)

			let alert = BaseAlertController(title: "Confirm address deletion".localized(), message: "Mx" + (self?.viewModel.account(for: indexPath.row)?.address ?? ""), preferredStyle: .alert)
			let yesAction = UIAlertAction(title: "DELETE".localized(), style: .default) { action in
				if self?.viewModel.removeAccount(index: indexPath.section) ?? true {
					self?.tableView.setEditing(false, animated: true)
				} else {
					let banner = NotificationBanner(title: "Can not delete address".localized(),
																					subtitle: "Try to logout and login again".localized(),
																					style: .danger)
					banner.show()
				}
			}
			let cancelAction = UIAlertAction(title: "CANCEL".localized(), style: .cancel)
			alert.addAction(yesAction)
			alert.addAction(cancelAction)
			alert.view.tintColor = UIColor.mainColor()

			self?.present(alert, animated: true)
		}).disposed(by: disposeBag)

		tableView.rx.setDelegate(self).disposed(by: disposeBag)

		viewModel.accountObservable.bind(to: tableView.rx.items(dataSource: rxDataSource!))
			.disposed(by: disposeBag)

		self.navigationController?.navigationItem.rightBarButtonItem = nil

		tableView.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		AnalyticsHelper.defaultAnalytics.track(event: .addressesScreen)
	}

	// MARK: -

	private func registerCells() {
		tableView.register(UINib(nibName: "CopyTableViewCell", bundle: nil), forCellReuseIdentifier: "CopyTableViewCell")
		tableView.register(UINib(nibName: "SettingsSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsSwitchTableViewCell")
		tableView.register(UINib(nibName: "SeparatorTableViewCell", bundle: nil), forCellReuseIdentifier: "SeparatorTableViewCell")
		tableView.register(UINib(nibName: "DisclosureTableViewCell", bundle: nil), forCellReuseIdentifier: "DisclosureTableViewCell")
		tableView.register(UINib(nibName: "DefaultHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "DefaultHeader")
		tableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil),
				forCellReuseIdentifier: "ButtonTableViewCell")
	}
	
	// MARK: -

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DefaultHeader")
		if let defaultHeader = header as? DefaultHeader {
			if section == 0 {
				defaultHeader.titleLabel.text = "MAIN ADDRESS".localized()
			} else if section == viewModel.sectionsCount() - 1 {
				defaultHeader.titleLabel.text = ""
			} else {
				defaultHeader.titleLabel.text = "ADDRESS #\(section)".localized()
			}
		}
		return header
	}

	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

		if let defaultHeader = view as? DefaultHeader {
			if section == 0 {
				defaultHeader.titleLabel.text = "MAIN ADDRESS".localized()
			} else if section == viewModel.sectionsCount() - 1 {
				defaultHeader.titleLabel.text = ""
			} else {
				defaultHeader.titleLabel.text = "ADDRESS #\(section)".localized()
			}
		}
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == viewModel.sectionsCount() - 1 {
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

		if item.identifier.hasPrefix("DisclosureTableViewCell_Balance") {
			self.performSegue(withIdentifier: AddressViewController.Segue.showBalance.rawValue, sender: indexPath)
		}
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let switchCell = cell as? SettingsSwitchTableViewCell {

			guard let item = self.viewModel.cellItem(section: indexPath.section, row: indexPath.row) as? SwitchTableViewCellItem else {
				return
			}
			switchCell.switch.setOn(item.isOn.value, animated: true)
			switchCell.switch.isEnabled = !item.isOn.value
		}
		
		if let buttonCell = cell as? ButtonTableViewCell {
			buttonCell.delegate = self
			buttonCell.backgroundColor = .clear
		}
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .delete
	}

	// MARK: -

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		if segue.identifier == AddressViewController.Segue.showBalance.rawValue {

			guard let indexPath = sender as? IndexPath,
				let account = viewModel.account(for: indexPath.section) else {
					return
			}

			let address = account.address.stripMinterHexPrefix()

			let vm = TransactionsViewModel(addresses: ["Mx" + address])
			if let vc = segue.destination as? TransactionsViewController {
				vc.viewModel = vm
			}
		}
	}

}

extension AddressViewController : SwitchTableViewCellDelegate {
	
	func didSwitch(isOn: Bool, cell: SwitchTableViewCell) {
		if let ip = tableView.indexPath(for: cell), let cellItem = viewModel.cellItem(section: ip.section, row: ip.row) {
			if isOn {

				// Set switch off for previous main address
				let switchCell = tableView.cellForRow(at: IndexPath(row: 6, section: 0)) as? SwitchTableViewCell
				switchCell?.switch.setOn(false, animated: true)
				switchCell?.switch.isEnabled = true
				(tableView.headerView(forSection: 0) as? DefaultHeader)?.titleLabel.text = "ADDRESS #\(ip.section)".localized()
				
				// Set switch on for current main address
				(self.tableView.headerView(forSection: ip.section) as? DefaultHeader)?.titleLabel.text = "MAIN ADDRESS".localized()
				let newMainSwitchCell = self.tableView.cellForRow(at: ip) as? SwitchTableViewCell
				newMainSwitchCell?.switch.isEnabled = false

				viewModel.setMainAccount(isMain: isOn, cellItem: cellItem)
				tableView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)

				DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
					(self.tableView.headerView(forSection: ip.section) as? DefaultHeader)?.titleLabel.text = "ADDRESS #\(ip.section)".localized()
					self.tableView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)
				}
			}
		}
	}

}

extension AddressViewController: AdvancedModeViewControllerDelegate {

	func advancedModeViewControllerDidAddAccount() {
		self.navigationController?.popToViewController(self, animated: true)
	}

}

extension AddressViewController: ButtonTableViewCellDelegate {
	func buttonTableViewCellDidTap(_ cell: ButtonTableViewCell) {
		if tableView.isEditing {
			tableView.setEditing(false, animated: true)
		}

		hardImpactFeedbackGenerator.prepare()
		hardImpactFeedbackGenerator.impactOccurred()

		AnalyticsHelper.defaultAnalytics.track(event: .addressesAddAddressButton)

		SoundHelper.playSoundIfAllowed(type: .cancel)
		
		tableView.endEditing(true)

		let pairedMode = PickerTableViewCellPickerItem(title: "2FA MODE".localized(), object: "showPairedMode")
		let seedMode = PickerTableViewCellPickerItem(title: "SEED MODE".localized(), object: "showAdvancedMode")
		let items = [pairedMode, seedMode]

		let data: [[String]] = [items.map({ (item) -> String in
			return item.title ?? ""
		})]

		let picker = McPicker(data: data)
		picker.toolbarButtonsColor = .white
		picker.toolbarDoneButtonColor = .white
		picker.toolbarBarTintColor = UIColor.mainColor()
		picker.toolbarItemsFont = UIFont.mediumFont(of: 16.0)
		let label = UILabel()
		label.font = UIFont.boldFont(of: 22)
		label.textAlignment = .center
		picker.label = label
		picker.show { [weak self] (selected) in
			guard let coin = selected[0] else {
				return
			}
			//self?.selectField.text = coin

			if let item = items.filter({ (item) -> Bool in
				return item.title == coin
			}).first {
				self?.performSegue(withIdentifier: item.object as! String, sender: self)
			}
		}
	}
}

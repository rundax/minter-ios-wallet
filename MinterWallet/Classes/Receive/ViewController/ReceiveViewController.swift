//
//  ReceiveReceiveViewController.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 19/04/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import NotificationBannerSwift

class ReceiveViewController: BaseViewController, UITableViewDelegate {

	// MARK: -

	var viewModel = ReceiveViewModel()

	let disposeBag = DisposeBag()
	var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>?

	@IBOutlet weak var addEmailButton: UIButton!

	// MARK: -
	@IBAction func addEmailDidTap(_ sender: Any) {
	}
	
	@IBAction func shareButtonDidTap(_ sender: UIButton) {

		hardImpactFeedbackGenerator.prepare()
		hardImpactFeedbackGenerator.impactOccurred()

		AnalyticsHelper.defaultAnalytics.track(event: .receiveShareButton)

		if let activities = viewModel.activities() {
			let vc = ReceiveRouter.activityViewController(activities: activities,
																										sourceView: sender)
			present(vc, animated: true)
		}
	}

	@IBOutlet var headerView: UIView!
	@IBOutlet var footerView: UIView!

	@IBOutlet weak var tableView: UITableView! {
		didSet {
			tableView.tableHeaderView = self.headerView
			tableView.tableFooterView = self.footerView
		}
	}

	// MARK: Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		registerCells()

		rxDataSource = RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>(
			configureCell: { [weak self] dataSource, tableView, indexPath, sm in
				guard let item = self?.viewModel.cellItem(section: indexPath.section, row: indexPath.row),
					let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as? BaseCell else {
					return UITableViewCell()
				}

				cell.configure(item: item)

				if let qrCell = cell as? QRTableViewCell {
					qrCell.delegate = self
				}

				return cell
		})
		rxDataSource?.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic,
																																	reloadAnimation: .automatic,
																																	deleteAnimation: .automatic)

		tableView.rx.setDelegate(self).disposed(by: disposeBag)

		viewModel.sectionsObservable.bind(to: tableView.rx.items(dataSource: rxDataSource!)).disposed(by: disposeBag)

		if self.shouldShowTestnetToolbar {
			self.tableView.contentInset = UIEdgeInsets(top: 8,
																								 left: 0,
																								 bottom: 0,
																								 right: 0)
			self.view.addSubview(self.testnetToolbarView)
		}

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let cashedRecipient = JSONStorage<Recipient>(storageType: .permanent, filename: Session.shared.accounts.value.first(where: { $0.isMain })?.address ?? "")
		if cashedRecipient.storedValue == nil {
			EmailManager.getRecipient(address: cashedRecipient.filename) { [weak self] recipient in
				if let recipient = recipient {
					JSONStorage<Recipient>(storageType: .permanent, filename: Session.shared.accounts.value.first(where: { $0.isMain })?.address ?? "").save(recipient)
					self?.addEmailButton.setTitle("CHANGE EMAIL".localized(), for: .normal)
				}
				self?.viewModel.createSections()
				self?.tableView.reloadData()
			}
			addEmailButton.setTitle("ATTACH EMAIL".localized(), for: .normal)
		} else {
			addEmailButton.setTitle("CHANGE EMAIL".localized(), for: .normal)
			viewModel.createSections()
			tableView.reloadData()
		}
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		AnalyticsHelper.defaultAnalytics.track(event: .receiveScreen, params: nil)
	}

	// MARK: - TableView

	private func registerCells() {
		tableView.register(UINib(nibName: "AddressTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "AddressTableViewCell")
		tableView.register(UINib(nibName: "SeparatorTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "SeparatorTableViewCell")
		tableView.register(UINib(nibName: "DefaultHeader", bundle: nil),
											 forHeaderFooterViewReuseIdentifier: "DefaultHeader")
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 52
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
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if let item = viewModel.cellItem(section: indexPath.section,
																		 row: indexPath.row) as? ReceiveEmailTableViewCellItem {
			guard let recipient = item.recipient else {
				return 0
			}
			
			if recipient.email == "" {
				return 0
			}
		}
		return UITableViewAutomaticDimension
	}
}

extension ReceiveViewController: QRTableViewCellDelegate {

	func QRTableViewCellDidTapCopy(cell: QRTableViewCell) {
		if let indexPath = tableView.indexPath(for: cell),
			let item = viewModel.cellItem(section: indexPath.section,
																		row: indexPath.row),
			let qrItem = item as? QRTableViewCellItem {

			self.lightImpactFeedbackGenerator.prepare()
			self.lightImpactFeedbackGenerator.impactOccurred()

			guard let str = qrItem.string, let img = QRCode(str)?.image else {
				return
			}

			SoundHelper.playSoundIfAllowed(type: .click)

			UIPasteboard.general.image = img
			let banner = NotificationBanner(title: "Copied".localized(), subtitle: nil, style: .info)
			banner.show()
		}
	}
}

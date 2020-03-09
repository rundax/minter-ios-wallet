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
import RxCocoa
import NotificationBannerSwift

class ReceiveViewController: BaseTableViewController, ControllerType {

  // MARK: - ControllerType

  typealias ViewModelType = ReceiveViewModel

  var viewModel: ReceiveViewModel!

  func configure(with viewModel: ReceiveViewController.ViewModelType) {

    viewModel
      .output
      .showViewController
      .asDriver(onErrorJustReturn: nil)
      .drive(onNext: { [weak self] (viewController) in
        guard let viewController = viewController else { return }
        self?.tabBarController?.present(viewController, animated: true, completion: nil)
      }).disposed(by: disposeBag)
  }

	// MARK: -

	let disposeBag = DisposeBag()
	var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>?

	// MARK: Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		registerCells()

    configure(with: viewModel)

    rxDataSource = RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>(
      configureCell: { [weak self] dataSource, tableView, indexPath, sm in
        guard
          let datasourceItem = try? dataSource.model(at: indexPath) as? BaseCellItem,
          let item = datasourceItem,
          let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as? ConfigurableCell else {
            return UITableViewCell()
        }
        cell.configure(item: item)

				if let accordionCell = cell as? AccordionTableViewCell {
					let isExpanded = self?.expandedIdentifiers
						.contains(accordionCell.identifier) ?? false
					(cell as? ExpandableCell)?.toggle(isExpanded, animated: false)
				}
				
				if let buttonsCell = cell as? AddressButtonsTableViewCell {
					buttonsCell.buttonsDelegate = self
					self?.viewModel.output.isLoadingPass.asDriver(onErrorJustReturn: false).drive(onNext: { (val) in
						buttonsCell.appleWalletButton.isEnabled = !val
						buttonsCell.appleWalletActivityIndicator.alpha = val ? 1.0 : 0.0
						if val {
							buttonsCell.appleWalletActivityIndicator.startAnimating()
						} else {
							buttonsCell.appleWalletActivityIndicator.stopAnimating()
						}
					}).disposed(by: self!.disposeBag)
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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

    setNeedsStatusBarAppearanceUpdate()

		AnalyticsHelper.defaultAnalytics.track(event: .receiveScreen, params: nil)
	}

	// MARK: - TableView

	private func registerCells() {
		tableView.register(UINib(nibName: "CopyTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "CopyTableViewCell")
		tableView.register(UINib(nibName: "SeparatorTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "SeparatorTableViewCell")
		tableView.register(UINib(nibName: "DefaultHeader", bundle: nil),
											 forHeaderFooterViewReuseIdentifier: "DefaultHeader")
		tableView.register(UINib(nibName: "AddressButtonsTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "AddressButtonsTableViewCell")
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
		guard let item = viewModel.cellItem(section: indexPath.section, row: indexPath.row) else {
			return 0.1
		}

		if item.reuseIdentifier == "CopyTableViewCell" {
				return UITableViewAutomaticDimension
		}

		if item.reuseIdentifier == "SeparatorTableViewCell" {
				return 1.0
		}
		
		if !expandedIdentifiers.contains(item.identifier) {
			return 70.0
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

extension ReceiveViewController: AddressButtonsTableViewCellDelegate {
	func didTapQRButton(_ cell: AccordionTableViewCell) {
		if !cell.toggling {
			cell.toggle(!cell.expanded, animated: shouldAnimateCellToggle)
			toggleCell(cell, animated: shouldAnimateCellToggle)
		}
	}
	
	func didTapShareButton(_ cell: AccordionTableViewCell) {
		hardImpactFeedbackGenerator.prepare()
		hardImpactFeedbackGenerator.impactOccurred()

		AnalyticsHelper.defaultAnalytics.track(event: .receiveShareButton)

		let vc = ReceiveRouter.activityViewController(activities: [cell.identifier],
																									sourceView: cell)
		present(vc, animated: true)
	}
	
	func didTapAppleButton(_ cell: AccordionTableViewCell) {
		if let cell = cell as? AddressButtonsTableViewCell {
			viewModel.getPass(cell.identifier)
		}
	}
}

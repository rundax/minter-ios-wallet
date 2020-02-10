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

class ReceiveViewController: BaseViewController, UITableViewDelegate, ControllerType {

  // MARK: - ControllerType

  typealias ViewModelType = ReceiveViewModel

  var viewModel: ReceiveViewModel!

  func configure(with viewModel: ReceiveViewController.ViewModelType) {
		addToWalletButton.rx.tap.asDriver().drive(viewModel.input.didTapAddPass).disposed(by: disposeBag)

    viewModel
      .output
      .showViewController
      .asDriver(onErrorJustReturn: nil)
      .drive(onNext: { [weak self] (viewController) in
        guard let viewController = viewController else { return }
        self?.tabBarController?.present(viewController, animated: true, completion: nil)
      }).disposed(by: disposeBag)

    viewModel.output.isLoadingPass.asDriver(onErrorJustReturn: false).drive(onNext: { [weak self] (val) in
      self?.addToWalletButton.isEnabled = !val
      self?.addWalletActivityIndicator.alpha = val ? 1.0 : 0.0
      if val {
        self?.addWalletActivityIndicator.startAnimating()
      } else {
        self?.addWalletActivityIndicator.stopAnimating()
      }
    }).disposed(by: disposeBag)

    viewModel
      .output
      .shouldShowPass
      .map({ (val) -> Bool in
        return !val
      })
      .asDriver(onErrorJustReturn: false)
      .drive(addToWalletButton.rx.isHidden)
      .disposed(by: disposeBag)
  }

	// MARK: -

	let disposeBag = DisposeBag()
	var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>?
	var popupViewController: PopupViewController?
	weak var delegate: SentPopupViewControllerDelegate?

	@IBOutlet weak var addEmailButton: UIButton!


	// MARK: -
	@IBAction func addEmailDidTap(_ sender: Any) {
		SoundHelper.playSoundIfAllowed(type: .bip)
		hardImpactFeedbackGenerator.prepare()
		hardImpactFeedbackGenerator.impactOccurred()
	}

  @IBOutlet weak var addWalletActivityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var addToWalletButton: DefaultButton!
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

    configure(with: viewModel)

    rxDataSource = RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>(
      configureCell: { dataSource, tableView, indexPath, sm in
        guard
          let datasourceItem = try? dataSource.model(at: indexPath) as? BaseCellItem,
          let item = datasourceItem,
          let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as? ConfigurableCell else {
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
		
		viewModel
		.output
		.popup
		.asDriver(onErrorJustReturn: nil)
		.drive(onNext: { [weak self] (popup) in
			if popup == nil {
				self?.popupViewController?.dismiss(animated: true, completion: nil)
				return
			}

			if let sent = popup as? SentPopupViewController {
				sent.delegate = self
			}

			if let textField = popup as? TextfieldPopupViewController {
				self?.popupViewController = nil
				textField.delegate = self
				textField.popupViewControllerDelegate = self
			}

			if self?.popupViewController == nil {
				self?.showPopup(viewController: popup!)
				self?.popupViewController = popup
			} else {
				self?.showPopup(viewController: popup!,
												inPopupViewController: self!.popupViewController)
			}
		}).disposed(by: disposeBag)
		
		addEmailButton
			.rx
			.tap
			.asDriver()
			.drive(viewModel.input.attachEmailButtonDidTap)
			.disposed(by: disposeBag)

		if self.shouldShowTestnetToolbar {
			self.tableView.contentInset = UIEdgeInsets(top: 40,
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

    setNeedsStatusBarAppearanceUpdate()

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

extension ReceiveViewController: SentPopupViewControllerDelegate {
	// MARK: - SentPopupViewControllerDelegate

	func didTapActionButton(viewController: SentPopupViewController) {
		SoundHelper.playSoundIfAllowed(type: .click)
		hardImpactFeedbackGenerator.prepare()
		hardImpactFeedbackGenerator.impactOccurred()
		AnalyticsHelper.defaultAnalytics.track(event: .sentCoinPopupViewTransactionButton)
		viewController.dismiss(animated: true) { [weak self] in
			if let url = self?.viewModel.lastTransactionExplorerURL() {
				let vc = BaseSafariViewController(url: url)
				self?.present(vc, animated: true) {}
			}
		}
	}

	func didTapSecondActionButton(viewController: SentPopupViewController) {
		SoundHelper.playSoundIfAllowed(type: .click)
		lightImpactFeedbackGenerator.prepare()
		lightImpactFeedbackGenerator.impactOccurred()
		AnalyticsHelper.defaultAnalytics.track(event: .sentCoinPopupShareTransactionButton)
		viewController.dismiss(animated: true) { [weak self] in
			if let url = self?.viewModel.lastTransactionExplorerURL() {
				let vc = ActivityRouter.activityViewController(activities: [url], sourceView: self!.view)
				self?.present(vc, animated: true, completion: nil)
			}
		}
	}

	func didTapSecondButton(viewController: SentPopupViewController) {
		SoundHelper.playSoundIfAllowed(type: .cancel)
		lightImpactFeedbackGenerator.prepare()
		AnalyticsHelper.defaultAnalytics.track(event: .sentCoinPopupCloseButton)
		viewController.dismiss(animated: true, completion: nil)
	}
}

extension ReceiveViewController: TextfieldPopupViewControllerDelegate {
	func didFinish(viewController: TextfieldPopupViewController) {
		
	}
	
	func didCancel(viewController: TextfieldPopupViewController) {
		SoundHelper.playSoundIfAllowed(type: .cancel)
//		AnalyticsHelper.defaultAnalytics.track(event: .sendCoinPopupCancelButton)
		viewController.dismiss(animated: true, completion: nil)
	}
}

extension ReceiveViewController: PopupViewControllerDelegate {
	func didDismissPopup(viewController: PopupViewController?) {
		self.viewModel.clear()
		viewController?.dismiss(animated: true, completion: nil)
	}
}

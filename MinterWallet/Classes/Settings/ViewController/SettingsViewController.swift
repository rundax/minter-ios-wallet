//
//  SettingsSettingsViewController.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 19/04/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit
import RxSwift
import RxAppState
import NotificationBannerSwift
import Photos
import MinterMy

class SettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ControllerType {

	// MARK: - IBOutput

	@IBOutlet weak var tableView: UITableView! {
		didSet {
			tableView?.tableFooterView = UIView()
			tableView.rowHeight = UITableViewAutomaticDimension
			tableView.estimatedRowHeight = 54.0
		}
	}
	@IBOutlet var bottomView: UIView!
	@IBOutlet weak var infoLabel: UILabel!

	// MARK: - ControllerType

	private var disposeBag = DisposeBag()

	private var shouldPresentSetPIN = false

	// MARK: -

	var viewModel: SettingsViewModel!

	typealias ViewModelType = SettingsViewModel

	func configure(with viewModel: SettingsViewController.ViewModelType) {

		viewModel.output.showPINController.asDriver(onErrorJustReturn: ("", ""))
			.drive(onNext: { [weak self] (val) in
			guard let vc = self?.PINViewController(title: val.0, desc: val.1) else {
				return
			}
			self?.navigationController?.pushViewController(vc, animated: true)
		}).disposed(by: disposeBag)

		viewModel.output.showConfirmPINController.asDriver(onErrorJustReturn: ("", ""))
			.drive(onNext: { [weak self] (val) in
				guard let vc = self?.PINViewController(title: val.0, desc: val.1) else {
					return
				}
				self?.navigationController?.setViewControllers([self!, vc], animated: true)
			}).disposed(by: disposeBag)

		viewModel.output.hidePINController.asDriver(onErrorJustReturn: ())
			.drive(onNext: { [weak self] (_) in
			self?.navigationController?.popToRootViewController(animated: true)
		}).disposed(by: disposeBag)

		viewModel.output.shakePINError.asDriver(onErrorJustReturn: ())
			.drive(onNext: { [weak self] (_) in
				(self?.navigationController?.viewControllers.first(where: { (vc) -> Bool in
					return nil != vc as? PINViewController
				}) as? PINViewController)?.shakeError()
		}).disposed(by: disposeBag)
	}

	// MARK: Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = viewModel.title

		registerCells()

		configure(with: viewModel)

		//move to VM
		Session.shared.isLoggedIn.asObservable().subscribe(onNext: { [weak self] (isLoggedIn) in
			if let button = self?.navigationItem.rightBarButtonItem?.customView as? UIButton {
				button.setTitle(self?.viewModel.rightButtonTitle, for: .normal)
			}
		}).disposed(by: disposeBag)

		viewModel.showLoginScreen.asObservable().filter({ (val) -> Bool in
			return val == true
		}).subscribe(onNext: { (show) in
			let login = Storyboards.Login.instantiateInitialViewController()
			self.present(UINavigationController(rootViewController: login), animated: true, completion: nil)
		}).disposed(by: disposeBag)

		viewModel.shouldReloadTable.asObservable().filter({ (val) -> Bool in
			return val == true
		}).subscribe(onNext: { [weak self] (val) in
			self?.tableView.reloadData()
		}).disposed(by: disposeBag)

		viewModel.errorNotification.asObservable().filter({ (notification) -> Bool in
			return nil != notification
		}).subscribe(onNext: { (notification) in
			let banner = NotificationBanner(title: notification?.title ?? "", subtitle: notification?.text, style: .danger)
			banner.show()
		}).disposed(by: disposeBag)

		viewModel.successMessage.asObservable().filter({ (notification) -> Bool in
			return nil != notification
		}).subscribe(onNext: { (notification) in
			let banner = NotificationBanner(title: notification?.title ?? "", subtitle: notification?.text, style: .success)
			banner.show()
		}).disposed(by: disposeBag)
		tableView.tableFooterView = bottomView

		if let appDele = UIApplication.realAppDelegate(), appDele.isTestnet {
			if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
				let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
				infoLabel.text = "Version: \(version) (\(build))"
			}
		}

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

		viewModel.viewWillAppear()
		AnalyticsHelper.defaultAnalytics.track(event: .settingsScreen)
	}

	private func registerCells() {
		tableView.register(UINib(nibName: "SeparatorTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "SeparatorTableViewCell")
		tableView.register(UINib(nibName: "DisclosureTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "DisclosureTableViewCell")
		tableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "ButtonTableViewCell")
		tableView.register(UINib(nibName: "BlankTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "BlankTableViewCell")
		tableView.register(UINib(nibName: "SettingsSwitchTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "SwitchTableViewCell")
		tableView.register(UINib(nibName: "DefaultHeader", bundle: nil),
											 forHeaderFooterViewReuseIdentifier: "DefaultHeader")
		tableView.register(UINib(nibName: "PickerTableViewCell", bundle: nil),
											 forCellReuseIdentifier: "PickerTableViewCell")
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
		
		if let pickerCell = cell as? PickerTableViewCell {
			pickerCell.dataSource = self
			pickerCell.delegate = self
			pickerCell.updateRightViewMode()
		}

		if let buttonCell = cell as? ButtonTableViewCell {
			buttonCell.delegate = self
			buttonCell.backgroundColor = .clear
		}

		if let switchCell = cell as? SwitchTableViewCell {
			switchCell.delegate = self
		}

		let avatarCell = cell as? SettingsAvatarTableViewCell
		avatarCell?.delegate = self

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

		if item.identifier == "DisclosureTableViewCell_Addresses" {
			self.performSegue(withIdentifier: SettingsViewController.Segue.showAddress.rawValue, sender: self)
		} else if item.identifier == "DisclosureTableViewCell_Username" {
			self.performSegue(withIdentifier: SettingsViewController.Segue.showUsername.rawValue, sender: self)
		} else if item.identifier == "DisclosureTableViewCell_Email" {
			self.performSegue(withIdentifier: SettingsViewController.Segue.showEmail.rawValue, sender: self)
		} else if item.identifier == "DisclosureTableViewCell_Password" {
			self.performSegue(withIdentifier: SettingsViewController.Segue.showPassword.rawValue, sender: self)
		} else if item.identifier == "DisclosureTableViewCell_ChangePIN" {
			viewModel.settingPIN = true
			self.performSegue(withIdentifier: SettingsViewController.Segue.showPIN.rawValue, sender: self)
		} else if item.identifier == "DisclosureTableViewCell_Gifts" {
			self.performSegue(withIdentifier: SettingsViewController.Segue.showGifts.rawValue, sender: self)
		}
	}

	// MARK: - ImagePicker

	func showImagePicker(sender: UIView?) {
		let imagePickerController = BaseImagePickerController()
		imagePickerController.delegate = self
		imagePickerController.mediaTypes = ["public.image"]
		let actionSheet = BaseAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		actionSheet.modalPresentationStyle = .overCurrentContext
		if let popoverPresentationController = actionSheet.popoverPresentationController {
			popoverPresentationController.sourceView = sender
			popoverPresentationController.sourceRect = sender?.bounds ?? CGRect.zero
		}

		actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action:UIAlertAction) in
			if UIImagePickerController.isSourceTypeAvailable(.camera) {
				imagePickerController.sourceType = .camera
				self.present(imagePickerController, animated: true, completion: nil)
			} else {
//				self.showAlert(withTitle: "Missing camera", andMessage: "You can't take photo, there is no camera.")
			}
		}))
		actionSheet.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { (action:UIAlertAction) in
			imagePickerController.sourceType = .photoLibrary
			self.present(imagePickerController, animated: true, completion: nil)
		}))
		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(actionSheet, animated: true, completion: nil)
	}
}

extension SettingsViewController: SettingsAvatarTableViewCellDelegate {

	func didTapChangeAvatar(cell: SettingsAvatarTableViewCell) {
		AnalyticsHelper.defaultAnalytics.track(event: .settingsChangeUserpicButton)

    guard PHPhotoLibrary.authorizationStatus() == .authorized else {
      PHPhotoLibrary.requestAuthorization { (status) in
        switch status {
        case .authorized:
          DispatchQueue.main.async {
            self.showImagePicker(sender: cell)
          }
        case .denied:
          DispatchQueue.main.async {
            self.openAppSpecificSettings()
          }
        default:
          DispatchQueue.main.async {
            BannerHelper.performErrorNotification(title: "Can't access photo library", subtitle: nil)
          }
        }
      }
      return
    }
    
    DispatchQueue.main.async {
      self.showImagePicker(sender: cell)
    }
	}
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		let mediaType = info["UIImagePickerControllerMediaType"] as? String ?? ""
		switch mediaType {
		case "public.movie":
			picker.dismiss(animated: true, completion: nil)

		case "public.image":
			if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
				self.viewModel.updateAvatar(image)
			}
			picker.dismiss(animated: true, completion: nil)

		default:
			picker.dismiss(animated: true, completion: nil)
			return
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

extension SettingsViewController: ButtonTableViewCellDelegate {

	func buttonTableViewCellDidTap(_ cell: ButtonTableViewCell) {
		hardImpactFeedbackGenerator.prepare()
		hardImpactFeedbackGenerator.impactOccurred()

		AnalyticsHelper.defaultAnalytics.track(event: .settingsLogoutButton)

		SoundHelper.playSoundIfAllowed(type: .cancel)
		
		if let indexPath = tableView.indexPath(for: cell),
		let item = viewModel.cellItem(section: indexPath.section, row: indexPath.row) {
			if item.identifier == "ButtonTableViewCell_Account" {
				tableView.endEditing(true)
				// AnalyticsHelper.defaultAnalytics.track(event: .sendCoinsChooseCoinButton)

				let seedMode = PickerTableViewCellPickerItem(title: "SEED MODE".localized(), object: "showAdvancedMode")
				let pairedMode = PickerTableViewCellPickerItem(title: "PAIRED MODE".localized(), object: "showPairedMode")
				let items = [seedMode, pairedMode]

				let data: [[String]] = [items.map({ (item) -> String in
					return item.title ?? ""
				})]

				let picker = McPicker(data: data)
				picker.toolbarButtonsColor = .white
				picker.toolbarDoneButtonColor = .white
				picker.toolbarBarTintColor = UIColor(hex: 0x4225A4)
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
			} else {
				// log out
				viewModel.rightButtonTapped()
			}
		}
	}
}

extension SettingsViewController: SwitchTableViewCellDelegate {

	func didSwitch(isOn: Bool, cell: SwitchTableViewCell) {
		if let indexPath = tableView.indexPath(for: cell),
			let item = viewModel.cellItem(section: indexPath.section, row: indexPath.row) {
			if item.identifier == "SwitchTableViewCell_Biometrics" {
				viewModel.didSwitchBiometrics(isOn: isOn)
				if viewModel.shouldInstallPIN {
					performSegue(withIdentifier: SettingsViewController.Segue.showPIN.rawValue, sender: nil)
				}
			} else if item.identifier == "SwitchTableViewCell_Pin" {
				shouldPresentSetPIN = isOn
				performSegue(withIdentifier: SettingsViewController.Segue.showPIN.rawValue, sender: nil)
			} else {
				viewModel.didSwitchSound(isOn: isOn)
			}
		}
	}
}

extension SettingsViewController {

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		if let pinVC = segue.destination as? PINViewController {
			pinVC.viewModel = viewModel.pinViewModel()
			pinVC.delegate = self
		}

		if segue.identifier == SettingsViewController.Segue.showPIN.identifier,
			let pinVC = segue.destination as? PINViewController {
			pinVC.viewModel = viewModel.pinViewModel()
			pinVC.delegate = self
		}
	}
}

extension SettingsViewController: PINViewControllerDelegate {

	func PINViewControllerDidSucceed(controller: PINViewController, withPIN: String) {
		viewModel.input.pin.onNext(withPIN)
	}

	func PINViewControllerDidSucceedWithBiometrics(controller: PINViewController) {}

	// MARK: -

	func PINViewController(title: String, desc: String) -> PINViewController? {
		let viewModel = PINViewModel()
		viewModel.title = title
		viewModel.desc = desc
		let pinVC = PINRouter.PINViewController(with: viewModel)
		pinVC?.delegate = self
		return pinVC
	}
}

extension SettingsViewController: PickerTableViewCellDelegate {

	func didFinish(with item: PickerTableViewCellPickerItem?) {
		
		let accounts = Session.shared.accounts.value.map({ (account) -> Account in
			var acc = account
			acc.isMain = false
			if account.address == (item?.object as? Account)?.address {
				AccountManager().setMain(isMain: true, account: &acc)
			}
			return acc
		})
		Session.shared.accounts.accept(accounts)
	}

	func willShowPicker() {
		tableView.endEditing(true)
		AnalyticsHelper.defaultAnalytics.track(event: .sendCoinsChooseCoinButton)
	}
}

extension SettingsViewController: PickerTableViewCellDataSource {
	func pickerItems(for cell: PickerTableViewCell) -> [PickerTableViewCellPickerItem] {
		return viewModel.getAccountItems()
	}
}

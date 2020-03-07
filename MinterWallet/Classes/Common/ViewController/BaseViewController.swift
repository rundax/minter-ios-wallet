//
//  BaseViewController.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 02/04/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa
import NotificationBannerSwift
import Reachability
import RxAppState
import SwiftOTP

protocol ControllerType: class {
	var viewModel: ViewModelType! { get set }

	associatedtype ViewModelType: ViewModelProtocol
	/// Configurates controller with specified ViewModelProtocol subclass
	///
	/// - Parameter viewModel: CPViewModel subclass instance to configure with
	func configure(with viewModel: ViewModelType)
}

class BaseViewController: UIViewController, UIImpactFeedbackProtocol {

	let hardImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
	let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.setNeedsStatusBarAppearanceUpdate()
	}
}

class BaseTableViewController: AccordionTableViewController, UIImpactFeedbackProtocol {

	let hardImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
	let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.setNeedsStatusBarAppearanceUpdate()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.setNeedsStatusBarAppearanceUpdate()
	}
}

class BaseImagePickerController: UIImagePickerController {

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.setNeedsStatusBarAppearanceUpdate()
	}
}

class BaseSafariViewController: SFSafariViewController {

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		preferredBarTintColor = UIColor.mainColor()
    preferredControlTintColor = UIColor.mainOrangeColor()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.setNeedsStatusBarAppearanceUpdate()
	}
}

class BaseAlertController: UIAlertController {

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.setNeedsStatusBarAppearanceUpdate()
	}
	
	static func show2FAConfirmVC(_ secretCode: String, vc: UIViewController? = nil, completion: @escaping (Bool) -> ()) {
		let alert = BaseAlertController(title: "Enter 6 digit code".localized(), message: nil, preferredStyle: .alert)
		let yesAction = UIAlertAction(title: "OK".localized(), style: .default) { action in
			let firstTextField = alert.textFields![0] as UITextField
			guard let data = base32DecodeToData(secretCode) else {
				completion(false)
				return
			}

			guard let totp = TOTP(secret: data, digits: 6, timeInterval: 30, algorithm: .sha1) else {
				completion(false)
				return
			}
			let otpString = totp.generate(time: Date())

			if otpString == firstTextField.text {
				completion(true)
			} else {
				completion(false)
			}
		}
		let cancelAction = UIAlertAction(title: "CANCEL".localized(), style: .cancel)
		alert.addTextField(configurationHandler: { (textField) in
			textField.placeholder = "Enter 6 digit code".localized()
			textField.keyboardType = .numberPad
			textField.maxLength = 6
		})
		alert.addAction(yesAction)
		alert.addAction(cancelAction)
		alert.view.tintColor = UIColor.mainColor()

		if let vc = vc {
			vc.present(alert, animated: true)
		} else if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			topController.present(alert, animated: true)
		}
	}
}

protocol TestnetToolbarProtocol where Self: UIViewController {
	var testnetToolbarView: UIView { get }
	var shouldShowTestnetToolbar: Bool { get }
	func didTapTestnetToolbar()
}

extension UIViewController: TestnetToolbarProtocol {

	var shouldShowTestnetToolbar: Bool {
		if let appDele = UIApplication.realAppDelegate() {
			return appDele.isTestnet
		}
		return false
	}

	var testnetToolbarView: UIView {
		let bottomView = UIView(frame: CGRect(x: 0,
																					y: 55.0,
																					width: view.bounds.width,
																					height: 1.0))
		bottomView.backgroundColor = UIColor(red: 189/255,
																				 green: 26/255,
																				 blue: 26/255,
																				 alpha: 1.0)

		let toolbarView = UIView(frame: CGRect(x: 0,
																					 y: 0,
																					 width: view.bounds.width,
																					 height: 56.0))
		toolbarView.backgroundColor = UIColor(red: 241/255,
																					green: 60/255,
																					blue: 60/255,
																					alpha: 1.0)
		toolbarView.addSubview(bottomView)

		let label = UILabel(frame: CGRect(x: 16.0,
																			y: 12.0,
																			width: 120.0,
																			height: 32.0))
		label.text = "THIS IS A TESTNET.\nNOT REAL MONEY!"
		label.font = UIFont.mediumFont(of: 12.0)
		label.textColor = .white
		label.numberOfLines = 0
		toolbarView.addSubview(label)

		let button = UIButton(frame: CGRect(x: view.bounds.width - 160 - 16,
																				y: 18.0,
																				width: 160.0,
																				height: 16.0))
		button.setAttributedTitle(NSAttributedString(string: "Download Mainnet App".uppercased().localized(),
																								 attributes: [
																									NSAttributedStringKey.font: UIFont.mediumFont(of: 12.0),
																									NSAttributedStringKey.foregroundColor: UIColor.white,
																									NSAttributedStringKey.underlineStyle: 1]),
															for: .normal)
		button.isUserInteractionEnabled = false
		button.setTitleColor(.white,
												 for: .normal)
		button.titleLabel?.font = UIFont.mediumFont(of: 12.0)
		toolbarView.addSubview(button)

		let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTestnetToolbar))
		toolbarView.addGestureRecognizer(tap)
		return toolbarView
	}

	// MARK: -

	@objc func didTapTestnetToolbar() {
		let conf = Configuration()
		if let url = URL(string: conf.environment.appstoreURLString) {
			UIApplication.shared.open(url, options: [:]) { (res) in}
		}
	}
}

extension UIViewController {

	func showPopup(viewController: PopupViewController,
								 inPopupViewController: PopupViewController? = nil,
								 inTabbar: Bool = true) {

		if nil != inPopupViewController {
			guard let currentViewController = (inPopupViewController?
				.childViewControllers.last as? PopupViewController) ?? inPopupViewController else {
				return
			}
			currentViewController.addChildViewController(viewController)
			viewController.willMove(toParentViewController: currentViewController)
			currentViewController.didMove(toParentViewController: viewController)
			currentViewController.view.addSubview(viewController.view)
			viewController.view.alpha = 0.0
			viewController.blurView.effect = nil

			guard let popupView = viewController.popupView else {
				return
			}
			popupView.frame = CGRect(x: currentViewController.view.frame.width,
															 y: popupView.frame.origin.y,
															 width: popupView.frame.width,
															 height: popupView.frame.height)
			popupView.center = CGPoint(x: popupView.center.x,
																 y: currentViewController.view.center.y)
			UIView.animate(withDuration: 0.4,
										 delay: 0,
										 options: .curveEaseInOut,
										 animations: {
				currentViewController.popupView.frame = CGRect(x: -currentViewController.popupView.frame.width,
																											 y: currentViewController.popupView.frame.origin.y,
																											 width: currentViewController.popupView.frame.width,
																											 height: currentViewController.popupView.frame.height)
				popupView.center = currentViewController.view.center
				viewController.view.alpha = 1.0
				currentViewController.popupView.alpha = 0.0
			})
			return
		}
		viewController.modalPresentationStyle = .overFullScreen
		viewController.modalTransitionStyle = .crossDissolve
		if !inTabbar {
			self.present(viewController, animated: true, completion: nil)
		} else {
			self.tabBarController?.present(viewController, animated: true, completion: nil)
		}
	}
}

extension UIViewController {

  @objc func openAppSpecificSettings() {
    guard let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) else {
            return
    }

    let optionsKeyDictionary = [UIApplication.OpenExternalURLOptionsKey(string: "universalLinksOnly"): NSNumber(value: true)]
    UIApplication.shared.open(url, options: optionsKeyDictionary as [String: Any], completionHandler: nil)
  }

}

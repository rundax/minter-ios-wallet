//
//  HomeViewController.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 28/04/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit
import SafariServices
import RxAppState

class HomeViewController: BaseViewController {

	@IBOutlet weak var pairedModeButton: DefaultButton!
	@IBOutlet weak var signInButton: DefaultButton!
	@IBOutlet weak var helpLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var helpFakeLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var helpButton: DefaultButton!

	//MARK: Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		if let appDele = UIApplication.realAppDelegate() {
			if !(appDele.isTestnet) {
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
					self.signInButton.alpha = 0.0
					//self.createWalletButton.alpha = 0.0
					self.helpLeadingConstraint.isActive = false
					self.helpFakeLeadingConstraint.isActive = true
					self.view.setNeedsUpdateConstraints()
					self.view.updateConstraintsIfNeeded()
				}
			}
		}

		if self.shouldShowTestnetToolbar {
			let statusBarHeight = UIApplication.shared.statusBarFrame.height

			let toolbar = self.testnetToolbarView
			toolbar.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview(toolbar)
			
			let underview = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: statusBarHeight))
			underview.translatesAutoresizingMaskIntoConstraints = false
			underview.backgroundColor = UIColor(red: 241/255,
																					green: 60/255,
																					blue: 60/255,
																					alpha: 1.0)
			self.view.addSubview(underview)

			self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[underview(height)]-0-[toolbar(toolbarHeight)]",
																															options: [],
																															metrics: ["height": statusBarHeight,
																																				"toolbarHeight": toolbar.bounds.height],
																															views: ["toolbar": toolbar,
																																			"underview": underview
				]))

			self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolbar]-0-|",
																															options: [],
																															metrics: nil,
																															views: ["toolbar": toolbar]))

			self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[underview]-0-|",
																															options: [],
																															metrics: nil,
																															views: ["underview": underview]))
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	@IBAction func didTapHelpButton(_ sender: Any) {
		//TODO: Move somewhere
		let url = URL(string: "https://help.minter.network")!
		let vc = BaseSafariViewController(url: url)
		self.present(vc, animated: true, completion: nil)
	}

	// MARK: -

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		if segue.identifier == "showAdvanced" {
			if let advanced = segue.destination as? AdvancedModeViewController {
				advanced.delegate = self
			}
		}
	}
}

extension HomeViewController: AdvancedModeViewControllerDelegate {

	func advancedModeViewControllerDidAddAccount() {
		if let rootVC = UIViewController.stars_topMostController() as? RootViewController {
			let vc = Storyboards.Main.instantiateInitialViewController()
			rootVC.showViewControllerWith(vc, usingAnimation: .up) {}
		}
	}
}

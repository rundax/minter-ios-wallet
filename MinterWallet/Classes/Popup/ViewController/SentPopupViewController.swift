//
//  SentViewController.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 30/05/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit
import AlamofireImage

protocol SentPopupViewControllerDelegate: class {
	func didTapActionButton(viewController: SentPopupViewController)
	func didTapSecondActionButton(viewController: SentPopupViewController)
	func didTapSecondButton(viewController: SentPopupViewController)
}

class SentPopupViewController: PopupViewController, ControllerType {

	// MARK: -

	typealias ViewModelType = SentPopupViewModel
	var viewModel: SentPopupViewModel!
	func configure(with viewModel: SentPopupViewModel) {
		
	}

	weak var delegate: SentPopupViewControllerDelegate?

	// MARK: -

	@IBOutlet weak var avatarImageViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var descTitle: UILabel!
	@IBOutlet weak var receiverLabel: UILabel!
	@IBOutlet weak var avatarImageView: UIImageView! {
		didSet {
			avatarImageView?.backgroundColor = .white
			avatarImageView?.makeBorderWithCornerRadius(radius: 25,
																									borderColor: .clear,
																									borderWidth: 4)
		}
	}
	@IBOutlet weak var actionButton: DefaultButton!
	@IBOutlet weak var secondActionButton: DefaultButton!
	@IBOutlet weak var secondButton: DefaultButton!
	@IBOutlet weak var avatarWrapper: UIView! {
		didSet {
			avatarWrapper?.layer.cornerRadius = 25.0
			avatarWrapper?.layer.applySketchShadow(color: UIColor(hex: 0x000000, alpha: 0.2)!,
																						 alpha: 1,
																						 x: 0,
																						 y: 2,
																						 blur: 18,
																						 spread: 0)
		}
	}

	@IBAction func actionBtnDidTap(_ sender: Any) {
		delegate?.didTapActionButton(viewController: self)
	}

	@IBAction func secondButtonDidTap(_ sender: Any) {
		delegate?.didTapSecondButton(viewController: self)
	}

	@IBAction func secondActionButtonDidTap(_ sender: Any) {
		delegate?.didTapSecondActionButton(viewController: self)
	}

	// MARK: -

	var shadowLayer = CAShapeLayer()

	// MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()
		updateUI()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: -

	private func updateUI() {
		guard let vm = viewModel as? SentPopupViewModel else {
			return
		}

		self.title = vm.title
		self.receiverLabel.text = vm.username
		self.avatarImageView.image = UIImage(named: "AvatarPlaceholderImage")
		if let url = vm.avatarImageURL {
			self.avatarImageView.af_setImage(withURL: url, filter: RoundedCornersFilter(radius: 25.0))
		} else if let img = vm.avatarImage {
			self.avatarImageView.image = img
		}
		if vm.noAvatar == true {
			self.avatarImageViewHeightConstraint.constant = 0.0
			self.avatarImageView.isHidden = true
			self.avatarWrapper.isHidden = true
		}
		if let desc = vm.desc {
			descTitle.text = desc
		}
		self.actionButton.setTitle(vm.actionButtonTitle, for: .normal)
		self.secondActionButton.setTitle(vm.secondActionButtomTitle, for: .normal)
		self.secondButton.setTitle(vm.secondButtonTitle, for: .normal)
	}

	func dropShadow() {
		shadowLayer.removeFromSuperlayer()
		shadowLayer.frame = avatarImageView.frame
		shadowLayer.path = UIBezierPath(roundedRect: avatarImageView.bounds, cornerRadius: 25.0).cgPath
		shadowLayer.shadowOpacity = 1.0
		shadowLayer.shadowRadius = 18.0
		shadowLayer.masksToBounds = false
		shadowLayer.shadowColor = UIColor(hex: 0x000000, alpha: 0.2)?.cgColor
		shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
		shadowLayer.opacity = 1.0
		shadowLayer.shouldRasterize = true
		shadowLayer.rasterizationScale = UIScreen.main.scale
		avatarImageView.superview?.layer.insertSublayer(shadowLayer, at: 0)
	}

	// MARK: -

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}
}

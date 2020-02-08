//
//  TextfieldPopupViewController.swift
//  MinterWallet
//
//  Created by Roman Slysh on 28.01.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift
import RxCocoa

protocol TextfieldPopupViewControllerDelegate: class {
	func didFinish(viewController: TextfieldPopupViewController)
	func didCancel(viewController: TextfieldPopupViewController)
}

class TextfieldPopupViewController: PopupViewController, ControllerType {
	
	enum State {
		case `default`
		case valid
		case invalid(error: String)
	}
	
	// MARK: -
	typealias ViewModelType = TextFieldPopupViewModel
	var viewModel: TextFieldPopupViewModel!
	
	func configure(with viewModel: TextFieldPopupViewModel) {
		
		textField
			.rx
			.text
			.subscribe(viewModel.input.textFieldText)
			.disposed(by: self.disposeBag)
		
		viewModel
			.output
			.textFieldDidChangeState
			.asDriver(onErrorJustReturn: .default)
			.drive(onNext: { [weak self] state in
				switch state {
				case .default:
					self?.emailTitleLabel.text = self?.viewModel?.title
					self?.emailTitleLabel.textColor = UIColor.black
					self?.textField.setDefault()
					self?.actionButton.isEnabled = false
				case .valid:
					self?.emailTitleLabel.text = self?.viewModel?.title
					self?.emailTitleLabel.textColor = UIColor(hex: 0x4DAC4A)
					self?.textField.setValid()
					self?.actionButton.isEnabled = true
				case .invalid(let error):
					self?.emailTitleLabel.text = error
					self?.emailTitleLabel.textColor = UIColor.mainRedColor()
					self?.textField.setInvalid()
					self?.actionButton.isEnabled = false
				case .none:
					self?.emailTitleLabel.text = self?.viewModel.title
					self?.emailTitleLabel.textColor = UIColor.mainRedColor()
					self?.textField.setInvalid()
					self?.actionButton.isEnabled = false
				}
			}).disposed(by: disposeBag)
		
		viewModel
			.output
			.isActivityIndicatorAnimating
			.asDriver(onErrorJustReturn: false)
			.drive(onNext: { [weak self] (val) in
				self?.actionButton.isEnabled = !val
				self?.actionButtonActivityIndicator.alpha = val ? 1.0 : 0.0
				if val {
					self?.actionButtonActivityIndicator.startAnimating()
				} else {
					self?.actionButtonActivityIndicator.stopAnimating()
				}
			}).disposed(by: disposeBag)
		
		// Input
		actionButton
			.rx
			.tap
			.asDriver(onErrorJustReturn: ())
			.drive(viewModel.input.didTapAction)
			.disposed(by: disposeBag)
		
		cancelButton
			.rx
			.tap
			.asDriver(onErrorJustReturn: ())
			.drive(viewModel.input.didTapCancel)
			.disposed(by: disposeBag)
	}

	// MARK: -

	weak var delegate: TextfieldPopupViewControllerDelegate?
	lazy var tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(endEditing))

	// MARK: - IBOutlet

	@IBOutlet weak var textField: ValidatableTextField! {
		didSet {
			setAppearance(for: textField)
		}
	}
	@IBOutlet weak var emailTitleLabel: UILabel!
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var actionButton: DefaultButton!
	@IBOutlet weak var cancelButton: DefaultButton!
	@IBOutlet weak var actionButtonActivityIndicator: UIActivityIndicatorView!
	@IBAction func secondButtonDidTap(_ sender: UIButton) {
		self.delegate?.didCancel(viewController: self)
	}
	
	@IBAction func didTapActionButton(_ sender: UIButton) {
		actionButtonActivityIndicator?.startAnimating()
		actionButtonActivityIndicator?.alpha = 1.0
		sender.isEnabled = false
		self.delegate?.didFinish(viewController: self)
	}
	// MARK: -

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		hidesBottomBarWhenPushed = true
	}

	// MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateUI()
		textField.delegate = self
		
		configure(with: viewModel)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: -
	
	@objc private func endEditing() {
		view.endEditing(true)
	}

	private func updateUI() {
		popupTitle.text = viewModel?.popupTitle
		emailTitleLabel.text = viewModel?.title
		textField.text = viewModel?.text
		textField.hideImages()
		addressLabel.text = viewModel?.addressTitle
		amountLabel.text = (viewModel?.amountTitle ?? "10") + " " + (viewModel?.emailFeeCurrencyTitle ?? "BIP")
		actionButton.setTitle(viewModel?.buttonTitle ?? "", for: .normal)
		cancelButton.setTitle(viewModel?.cancelTitle ?? "", for: .normal)
	}
	
	func toggleTextFieldBorder(textField: UITextField?) {
		if textField?.isEditing == true {
			textField?.layer.borderColor = UIColor.mainColor().cgColor
		} else {
			textField?.layer.borderColor = UIColor.mainGreyColor(alpha: 0.4).cgColor
		}
	}

	func setAppearance(for textField: UITextField) {
		textField.layer.cornerRadius = 8.0
		textField.layer.borderWidth = 2
		textField.layer.borderColor = UIColor.mainGreyColor(alpha: 0.4).cgColor
		textField.rx.controlEvent([.editingDidBegin, .editingDidEnd])
			.asObservable()
			.subscribe(onNext: { [weak self] state in
				self?.toggleTextFieldBorder(textField: textField)
			}).disposed(by: disposeBag)
	}
}

extension TextfieldPopupViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		view.addGestureRecognizer(tapRecognizer)
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		view.gestureRecognizers?.removeLast()
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
	}
}

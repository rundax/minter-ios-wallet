//
//  SpendCoinsViewController.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 17/07/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit
import RxSwift
import XLPagerTabStrip
import NotificationBannerSwift
import TPKeyboardAvoiding

class SpendCoinsViewController: ConvertCoinsViewController,
IndicatorInfoProvider,
UITextFieldDelegate {

	// MARK: -

	private var formatter = CurrencyNumberFormatter.coinFormatter

	// MARK: - IBOutlet

	@IBOutlet weak var useMaxButton: UIButton!
	@IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
	@IBOutlet weak var spendCoinTextField: ValidatableTextField! {
		didSet {
			setAppearance(for: spendCoinTextField)
			let imageView = UIImageView(image: UIImage(named: "textFieldSelectIcon"))
			let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 5.0))
			imageView.frame = CGRect(x: 0.0, y: 22.0, width: 10.0, height: 5.0)
			rightView.addSubview(imageView)
			rightView.isUserInteractionEnabled = false
			spendCoinTextField?.rightView = rightView
			spendCoinTextField?.rightViewMode = .always
		}
	}
	@IBOutlet weak var spendAmountTextField: ValidatableTextField! {
		didSet {
			setAppearance(for: spendAmountTextField)
		}
	}
	@IBOutlet weak var getCoinActivityIndicator: UIActivityIndicatorView!
	@IBAction func didTapExchange(_ sender: Any) {
		SoundHelper.playSoundIfAllowed(type: .bip)
		hardImpactFeedbackGenerator.prepare()
		hardImpactFeedbackGenerator.impactOccurred()
		AnalyticsHelper.defaultAnalytics.track(event: .convertSpendExchangeButton)
	}
	@IBOutlet weak var amountErrorLabel: UILabel!
	@IBOutlet weak var getCoinErrorLabel: UILabel!
	@IBAction func didTapUseMax(_ sender: Any) {
		AnalyticsHelper.defaultAnalytics.track(event: .convertSpendUseMaxButton)
	}

	// MARK: -

	func configure(with viewModel: SpendCoinsViewModel) {
		//Input
		self.spendAmountTextField.rx.text.asObservable()
			.subscribe(viewModel.input.spendAmount)
			.disposed(by: self.disposableBag)

		self.getCoinTextField.rx.text.asObservable()
			.subscribe(viewModel.input.getCoin)
			.disposed(by: self.disposableBag)

		self.spendCoinTextField.rx.text.asObservable()
			.subscribe(viewModel.input.spendCoin)
			.disposed(by: self.disposableBag)

		self.useMaxButton.rx.tap.asObservable()
			.subscribe(viewModel.input.useMaxDidTap)
			.disposed(by: self.disposableBag)

		self.exchangeButton.rx.tap.asObservable()
			.subscribe(viewModel.input.exchangeDidTap)
			.disposed(by: self.disposableBag)

		//Output
		viewModel.output.approximately.asObservable()
			.distinctUntilChanged().subscribe(onNext: { [weak self] (val) in
				self?.approximately.text = val
		}).disposed(by: disposableBag)

		viewModel.output.spendCoin.filter({ (val) -> Bool in
			return val != nil && val != ""
		}).asDriver(onErrorJustReturn: nil).drive(self.spendCoinTextField.rx.text).disposed(by: self.disposableBag)

		viewModel.output.hasMultipleCoinsObserver.asDriver(onErrorJustReturn: false)
			.drive(onNext: { [weak self] (has) in
				self?.spendCoinTextField?.rightViewMode = has ? .always : .never
		}).disposed(by: self.disposableBag)

		viewModel.output.isButtonEnabled.asDriver(onErrorJustReturn: true)
			.drive(onNext: { [weak self] (val) in
				self?.exchangeButton.isEnabled = val
		}).disposed(by: self.disposableBag)

		viewModel.output.isLoading.asDriver(onErrorJustReturn: false)
			.drive(onNext: { [weak self] (val) in
				if val {
					self?.buttonActivityIndicator.startAnimating()
					self?.buttonActivityIndicator.isHidden = false
				} else {
					self?.buttonActivityIndicator.stopAnimating()
					self?.buttonActivityIndicator.isHidden = true
				}
		}).disposed(by: disposableBag)

		viewModel.output.errorNotification.asDriver(onErrorJustReturn: nil)
			.filter({ (notification) -> Bool in
				return notification != nil
		}).drive(onNext: { (notification) in
			let banner = NotificationBanner(title: notification?.title ?? "",
																			subtitle: notification?.text,
																			style: .danger)
			banner.show()
		}).disposed(by: self.disposableBag)

		viewModel.output.shouldClearForm.asObservable().filter({ (val) -> Bool in
			return val
		}).subscribe(onNext: { [weak self] (val) in
			self?.clearForm()
		}).disposed(by: disposableBag)

		viewModel.output.isCoinLoading.distinctUntilChanged()
			.asDriver(onErrorJustReturn: false).drive(onNext: { [weak self] (val) in
			self?.getCoinActivityIndicator.isHidden = !val
			if val {
				self?.getCoinActivityIndicator.startAnimating()
			} else {
				self?.getCoinActivityIndicator.stopAnimating()
			}
		}).disposed(by: disposableBag)

		viewModel.output.amountError.asObservable().subscribe(onNext: { (val) in
			self.amountErrorLabel.text = val
		}).disposed(by: disposableBag)

		viewModel.output.getCoinError.asObservable().subscribe(onNext: { (val) in
			self.getCoinErrorLabel.text = val
		}).disposed(by: disposableBag)

		viewModel.successMessage.asObservable().filter({ (notification) -> Bool in
			return nil != notification
		}).subscribe(onNext: { (notification) in
			let banner = NotificationBanner(title: notification?.title ?? "",
																			subtitle: notification?.text,
																			style: .success)
			banner.show()
		}).disposed(by: disposableBag)

		viewModel.output.spendAmount.asDriver(onErrorJustReturn: nil).map({ (str) -> String? in
			str?.replacingOccurrences(of: ",", with: ".")
		})
		.drive(spendAmountTextField.rx.text).disposed(by: disposableBag)

		self.viewModel = viewModel
	}

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		if let viewModel = viewModel as? SpendCoinsViewModel {
			self.configure(with: viewModel)
		}

		self.spendAmountTextField.rightPadding = useMaxButton.bounds.width
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsHelper.defaultAnalytics.track(event: .convertSpendScreen)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - UITextFieldDelegate

	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		if textField == self.spendCoinTextField {
			scrollView.endEditing(true)
			showPicker()
			return false
		}
		return true
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == self.getCoinTextField {
			scrollView.endEditing(true)
		}
		return true
	}

	private func shouldShowPicker() -> Bool {
		return (viewModel.pickerItems().count) > 1
	}

	// MARK: -

	func clearForm() {
		self.spendAmountTextField.text = ""
		self.getCoinTextField.text = ""
	}

	func showPicker() {
		let items = viewModel.spendCoinPickerItems

		guard items.count > 0 else {
			return
		}

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
			self?.spendCoinTextField.text = selected.first?.value
			self?.spendCoinTextField.sendActions(for: .valueChanged)
		}
	}

	// MARK: - IndicatorInfoProvider

	func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
		return IndicatorInfo(title: "SPEND".localized())
	}
}

//
//  ReceiveReceiveViewModel.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 19/04/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import RxSwift
import RxCocoa
import PassKit
import MinterCore
import MinterMy
import MinterExplorer
import BigInt
import RxRelay
import SwiftOTP
import NotificationBannerSwift

class ReceiveViewModel: BaseViewModel, ViewModelProtocol {
	fileprivate let emailFeeAmount = "20"
	fileprivate let emailFeeAddress = "Mx000ceac2471e7d4c269464b0e66b67b44d700001"
	fileprivate let emailFeeCurrency = UIApplication.realAppDelegate()!.isTestnet ? "MNT" : "BIP"
	
	private var selectedAddress: String?
	private var textFieldPopup: TextFieldPopupViewModel?
	
	// MARK: - ViewModelProtocol

		struct Dependency {
			var accounts: Observable<[Account]>
		}

		struct Input {
			var didTapAddPass: AnyObserver<Void>
			var email: AnyObserver<String?>
			var attachEmailButtonDidTap: AnyObserver<Void>
		}

		struct Output {
			var showViewController: Observable<UIViewController?>
			var errorNotification: Observable<NotifiableError?>
			var isLoadingPass: Observable<Bool>
			var shouldShowPass: Observable<Bool>

			var txErrorNotification: Observable<NotifiableError?>
			var popup: Observable<PopupViewController?>
		}

		var dependencies: ReceiveViewModel.Dependency!
		var input: ReceiveViewModel.Input!
		var output: ReceiveViewModel.Output!

		// MARK: -

		var title: String {
			return "Receive Coins".localized()
		}
	
	let fakePK = Data(hex: "678b3252ce9b013cef922687152fb71d45361b32f8f9a57b0d11cc340881c999").toHexString()
	
	var baseCoinBalance: Decimal {
		let balances = Session.shared.allBalances.value
		if
			let ads = selectedAddress,
			let coin = Coin.baseCoin().symbol,
			let smt = balances[ads],
			let blnc = smt[coin] {
				return blnc
		}
		return 0
	}
	
	private let accountManager = AccountManager()
	private let emailSubject = BehaviorSubject<String?>(value: "")
	private let attachEmailButtonDidTap = PublishSubject<Void>()

	private let errorNotificationSubject = PublishSubject<NotifiableError?>()
	private let txErrorNotificationSubject = PublishSubject<NotifiableError?>()
	private let popupSubject = PublishSubject<PopupViewController?>()
	
	private let clearPayloadSubject = BehaviorSubject<String?>(value: "")
	private var showViewControllerSubject = PublishSubject<UIViewController?>()
	
	private var isLoadingNonceSubject = PublishSubject<Bool>()

	private var lastSentTransactionHash: String?
	private var selectedCoin = BehaviorRelay<String>(value: "BIP")
	private var selectedAddressBalance: Decimal? {
		guard nil != selectedAddress && nil != selectedCoin.value else {
			return nil
		}
		let balance = Session.shared.allBalances.value.filter { (val) -> Bool in
			if selectedAddress != val.key { return false }
			return (nil != val.value[selectedCoin.value])
		}
		return balance[selectedAddress!]?[selectedCoin.value]
	}
	private var currentGas = BehaviorSubject<Int>(value: RawTransactionDefaultGasPrice)

	var sections = Variable([BaseTableSectionItem]())

  private var didTapAddPassSubject = PublishSubject<Void>()
  private var isLoadingPassSubject = PublishSubject<Bool>()
  private var shouldShowPassSubject = BehaviorRelay(value: PKPassLibrary.isPassLibraryAvailable())

	// MARK: -

	var sectionsObservable: Observable<[BaseTableSectionItem]> {
		return self.sections.asObservable()
	}

  init(dependency: Dependency) {
		super.init()

    self.dependencies = dependency

		input = Input(didTapAddPass: didTapAddPassSubject.asObserver(), email: emailSubject.asObserver(), attachEmailButtonDidTap: attachEmailButtonDidTap.asObserver())
    output = Output(showViewController: showViewControllerSubject.asObservable(),
                    errorNotification: errorNotificationSubject.asObservable(),
                    isLoadingPass: isLoadingPassSubject.asObservable(),
										shouldShowPass: shouldShowPassSubject.asObservable(), txErrorNotification: txErrorNotificationSubject.asObservable(), popup: popupSubject.asObservable())

    bind()
	}

  var accounts: [Account] = [] {
    didSet {
      self.createSections()
    }
  }

  func bind() {

    didTapAddPassSubject.asObservable().subscribe(onNext: { [weak self] (_) in
      self?.getPass()
    }).disposed(by: disposeBag)

    dependencies
      .accounts.asObservable()
      .subscribe(onNext: { [weak self] (accounts) in
        self?.accounts = accounts
    }).disposed(by: disposeBag)
		
		Session.shared.accounts.asDriver().drive(onNext: { [weak self] (accounts) in
			self?.createSections()
		}).disposed(by: disposeBag)
		
		attachEmailButtonDidTap.asObservable().subscribe { [weak self] _ in
			self?.attachEmailButtonTaped()
		}.disposed(by: disposeBag)
  }

  // MARK: -

	func createSections() {
		guard let accounts = accounts.first else {
			return
		}

		let sctns = [accounts].map { (account) -> BaseTableSectionItem in
			let sectionId = account.address

			let separator = SeparatorTableViewCellItem(reuseIdentifier: "SeparatorTableViewCell",
                                                 identifier: "SeparatorTableViewCell_1\(sectionId)")

			let address = AddressTableViewCellItem(reuseIdentifier: "AddressTableViewCell",
                                             identifier: "AddressTableViewCell_" + sectionId)
			address.address = "Mx" + account.address
			address.buttonTitle = "Copy".localized()

			let qrCell = QRTableViewCellItem(reuseIdentifier: "QRTableViewCell",
                                   identifier: "QRTableViewCell")
			qrCell.string = "Mx" + account.address

			let cashedRecipient = JSONStorage<Recipient>(storageType: .permanent, filename: Session.shared.accounts.value.first(where: { $0.isMain })?.address ?? "")
			let email = ReceiveEmailTableViewCellItem(reuseIdentifier: "ReceiveEmailTableViewCell", identifier: "ReceiveEmailTableViewCell_" + sectionId)
			email.recipient = cashedRecipient.storedValue
			email.buttonTitle = "Copy".localized()
			emailSubject.asObserver().onNext(cashedRecipient.storedValue?.email)
			
			var section = BaseTableSectionItem(header: "YOUR CREDENTIALS".localized())
			section.identifier = sectionId

			section.items = [email, address, separator, qrCell]
			return section
		}

		self.sections.value = sctns
	}

	// MARK: - Share

	func activities() -> [Any]? {
		guard let account = accounts.first else {
			return nil
		}

		let address = "Mx" + account.address
		return [address]
	}

	// MARK: - TableView

	func section(index: Int) -> BaseTableSectionItem? {
		return sections.value[safe: index]
	}

	func sectionsCount() -> Int {
		return sections.value.count
	}

	func rowsCount(for section: Int) -> Int {
		return sections.value[safe: section]?.items.count ?? 0
	}

	func cellItem(section: Int, row: Int) -> BaseCellItem? {
		return sections.value[safe: section]?.items[safe: row]
	}

	// MARK: -

  let passbookManager = PassbookManager()

  func getPass() {
    guard let account = accounts.first else {
      return
    }

    let address = account.address
    isLoadingPassSubject.onNext(true)
    passbookManager.pass(with: "Mx" + address) { [weak self] (data, error) in
      self?.isLoadingPassSubject.onNext(false)
      guard let passData = data else {
        //show error
        return
      }
      var errorPointer: NSError?
      let pass = PKPass(data: passData, error: &errorPointer)
      if errorPointer == nil {
        let controller = PKAddPassesViewController(pass: pass)
        self?.showViewControllerSubject.onNext(controller)
      }
    }
  }
	
	// MARK: -

	func lastTransactionExplorerURL() -> URL? {
		guard nil != lastSentTransactionHash else {
			return nil
		}
		return URL(string: MinterExplorerBaseURL! + "/transactions/" + (lastSentTransactionHash ?? ""))
	}
	
	func attachEmailButtonTaped() {
//		GateManager
//			.shared
//			.minGas()
//			.subscribe(onNext: { [weak self] (gas) in
//				self?.currentGas.onNext(gas)
//		}).disposed(by: disposeBag)

		let email = (try? self.emailSubject.value()) as? String
		textFieldPopup = self.attachEmailPopupViewModel(textFieldText: email)
		
		textFieldPopup?.output.didTapActionButton.asObservable().subscribe(onNext: { _ in
			self.sendAttachEmailTransaction()
		}).disposed(by: disposeBag)

		textFieldPopup?.output.didTapCancel.asObservable().subscribe(onNext: { _ in
			self.clear()
		}).disposed(by: disposeBag)

		textFieldPopup?.output.textFieldDidChange.asObservable().subscribe({ text in
			guard let email = text.element as? String else { return }
			if email == "" {
				self.textFieldPopup?.input.textFieldDidChangeState.onNext(.default)
				return
			}

			if email.isValidEmail() {
				self.textFieldPopup?.input.textFieldDidChangeState.onNext(.valid)
				self.emailSubject.onNext(text.element ?? "")
			} else {
				self.textFieldPopup?.input.textFieldDidChangeState.onNext(.invalid(error: "Email is incorrect".localized()))
			}
		}).disposed(by: disposeBag)
		
		let attachPopup = Storyboards.Popup.instantiateTextfieldPopupViewController()
		attachPopup.viewModel = textFieldPopup
		self.popupSubject.onNext(attachPopup)
	}
	
	private func sendAttachEmailTransaction() {
		guard let email = (try? self.emailSubject.value()) as? String else { return }
		if !email.isValidEmail() { return }
		
		func sendTx() {
			Observable
			.combineLatest(
				GateManager.shared.nonce(address: selectedAddress!),
				GateManager.shared.minGas()
			).do(onError: { [weak self] (error) in
				self?.errorNotificationSubject.onNext(NotifiableError(title: "Can't get nonce"))
			}, onCompleted: { [weak self] in
				self?.isLoadingNonceSubject.onNext(false)
			}, onSubscribe: { [weak self] in
				self?.isLoadingNonceSubject.onNext(true)
			}).map({ (val) -> (Int, Int) in
				return (val.0+1, val.1)
			}).flatMapLatest({ (val) -> Observable<String?> in
				let nonce = BigUInt(val.0)
				let amount = Decimal(string: self.emailFeeAmount)!
				let coin = self.emailFeeCurrency
				let recipient = self.emailFeeAddress
				return self.prepareTx(nonce: nonce,
															amount: amount,
															selectedCoinBalance: self.selectedAddressBalance ?? 0.0,
															recipient: recipient,
															coin: coin,
															payload: email)
			}).flatMapLatest({ (signedTx) -> Observable<String?> in
				return GateManager.shared.send(rawTx: signedTx)
			}).subscribe(onNext: { [weak self] (val) in
				self?.lastSentTransactionHash = val

				if let sentViewModel = self?.sentViewModel() {
					let popup = PopupRouter.sentPopupViewCointroller(viewModel: sentViewModel)
					self?.popupSubject.onNext(popup)
				}

				DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2), execute: {
					Session.shared.loadTransactions()
					Session.shared.loadBalances()
					Session.shared.loadDelegatedBalance()
				})
				self?.clear()
				self?.textFieldPopup?.input.activityIndicator.onNext(false)
			}, onError: { [weak self] (error) in
				self?.handle(error: error)
				self?.textFieldPopup?.input.activityIndicator.onNext(false)
			}, onCompleted: { [weak self] in
				self?.isLoadingNonceSubject.onNext(false)
				self?.textFieldPopup?.input.activityIndicator.onNext(false)
			}).disposed(by: disposeBag)
		}
		
		if let secretCode = accountManager.secretCode() {
			confirmWithSecretCode(secretCode) { isConfirmed in
				if isConfirmed {
					sendTx()
				} else {
					self.textFieldPopup?.input.activityIndicator.onNext(false)
				}
			}
		} else {
				sendTx()
		}
	}
	
	// MARK: -
	
	func prepareTx(
		nonce: BigUInt,
		amount: Decimal,
		selectedCoinBalance: Decimal,
		recipient: String,
		coin: String,
		payload: String) -> Observable<String?> {
			return Observable.create { (observer) -> Disposable in
				if
					let mnemonic = self.accountManager.mnemonic(for: self.selectedAddress!),
					let seed = self.accountManager.seed(mnemonic: mnemonic),
					let newPk = try? self.accountManager.privateKey(from: seed) {

					let isPublicKey = recipient.isValidPublicKey()
					let gasCoin = (self.canPayCommissionWithBaseCoin(isDelegate: isPublicKey)) ? Coin.baseCoin().symbol! : coin
					let value = BigUInt(decimal: amount.decimalFromPIP()) ?? BigUInt(0)
					let rawTx: RawTransaction = self.rawTransaction(nonce: nonce,
																													gasCoin: gasCoin,
																													recipient: recipient,
																													value: value,
																													coin: coin,
																													payload: payload)

					let pkString = newPk.raw.toHexString()
					let signedTx = RawTransactionSigner.sign(rawTx: rawTx, privateKey: pkString)
					observer.onNext(signedTx)
					observer.onCompleted()
				} else {
					observer.onError(SendViewModel.SendViewModelError.noPrivateKey)
					observer.onCompleted()
				}
				return Disposables.create()
			}
	}
	
	func confirmWithSecretCode(_ secretCode: String, completion: ((Bool) -> Void)? = nil) {
		let alert = BaseAlertController(title: "Enter 6 digit code", message: nil, preferredStyle: .alert)
		let yesAction = UIAlertAction(title: "OK", style: .default) { action in
			let firstTextField = alert.textFields![0] as UITextField
			guard let data = base32DecodeToData(secretCode) else {
				return
			}

			guard let totp = TOTP(secret: data, digits: 6, timeInterval: 30, algorithm: .sha1) else {
				return
			}
			let otpString = totp.generate(time: Date())

			if otpString == firstTextField.text {
				completion?(true)
			} else {
				let banner = NotificationBanner(title: "Wrong code!",subtitle: "", style: .danger)
				banner.show()
				completion?(false)
			}
		}
		let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel) { _ in
			self.textFieldPopup?.input.activityIndicator.onNext(false)
		}
		alert.addTextField(configurationHandler: { (textField) in
			textField.placeholder = "Enter 6 digit code"
			textField.keyboardType = .numberPad
			textField.maxLength = 6
		})
		alert.addAction(yesAction)
		alert.addAction(cancelAction)
		alert.view.tintColor = UIColor.mainColor()
				
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}

			topController.present(alert, animated: true)
		}
	}
	
	func rawTransaction(nonce: BigUInt,
											gasCoin: String,
											recipient: String,
											value: BigUInt,
											coin: String,
											payload: String) -> RawTransaction {
		let rawTx: RawTransaction
		let gasPrice = (try? currentGas.value()) ?? 1
		if recipient.isValidPublicKey() {
			rawTx = DelegateRawTransaction(nonce: nonce,
																		 gasPrice: gasPrice,
																		 gasCoin: gasCoin,
																		 publicKey: recipient,
																		 coin: coin,
																		 value: value)
		} else {
			rawTx = SendCoinRawTransaction(nonce: nonce,
																		 gasPrice: gasPrice,
																		 gasCoin: gasCoin,
																		 to: recipient,
																		 value: value,
																		 coin: coin.uppercased())
		}
		rawTx.payload = payload.data(using: .utf8) ?? Data()
		return rawTx
	}

	func clear() {
		let cashedRecipient = JSONStorage<Recipient>(storageType: .permanent, filename: Session.shared.accounts.value.first(where: { $0.isMain })?.address ?? "")
		emailSubject.asObserver().onNext(cashedRecipient.storedValue?.email)
		clearPayloadSubject.onNext(nil)
	}
	
	private func commission(isDelegate: Bool = false) -> Decimal {
		let payloadCom = payloadComission().decimalFromPIP()
		let val: Decimal
		if isDelegate {
			val = (payloadCom + RawTransactionType.delegate.commission()).PIPToDecimal()
		} else {
			val = (payloadCom + RawTransactionType.sendCoin.commission()).PIPToDecimal()
		}
		return Decimal(Session.shared.currentGasPrice.value) * val
	}
	
	private func payloadComission() -> Decimal {
		return Decimal((try? clearPayloadSubject.value() ?? "")?.count ?? 0) * RawTransaction.payloadByteComissionPrice
	}

	private func handle(error: Error) {
		var notification: NotifiableError
		if let error = error as? HTTPClientError {
			if let errorMessage = error.userData?["log"] as? String {
				notification = NotifiableError(title: "An Error Occurred".localized(),
																			 text: errorMessage)
			} else {
				notification = NotifiableError(title: "An Error Occurred".localized(),
																			 text: "Unable to send transaction".localized())
			}
		} else {
			notification = NotifiableError(title: "An Error Occurred".localized(),
																		 text: "Unable to send transaction".localized())
		}
		self.txErrorNotificationSubject.onNext(notification)
	}
	
	private func canPayCommissionWithBaseCoin(isDelegate: Bool = false) -> Bool {
		let balance = self.baseCoinBalance
		if balance >= commission(isDelegate: isDelegate) {
			return true
		}
		return false
	}
}


extension ReceiveViewModel {

	// MARK: - ViewModels
	func attachEmailPopupViewModel(textFieldText: String? = nil) -> TextFieldPopupViewModel {
		let viewModel: TextFieldPopupViewModel
		if let email = textFieldText, email != "" {
			viewModel = TextFieldPopupViewModel(popupTitle: "Attach email to your address".localized())
			viewModel.text = email
		} else {
			viewModel = TextFieldPopupViewModel(popupTitle: "Change your email for your address".localized())
		}

		guard let account = Session.shared.accounts.value.first else {
			print("ERROR! No accounts found!")
			Session.shared.logout()
			return viewModel
		}

		selectedAddress = account.address
		viewModel.addressTitle = "Mx" + account.address
		viewModel.title = " "
		viewModel.emailFeeCurrencyTitle = emailFeeCurrency
		viewModel.amountTitle = emailFeeAmount
		viewModel.buttonTitle = "SEND".localized()
		viewModel.cancelTitle = "CANCEL".localized()
		return viewModel
	}
	
	func sentViewModel() -> SentPopupViewModel {
		let viewModel = SentPopupViewModel()
		viewModel.actionButtonTitle = "VIEW TRANSACTION".localized()
		viewModel.avatarImageURL = MinterMyAPIURL.avatarAddress(address: self.emailFeeAddress).url()
		viewModel.secondButtonTitle = "CLOSE".localized()
		viewModel.desc = "Check your email to verify ownership".localized()
		viewModel.username = (try? self.emailSubject.value()) as? String
		viewModel.title = "Success!".localized()
		return viewModel
	}
}

//
//  ReceiveReceiveViewModel.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 19/04/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import RxSwift
import MinterExplorer
import MinterMy
import BigInt
import MinterCore
import RxRelay

class ReceiveViewModel: BaseViewModel, ViewModelProtocol {
	fileprivate let emailFeeAmount = "20"
	fileprivate let emailFeeAddress = "Mxe1dbde5c02a730f747a47d24f0f993c27da9dff1"
	fileprivate let emailFeeCurrency = "BIP"
	
	private var selectedAddress: String?
	
	// MARK: - ViewModelProtocol

	var input: ReceiveViewModel.Input!
	var output: ReceiveViewModel.Output!
	struct Input {
		var email: AnyObserver<String?>
		var attachEmailButtonDidTap: AnyObserver<Void>
	}
	struct Output {
		var errorNotification: Observable<NotifiableError?>
		var txErrorNotification: Observable<NotifiableError?>
		var popup: Observable<PopupViewController?>
		var showViewController: Observable<UIViewController?>
	}
	struct Dependency {}
	
	let fakePK = Data(hex: "678b3252ce9b013cef922687152fb71d45361b32f8f9a57b0d11cc340881c999").toHexString()

	var title: String {
		get {
			return "Receive Coins".localized()
		}
	}
	
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

	// MARK: -

	var sectionsObservable: Observable<[BaseTableSectionItem]> {
		return self.sections.asObservable()
	}

	override init() {
		self.input = Input(email: emailSubject.asObserver(), attachEmailButtonDidTap: attachEmailButtonDidTap.asObserver())
		self.output = Output(errorNotification: errorNotificationSubject.asObservable(),
												 txErrorNotification: txErrorNotificationSubject.asObservable(),
												 popup: popupSubject.asObservable(),
												 showViewController: showViewControllerSubject.asObservable())

		super.init()
		
		Session.shared.accounts.asDriver().drive(onNext: { [weak self] (accounts) in
			self?.createSections()
		}).disposed(by: disposeBag)
		
		attachEmailButtonDidTap.asObservable().subscribe { [weak self] _ in
			self?.attachEmailButtonTaped()
		}.disposed(by: disposeBag)
	}

	func createSections() {
		guard let accounts = Session.shared.accounts.value.first else {
			return
		}

		let sctns = [accounts].map { (account) -> BaseTableSectionItem in
			let sectionId = account.address

			let separator = SeparatorTableViewCellItem(reuseIdentifier: "SeparatorTableViewCell", identifier: "SeparatorTableViewCell_1\(sectionId)")

			let address = AddressTableViewCellItem(reuseIdentifier: "AddressTableViewCell", identifier: "AddressTableViewCell_" + sectionId)
			address.address = "Mx" + account.address
			address.buttonTitle = "Copy".localized()

			let qr = QRTableViewCellItem(reuseIdentifier: "QRTableViewCell", identifier: "QRTableViewCell")
			qr.string = "Mx" + account.address

			let cashedRecipient = JSONStorage<Recipient>(storageType: .permanent, filename: Session.shared.accounts.value.first(where: { $0.isMain })?.address ?? "")
			let email = ReceiveEmailTableViewCellItem(reuseIdentifier: "ReceiveEmailTableViewCell", identifier: "ReceiveEmailTableViewCell_" + sectionId)
			email.recipient = cashedRecipient.storedValue
			email.buttonTitle = "Copy".localized()
			emailSubject.asObserver().onNext(cashedRecipient.storedValue?.email)
			
			var section = BaseTableSectionItem(header: "YOUR CREDENTIALS".localized())
			section.identifier = sectionId

			section.items = [email, address, separator, qr]
			return section
		}

		self.sections.value = sctns
	}
	
	// MARK: - Share

	func activities() -> [Any]? {
		guard let account = Session.shared.accounts.value.first else {
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
		let attachVM = self.attachEmailPopupViewModel(textFieldText: email)
		
		attachVM.output.didTapActionButton.asObservable().subscribe(onNext: { _ in
			self.sendAttachEmailTransaction()
		}).disposed(by: disposeBag)

		attachVM.output.didTapCancel.asObservable().subscribe(onNext: { _ in
			self.clear()
		}).disposed(by: disposeBag)

		attachVM.output.textFieldDidChange.asObservable().subscribe({ text in
			guard let email = text.element as? String else { return }
			if email == "" {
				attachVM.input.textFieldDidChangeState.onNext(.default)
				return
			}

			if email.isValidEmail() {
				attachVM.input.textFieldDidChangeState.onNext(.default)
				self.emailSubject.onNext(text.element ?? "")
			} else {
				attachVM.input.textFieldDidChangeState.onNext(.invalid(error: "Email is incorrect".localized()))
			}
		}).disposed(by: disposeBag)
		
// 		TODO: - attach 2FA support after refactoring
//		if let secretCode = accountManager.secretCode() {
//				confirmWithSecretCode(secretCode, sendVM: attachVM)
//		} else {
//				let sendPopup = Storyboards.Popup.instantiateInitialViewController()
//				sendPopup.viewModel = sendVM
//				self.popupSubject.onNext(sendPopup)
//		}
		
		let attachPopup = Storyboards.Popup.instantiateTextfieldPopupViewController()
		attachPopup.viewModel = attachVM
		self.popupSubject.onNext(attachPopup)
	}
	
	private func sendAttachEmailTransaction() {
		guard let email = (try? self.emailSubject.value()) as? String else { return }
		if !email.isValidEmail() { return }

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
			}, onError: { [weak self] (error) in
				self?.handle(error: error)
			}, onCompleted: { [weak self] in
				self?.isLoadingNonceSubject.onNext(false)
			}).disposed(by: disposeBag)
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
		emailSubject.onNext(nil)
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
		viewModel.buttonTitle = "SEND".localized()
		viewModel.cancelTitle = "CANCEL".localized()
		return viewModel
	}
	
	func sentViewModel() -> SentPopupViewModel {
		let viewModel = SentPopupViewModel()
		viewModel.actionButtonTitle = "VIEW TRANSACTION".localized()
		viewModel.avatarImageURL = MinterMyAPIURL.avatarAddress(address: self.emailFeeAddress).url()
		viewModel.secondButtonTitle = "CLOSE".localized()
		viewModel.username = self.emailFeeAddress
		viewModel.title = "Success!".localized()
		return viewModel
	}
}

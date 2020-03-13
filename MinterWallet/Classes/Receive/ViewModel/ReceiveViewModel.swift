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

class ReceiveViewModel: BaseViewModel, ViewModelProtocol {

  // MARK: - ViewModelProtocol

  struct Dependency {
    var accounts: Observable<[Account]>
  }

  struct Input {}

  struct Output {
    var showViewController: Observable<UIViewController?>
    var errorNotification: Observable<NotifiableError?>
		var isLoadingPass: Observable<String>
    var shouldShowPass: Observable<Bool>
  }

  var dependencies: ReceiveViewModel.Dependency!
  var input: ReceiveViewModel.Input!
  var output: ReceiveViewModel.Output!

  // MARK: -

	var title: String {
    return "Receive Coins".localized()
	}

	private var disposableBag = DisposeBag()

	var sections = Variable([BaseTableSectionItem]())

  private var showViewControllerSubject = PublishSubject<UIViewController?>()
	private var isLoadingPassSubject = PublishSubject<String>()
  private var errorNotificationSubject = PublishSubject<NotifiableError?>()
  private var shouldShowPassSubject = BehaviorRelay(value: PKPassLibrary.isPassLibraryAvailable())

	// MARK: -

	var sectionsObservable: Observable<[BaseTableSectionItem]> {
		return self.sections.asObservable()
	}

  init(dependency: Dependency) {
		super.init()

    self.dependencies = dependency

    input = Input()
    output = Output(showViewController: showViewControllerSubject.asObservable(),
                    errorNotification: errorNotificationSubject.asObservable(),
                    isLoadingPass: isLoadingPassSubject.asObservable(),
                    shouldShowPass: shouldShowPassSubject.asObservable())

    bind()
	}

  var accounts: [Account] = [] {
    didSet {
      self.createSections()
    }
  }

  func bind() {

    dependencies
      .accounts.asObservable()
      .subscribe(onNext: { [weak self] (accounts) in
        self?.accounts = accounts
    }).disposed(by: disposableBag)
  }

  // MARK: -

	func createSections() {
		var addressNum = 0
		let sctns = accounts.sorted(by: { (acc1, acc2) -> Bool in
			return (acc1.isMain && !acc2.isMain)
		}).map { (account) -> BaseTableSectionItem in
			addressNum += 1

			let sectionId = account.address

			let separator = SeparatorTableViewCellItem(reuseIdentifier: "SeparatorTableViewCell",
                                                 identifier: "SeparatorTableViewCell_1\(sectionId)")

			let address = AddressTableViewCellItem(reuseIdentifier: "CopyTableViewCell",
                                             identifier: "AddressTableViewCell_" + sectionId)
			address.address = "Mx" + account.address
			address.buttonTitle = "Copy".localized()

			let bipAddress = "Mx" + account.address
			let addressButtonsCell = AddressButtonsTableViewCellItem(reuseIdentifier: "AddressButtonsTableViewCell",
                                   identifier: bipAddress)
			addressButtonsCell.string = bipAddress

			var headerTitle = "ADDRESS #\(addressNum)".localized()
			if account.isMain == true {
				headerTitle = "MAIN ADDRESS".localized()
			}
			var section = BaseTableSectionItem(header: headerTitle)
			section.identifier = sectionId

			section.items = [address, separator, addressButtonsCell]
			return section
		}

		self.sections.value = sctns
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

	func getPass(_ address: String) {
		isLoadingPassSubject.onNext(address)
    passbookManager.pass(with: address) { [weak self] (data, error) in
			self?.isLoadingPassSubject.onNext("")
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
}

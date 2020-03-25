//
//  RecipientPresetsTableViewCell.swift
//  MinterWallet
//
//  Created by Roman Slysh on 25.03.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import UIKit
import RxSwift

class RecipientPresetsTableViewCellItem: BaseCellItem {
	
	struct Input {
		var didTapMainPreset: AnyObserver<Void>
		var didTapGiftPreset: AnyObserver<Void>
		var didTapDelegatePreset: AnyObserver<Void>
	}
	struct Output {
		var didTapMainPreset: Observable<Void>
		var didTapGiftPreset: Observable<Void>
		var didTapDelegatePreset: Observable<Void>
	}
	var input: Input?
	var output: Output?

	// MARK: - Subjects

	private var didTapMainPresetSubject = PublishSubject<Void>()
	private var didTapGiftPresetSubject = PublishSubject<Void>()
	private var didTapDelegatePresetSubject = PublishSubject<Void>()

	override init(reuseIdentifier: String, identifier: String) {
		super.init(reuseIdentifier: reuseIdentifier, identifier: identifier)

		input = Input(didTapMainPreset: didTapMainPresetSubject.asObserver(), didTapGiftPreset: didTapGiftPresetSubject.asObserver(), didTapDelegatePreset: didTapDelegatePresetSubject.asObserver())
		output = Output(didTapMainPreset: didTapMainPresetSubject.asObservable(), didTapGiftPreset: didTapGiftPresetSubject.asObservable(),
		didTapDelegatePreset: didTapDelegatePresetSubject.asObservable())
	}
}


class RecipientPresetsTableViewCell: BaseCell {
	
	weak var presetsDelegate: PresetsTableViewCellDelegate?

	@IBOutlet weak var mainAddressButton: DefaultButton!
	@IBOutlet weak var giftButton: DefaultButton!
	@IBOutlet weak var delegateButton: DefaultButton!
	
	@IBAction func presetButtonDidTap(_ sender: DefaultButton) {
		presetsDelegate?.presetButtonDidTap(sender)
	}
	
	// MARK: -
	
	override func awakeFromNib() {
		super.awakeFromNib()

		mainAddressButton.setTitle("MAIN ADDRESS".localized(), for: .normal)
		giftButton.setTitle("GIFT".localized(), for: .normal)
		delegateButton.setTitle("DELEGATE".localized(), for: .normal)
	}

	override func configure(item: BaseCellItem) {
		super.configure(item: item)

		if let item = item as? RecipientPresetsTableViewCellItem {
			if let didTapPreset = item.input?.didTapMainPreset {
				mainAddressButton
					.rx
					.tap
					.asDriver(onErrorJustReturn: ())
					.drive(didTapPreset)
					.disposed(by: disposeBag)
			}
			
			if let didTapPreset = item.input?.didTapGiftPreset {
				giftButton
					.rx
					.tap
					.asDriver(onErrorJustReturn: ())
					.drive(didTapPreset)
					.disposed(by: disposeBag)
			}

			if let didTapPreset = item.input?.didTapDelegatePreset {
				delegateButton
					.rx
					.tap
					.asDriver(onErrorJustReturn: ())
					.drive(didTapPreset)
					.disposed(by: disposeBag)
			}
		}
	}
}

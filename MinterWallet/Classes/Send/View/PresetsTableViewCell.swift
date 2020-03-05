//
//  PresetsTableViewCell.swift
//  MinterWallet
//
//  Created by Roman Slysh on 05/03/2020.
//  Copyright © 2018 Rundax. All rights reserved.
//

import UIKit
import RxSwift

class PresetsTableViewCellItem: BaseCellItem {
	
	struct Input {
		var didTapPreset: AnyObserver<Void>
	}
	struct Output {
		var didTapPreset: Observable<Void>
	}
	var input: Input?
	var output: Output?

	// MARK: - Subjects

	private var didTapPresetSubject = PublishSubject<Void>()

	override init(reuseIdentifier: String, identifier: String) {
		super.init(reuseIdentifier: reuseIdentifier, identifier: identifier)

		input = Input(didTapPreset: didTapPresetSubject.asObserver())
		output = Output(didTapPreset: didTapPresetSubject.asObservable())
	}
}

protocol PresetsTableViewCellDelegate: class {
	func presetButtonDidTap(_ sender: DefaultButton)
}

class PresetsTableViewCell: BaseCell {
	
	weak var presetsDelegate: PresetsTableViewCellDelegate?

	@IBOutlet weak var _10Button: DefaultButton!
	@IBOutlet weak var _100Button: DefaultButton!
	@IBOutlet weak var _200Button: DefaultButton!
	@IBOutlet weak var _500Button: DefaultButton!
	@IBOutlet weak var _1000Button: DefaultButton!
	@IBOutlet weak var maxButton: DefaultButton!
	
	@IBAction func presetButtonDidTap(_ sender: DefaultButton) {
		presetsDelegate?.presetButtonDidTap(sender)
	}
	
	// MARK: -
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let screenSize: CGRect = UIScreen.main.bounds
		if screenSize.width <= 320 {
			maxButton.setTitle("MAX".localized(), for: .normal)
		} else {
			maxButton.setTitle("USE MAX".localized(), for: .normal)
		}
	}
	
	override func configure(item: BaseCellItem) {
		super.configure(item: item)

		if let item = item as? PresetsTableViewCellItem {
			if let didTapPreset = item.input?.didTapPreset {
				_10Button
					.rx
					.tap
					.asDriver(onErrorJustReturn: ())
					.drive(didTapPreset)
					.disposed(by: disposeBag)
				_100Button
					.rx
					.tap
					.asDriver(onErrorJustReturn: ())
					.drive(didTapPreset)
					.disposed(by: disposeBag)
				_200Button
					.rx
					.tap
					.asDriver(onErrorJustReturn: ())
					.drive(didTapPreset)
					.disposed(by: disposeBag)
				_500Button
					.rx
					.tap
					.asDriver(onErrorJustReturn: ())
					.drive(didTapPreset)
					.disposed(by: disposeBag)
				_1000Button
					.rx
					.tap
					.asDriver(onErrorJustReturn: ())
					.drive(didTapPreset)
					.disposed(by: disposeBag)
				maxButton
					.rx
					.tap
					.asDriver(onErrorJustReturn: ())
					.drive(didTapPreset)
					.disposed(by: disposeBag)
			}
		}
	}
}

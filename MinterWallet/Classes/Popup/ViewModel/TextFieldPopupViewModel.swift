//
//  TextfieldPopupViewModel.swift
//  MinterWallet
//
//  Created by Roman Slysh on 28.01.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import Foundation
import RxSwift


class TextFieldPopupViewModel: PopupViewModel, ViewModelProtocol {

	// MARK: - ViewModelProtocol

	struct Input {
		var didTapAction: AnyObserver<Void>
		var didTapCancel: AnyObserver<Void>
		var activityIndicator: AnyObserver<Bool>
		var textFieldText: AnyObserver<String?>
		var textFieldDidChangeState: AnyObserver<TextfieldPopupViewController.State?>
	}
	struct Output {
		var isActivityIndicatorAnimating: Observable<Bool>
		var didTapActionButton: Observable<Void>
		var didTapCancel: Observable<Void>
		var textFieldDidChange: Observable<String?>
		var textFieldDidChangeState: Observable<TextfieldPopupViewController.State?>
	}
	struct Dependency {}
	var input: TextFieldPopupViewModel.Input!
	var output: TextFieldPopupViewModel.Output!
	var dependency: TextFieldPopupViewModel.Dependency!

	// MARK: -

	var text: String?
	var buttonTitle: String?
	var cancelTitle: String?
	var addressTitle: String?
	var amountTitle: String?
	var emailFeeCurrencyTitle: String?

	// MARK: - input

	private var didTapActionSubject = PublishSubject<Void>()
	private var didTapCancelSubject = PublishSubject<Void>()
	private var activityIndicatorSubject = PublishSubject<Bool>()
	private var textFieldTextSubject = BehaviorSubject<String?>(value: "")
	private var textFieldStateSubject = BehaviorSubject<TextfieldPopupViewController.State?>(value: .default)

	init(popupTitle: String?, buttonTitle: String? = nil, cancelTitle: String? = nil) {
		super.init()

		input = Input(didTapAction: didTapActionSubject.asObserver(),
									didTapCancel: didTapCancelSubject.asObserver(),
									activityIndicator: activityIndicatorSubject.asObserver(), textFieldText: textFieldTextSubject.asObserver(), textFieldDidChangeState: textFieldStateSubject.asObserver())
		output = Output(isActivityIndicatorAnimating: activityIndicatorSubject.asObservable(),
										didTapActionButton: didTapActionSubject.asObservable(),
										didTapCancel: didTapCancelSubject.asObservable(),
										textFieldDidChange: textFieldTextSubject.asObservable(), textFieldDidChangeState: textFieldStateSubject.asObservable())
		dependency = Dependency()
		
		self.popupTitle = popupTitle
	}
}

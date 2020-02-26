//
//  SentViewModel.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 30/05/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit

class SentPopupViewModel: PopupViewModel, ViewModelProtocol {

	// MARK: - ViewModelProtocol

	struct Input {}
	struct Output {}
	struct Dependency {}
	var input: SentPopupViewModel.Input! = Input()
	var output: SentPopupViewModel.Output! = Output()

	// MARK: -

	var desc: String?
	var coin: String?
	var avatarImage: UIImage?
	var avatarImageURL: URL?
	var noAvatar: Bool = false
	var username: String?
	var actionButtonTitle: String?
	var secondActionButtomTitle: String?
	var secondButtonTitle: String?
}

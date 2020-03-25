//
//  UsernameTableViewCell.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 28/08/2019.
//  Copyright © 2019 Minter. All rights reserved.
//

import UIKit
import RxSwift

class UsernameTableViewCellItem: TextViewTableViewCellItem {}

protocol UsernameTextViewTableViewCellDelegate: class {
	func textViewDidChange(_ textView: UITextView)
	func textViewDidEndEditing(_ textView: UITextView)
	func didTapClearButton()
}

class UsernameTableViewCell: TextViewTableViewCell {

	var borderLayer: CAShapeLayer?
	weak var textViewDelegate: UsernameTextViewTableViewCellDelegate?
	@IBOutlet weak var clearButton: UIButton!
	
	// MARK: -

	var maxLength = 110

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func configure(item: BaseCellItem) {
		super.configure(item: item)

		textView
			.rx
			.text
			.subscribe(onNext: { [weak self] (str) in
				self?.clearButton.isHidden = str == ""
		}).disposed(by: disposeBag)
	}

	@IBAction func didTapClearButton(_ sender: Any) {
		textView.text = ""
		textViewDelegate?.didTapClearButton()
		clearButton.isHidden = true
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()

		setDefault()
		activityIndicator?.backgroundColor = .clear
		textView.font = UIFont.mediumFont(of: 16.0)
		clearButton.isHidden = true
	}

	@objc
	override func setValid() {
		self.textView?.superview?.layer.cornerRadius = 8.0
		self.textView?.superview?.layer.borderWidth = 2
		self.textView?.superview?.layer.borderColor = UIColor(hex: 0x4DAC4A)?.cgColor
		self.errorTitle.text = ""
	}

	@objc
	override func setInvalid(message: String?) {
		self.textView?.superview?.layer.cornerRadius = 8.0
		self.textView?.superview?.layer.borderWidth = 2
		self.textView?.superview?.layer.borderColor = UIColor.mainRedColor().cgColor
		
		if nil != message {
			self.errorTitle.text = message
		}
	}

	@objc
	override func setDefault() {
		self.textView?.superview?.layer.cornerRadius = 8.0
		self.textView?.superview?.layer.borderWidth = 2
		self.textView?.superview?.layer.borderColor = UIColor.mainGreyColor(alpha: 0.4).cgColor
		self.errorTitle.text = ""
	}
}

// UITextViewDelegate override
extension UsernameTableViewCell {
	func textViewDidChange(_ textView: UITextView) {
		textViewDelegate?.textViewDidChange(textView)
	}
	
	override func textViewDidEndEditing(_ textView: UITextView) {
		super.textViewDidEndEditing(textView)
		textViewDelegate?.textViewDidEndEditing(textView)
	}
}

//
//  UsernameTableViewCell.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 28/08/2019.
//  Copyright © 2019 Minter. All rights reserved.
//

import UIKit

class UsernameTableViewCellItem: TextViewTableViewCellItem {
	var giftButtonText: String?
}

protocol UsernameTextViewTableViewCellDelegate: class {
	func textViewDidChange(_ textView: UITextView)
	func textViewDidEndEditing(_ textView: UITextView)
	func didTapGiftButton()
}

class UsernameTableViewCell: TextViewTableViewCell {

	var borderLayer: CAShapeLayer?
	weak var textViewDelegate: UsernameTextViewTableViewCellDelegate?
	@IBOutlet weak var giftButton: UIButton!
	
	// MARK: -

	var maxLength = 110

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	@IBAction func didTapGiftButton(_ sender: Any) {
		textViewDelegate?.didTapGiftButton()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()

		setDefault()
		activityIndicator?.backgroundColor = .clear
		textView.font = UIFont.mediumFont(of: 16.0)
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

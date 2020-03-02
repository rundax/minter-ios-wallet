//
//  AddressButtonsTableViewCell.swift
//  MinterWallet
//
//  Created by Roman Slysh on 02.03.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import UIKit
import PassKit

class AddressButtonsTableViewCellItem : BaseCellItem {

	var string: String?

}

protocol AddressButtonsTableViewCellDelegate: class {
	func didTapQRButton(_ cell: AccordionTableViewCell)
	func didTapShareButton(_ cell: AccordionTableViewCell)
	func didTapAppleButton(_ cell: AccordionTableViewCell)
}

class AddressButtonsTableViewCell: ExpandableCell {
	@IBOutlet weak var qrButton: DefaultButton!
	@IBOutlet weak var shareButton: DefaultButton!
	@IBOutlet weak var appleWalletButton: DefaultButton!
	@IBOutlet weak var appleWalletActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var qrImageView: UIImageView!
	
	weak var buttonsDelegate: AddressButtonsTableViewCellDelegate?

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
        
		// Configure the view for the selected state
	}
	
	override func configure(item: BaseCellItem) {
		super.configure(item: item)

		if let item = item as? AddressButtonsTableViewCellItem, let string = item.string {
			identifier = string
			let qr = QRCode(string)
			qrImageView.image = qr?.image
		}

		appleWalletButton.isEnabled = PKPassLibrary.isPassLibraryAvailable()
	}
	
	@IBAction func didTapQRButton(_ sender: Any) {
		//setExpanded(!self.expanded, animated: true)
		buttonsDelegate?.didTapQRButton(self)
	}
	
	@IBAction func didTapShareButton(_ sender: Any) {
		buttonsDelegate?.didTapShareButton(self)
	}
	
	@IBAction func didTapAppleButton(_ sender: Any) {
		buttonsDelegate?.didTapAppleButton(self)
	}
	
}

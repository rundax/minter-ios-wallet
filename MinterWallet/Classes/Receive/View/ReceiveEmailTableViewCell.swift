//
//  ReceiveEmailTableViewCell.swift
//  MinterWallet
//
//  Created by Roman Slysh on 23.01.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import UIKit

class ReceiveEmailTableViewCellItem : BaseCellItem {
	var recipient: Recipient?
}


class ReceiveEmailTableViewCell: AddressTableViewCell {
	
	//MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	//MARK: - Configurable
	
	override func configure(item: BaseCellItem) {
		super.configure(item: item)
		
		if let item = item as? ReceiveEmailTableViewCellItem {
			addressLabel.text = item.recipient?.email
		}
	}
}

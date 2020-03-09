//
//  CopyTableViewCell.swift
//  MinterWallet
//
//  Created by Roman Slysh on 09.03.2020.
//  Copyright © 2020 Minter. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class CopyTableViewCellItem: BaseCellItem {
	var title: String?
	var buttonTitle: String?
}

class AddressTableViewCellItem: BaseCellItem {
	var address: String?
	var buttonTitle: String?
}

class CopyTableViewCell: BaseCell {

	// MARK: - IBOutlet/IBAction

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var actionButton: UIButton!
	@IBAction func didTapActionButton(_ sender: Any) {
		SoundHelper.playSoundIfAllowed(type: .click)
		AnalyticsHelper.defaultAnalytics.track(event: .pushGiftsCopyButton, params: nil)
		UIPasteboard.general.string = titleLabel.text
		let banner = NotificationBanner(title: "Copied".localized(),
																		subtitle: nil,
																		style: .info)
		banner.show()
	}

	// MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTitle))
		self.contentView.addGestureRecognizer(tapGesture)
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	@objc func didTapTitle() {
		SoundHelper.playSoundIfAllowed(type: .click)
		AnalyticsHelper.defaultAnalytics.track(event: .pushGiftsCopyButton, params: nil)
		UIPasteboard.general.string = titleLabel.text
		let banner = NotificationBanner(title: "Copied".localized(),
																		subtitle: nil,
																		style: .info)
		banner.show()
	}

	// MARK: - BaseCell

	override func configure(item: BaseCellItem) {
		if let copyItem = item as? CopyTableViewCellItem {
			titleLabel.text = copyItem.title
			actionButton.setTitle(copyItem.buttonTitle, for: .normal)
			return
		}

		if let addressItem = item as? AddressTableViewCellItem {
			titleLabel.text = "Mx" + (addressItem.address?.stripMinterHexPrefix() ?? "").lowercased()
			actionButton.setTitle(addressItem.buttonTitle, for: .normal)
		}
	}
    
}

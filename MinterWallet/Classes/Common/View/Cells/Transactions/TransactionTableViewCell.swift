//
//  TransactionTableViewCell.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 09/04/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit
import AlamofireImage

class TransactionTableViewCellItem: TransactionCellItem {
	var title: String?
	var image: UIImage?
	var imageURL: URL?
	var date: Date?
	var coin: String?
	var amount: Decimal?
	var expandable: Bool?
}

protocol ExpandedTransactionTableViewCellDelegate: class {
	func didTapExplorerButton(cell: ExpandableCell)
	func didTapFromButton(cell: ExpandableCell)
	func didTapToButton(cell: ExpandableCell)
}

class TransactionTableViewCell: BaseTransactionCell {

	// MARK: -

	let dateFormatter = TransactionDateFormatter.transactionDateFormatter
	let timeFormatter = TransactionDateFormatter.transactionTimeFormatter

	// MARK: - IBOutlet

	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var coinImageWrapper: UIView! {
		didSet {
			coinImageWrapper.layer
				.applySketchShadow(color: UIColor(hex: 0x000000, alpha: 0.2)!,
													 alpha: 1,
													 x: 0,
													 y: 2,
													 blur: 18,
													 spread: 0)
		}
	}
	@IBOutlet weak var coinImage: UIImageView! {
		didSet {
			coinImage.makeBorderWithCornerRadius(radius: 17.0,
																					 borderColor: .clear,
																					 borderWidth: 2.0)
		}
	}
	@IBOutlet weak var amount: UILabel!
	@IBOutlet weak var coin: UILabel!
	@IBOutlet weak var fromAddressButton: UIButton!
	@IBOutlet weak var toAddressButton: UIButton!
	@IBOutlet weak var expandedAmountLabel: UILabel!
	@IBOutlet weak var coinLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var heightCoinstraint: NSLayoutConstraint!

	// MARK: -

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	// MARK: -

	override func configure(item: BaseCellItem) {
		super.configure(item: item)

		defer {
			self.setNeedsUpdateConstraints()
			self.setNeedsLayout()
			self.layoutIfNeeded()
		}

		guard let transaction = item as? TransactionTableViewCellItem else {
			return
		}

		identifier = item.identifier
		title.text = TransactionTitleHelper.title(from: transaction.title ?? "")
		amount.text = amountText(amount: transaction.amount)
		if (transaction.amount ?? 0) > 0 {
			coinImage.image = UIImage(named: "receiveTX")
			amount.textColor = UIColor.mainOrangeColor()
		} else {
			coinImage.image = UIImage(named: "sendTX")
			amount.textColor = UIColor.mainColor()
		}

		fromAddressButton.setTitle(transaction.from, for: .normal)
		toAddressButton.setTitle(transaction.to, for: .normal)
		expandedAmountLabel.text = CurrencyNumberFormatter
			.formattedDecimal(with: (transaction.amount ?? 0),
												formatter: CurrencyNumberFormatter.coinFormatter)
		coinLabel.text = transaction.coin
		dateLabel.text = dateFormatter.string(from: transaction.date ?? Date())
		timeLabel.text = timeFormatter.string(from: transaction.date ?? Date())

		coin.text = transaction.coin
		expandable = transaction.expandable ?? false
	}

	private func amountText(amount: Decimal?) -> String {
		guard amount != nil else {
			return ""
		}
		return CurrencyNumberFormatter.formattedDecimal(with: amount ?? 0,
																										formatter: CurrencyNumberFormatter.transactionFormatter)
	}

	// MARK: -

	@IBAction func didTapExpandedButton(_ sender: Any) {
		delegate?.didTapExplorerButton(cell: self)
	}

	@IBAction func didTapFromButton(_ sender: Any) {
		delegate?.didTapFromButton(cell: self)
	}

	@IBAction func didTapToButton(_ sender: Any) {
		delegate?.didTapToButton(cell: self)
	}

	// MARK: -

	override func layoutSubviews() {
		super.layoutSubviews()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		detailView?.setNeedsLayout()
		detailView?.layoutIfNeeded()

		self.setNeedsLayout()
		self.layoutIfNeeded()
	}

	override func setExpanded(_ expanded: Bool, animated: Bool) {
		super.setExpanded(expanded, animated: animated)
	}
}

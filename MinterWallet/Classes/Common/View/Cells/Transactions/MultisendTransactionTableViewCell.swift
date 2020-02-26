//
//  MultisendTransactionTableViewCell.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 09/04/2019.
//  Copyright © 2019 Minter. All rights reserved.
//

import UIKit
import AlamofireImage

class MultisendTransactionTableViewCellItem: TransactionCellItem {
	var title: String?
	var imageURL: URL?
	var image: UIImage?
	var date: Date?
	var coin: String?
	var amount: Decimal?
	var expandable: Bool?
}

class MultisendTransactionTableViewCell: BaseTransactionCell {

	// MARK: -

	let dateFormatter = TransactionDateFormatter.transactionDateFormatter
	let timeFormatter = TransactionDateFormatter.transactionTimeFormatter

	// MARK: - IBOutlets

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
	@IBOutlet weak var amountTitleLabel: UILabel!
	@IBOutlet weak var amount: UILabel!
	@IBOutlet weak var coin: UILabel!
	@IBOutlet weak var fromAddressButton: UIButton!
	@IBOutlet weak var expandedAmountLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!

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

		amountTitleLabel.alpha = 1.0
		if let transaction = item as? MultisendTransactionTableViewCellItem {
			identifier = item.identifier
			title.text = TransactionTitleHelper.title(from: transaction.title ?? "")
			coinImage.image = UIImage(named: "multisendIcon")
			amount.text = amountText(amount: transaction.amount)
			amount.textColor = ((transaction.amount ?? 0) > 0) ? UIColor.mainOrangeColor() : UIColor.mainColor()

			fromAddressButton.setTitle(transaction.from, for: .normal)

			if transaction.amount == nil {
				expandedAmountLabel.text = ""
				amountTitleLabel.alpha = 0.0
			} else {
				expandedAmountLabel.text = CurrencyNumberFormatter
					.formattedDecimal(with: (transaction.amount ?? 0),
														formatter: CurrencyNumberFormatter.coinFormatter)
			}
			dateLabel.text = dateFormatter.string(from: transaction.date ?? Date())
			timeLabel.text = timeFormatter.string(from: transaction.date ?? Date())

			coin.text = transaction.coin
			expandable = transaction.expandable ?? false
		}

		self.setNeedsUpdateConstraints()
		self.setNeedsLayout()
		self.layoutIfNeeded()
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

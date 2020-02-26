//
//  AutocompleteView.swift
//  MinterWallet
//
//  Created by Roman Slysh on 1/17/20.
//  Copyright © 2020 Minter. All rights reserved.
//

import UIKit

final class CustomAutocompleteTableViewCell: LUAutocompleteTableViewCell {
	
	var recipient: Recipient? {
		didSet {
			textLabel?.text = recipient?.title
		}
	}
}

/// AutocompleteView class is custom view uses in Send screen for email autocomplate
class AutocompleteView: UIView {
	private static let cellIdentifier = "AutocompleteCellIdentifier"

	var textAttributes: [NSAttributedStringKey: Any]?
	var elements = [Recipient]() {
			didSet {
					tableView.reloadData()
			}
	}

	let tableView = UITableView()
	
	public override init(frame: CGRect) {
			super.init(frame: frame)

			commonInit()
	}

	/** Returns an object initialized from data in a given unarchiver.

	- Parameter coder: An unarchiver object.
	
	- Retunrs: `self`, initialized using the data in *decoder*.
	*/
	public required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)

			commonInit()
	}

	// MARK: - Private Functions

	private func commonInit() {
		backgroundColor = .white

		addSubview(tableView)

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: AutocompleteView.cellIdentifier)
		tableView.rowHeight = 45
		tableView.tableFooterView = UIView()
		tableView.separatorInset = .zero
		tableView.contentInset = .zero
		tableView.showsVerticalScrollIndicator = false
		tableView.showsHorizontalScrollIndicator = false
		tableView.bounces = false
		tableView.frame = bounds
		tableView.backgroundColor = .white
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		//tableView.frame = rect
	}
}

// MARK: - UITableViewDataSource

extension AutocompleteView: UITableViewDataSource {
    /** Tells the data source to return the number of rows in a given section of a table view.

    - Parameters:
        - tableView: The table-view object requesting this information.
        - section: An index number identifying a section of `tableView`.

    - Returns: The number of rows in `section`.
    */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
				return elements.count
    }

    /** Asks the data source for a cell to insert in a particular location of the table view.

    - Parameters:
        - tableView: A table-view object requesting the cell.
        - indexPath: An index path locating a row in `tableView`.

    - Returns: An object inheriting from `UITableViewCell` that the table view can use for the specified row. An assertion is raised if you return `nil`.
    */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteView.cellIdentifier) else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }

        guard indexPath.row < elements.count else {
            assertionFailure("Sanity check")
            return cell
        }

        let recipient = elements[indexPath.row]

        guard let customCell = cell as? CustomAutocompleteTableViewCell  else {
					cell.textLabel?.attributedText = NSAttributedString(string: recipient.title, attributes: textAttributes)
            cell.selectionStyle = .none

            return cell
        }
			
			customCell.recipient = recipient

			return customCell
    }
}

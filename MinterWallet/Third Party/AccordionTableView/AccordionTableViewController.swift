/**
*  https://github.com/tadija/AEAccordion
*  Copyright (c) Marko Tadić 2015-2018
*  Licensed under the MIT license. See LICENSE file.
*/

import UIKit

/**
This class is used for accordion effect in `UITableViewController`.

Just subclass it and implement `tableView:heightForRowAtIndexPath:`
(based on information in `expandedIndexPaths` property).
*/
open class AccordionTableViewController: UIViewController, UITableViewDelegate {

	// MARK: Properties

	@IBOutlet weak var tableView: UITableView!

	/// Array of `IndexPath` objects for all of the expanded cells.
	open var expandedIdentifiers = Set<String>()

	/// Flag that indicates if cell toggle should be animated. Defaults to `true`.
	open var shouldAnimateCellToggle = true

	/// Flag that indicates if `tableView` should scroll after cell is expanded,
	/// in order to make it completely visible (if it's not already). Defaults to `true`.
	open var shouldScrollIfNeededAfterCellExpand = true

	// MARK: Actions

	/**
	Expand or collapse the cell.
	- parameter cell: Cell that should be expanded or collapsed.
	- parameter animated: If `true` action should be animated.
	*/
	open func toggleCell(_ cell: AccordionTableViewCell, animated: Bool) {
		cell.willToggleCell(animated: animated)
		if cell.expanded {
			collapseCell(cell, animated: animated)
		} else {
			expandCell(cell, animated: animated)
		}
		cell.didToggleCell(animated: animated)
	}

	// MARK: UITableViewDelegate

	/// `AccordionTableViewController` will set cell to be expanded or collapsed without animation.
	public func tableView(_ tableView: UITableView,
															 willDisplay cell: UITableViewCell,
															 forRowAt indexPath: IndexPath) {
		if let cell = cell as? AccordionTableViewCell {
			let expanded1 = expandedIdentifiers.contains(cell.identifier)
			cell.setExpanded(expanded1, animated: false)
		}
	}

	/// `AccordionTableViewController` will animate cell to be expanded or collapsed.
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) as? AccordionTableViewCell {
			if !cell.toggling {
				cell.toggle(!cell.expanded, animated: shouldAnimateCellToggle)
				toggleCell(cell, animated: shouldAnimateCellToggle)
			}
		}
	}

	// MARK: Helpers

	private func expandCell(_ cell: AccordionTableViewCell, animated: Bool) {
		if let indexPath = tableView.indexPath(for: cell) {
			if !animated {
				cell.setExpanded(true, animated: false)
				expandedIdentifiers.insert(cell.identifier)
				tableView.reloadData()
				if #available(iOS 11.0, *) {
					scrollIfNeededAfterExpandingCell(at: indexPath, at: .bottom)
				} else {
					scrollIfNeededAfterExpandingCell(at: indexPath, at: .top)
				}
			} else {
				CATransaction.begin()
				CATransaction.setAnimationDuration(0.1)
				CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
				CATransaction.setCompletionBlock({ () -> Void in
					// 2. animate views after expanding
					cell.setExpanded(true, animated: true)
					if #available(iOS 11.0, *) {
						self.scrollIfNeededAfterExpandingCell(at: indexPath, at: .bottom)
					} else {
						self.scrollIfNeededAfterExpandingCell(at: indexPath, at: .top)
					}
				})
				// 1. expand cell height
				tableView.beginUpdates()
				expandedIdentifiers.insert(cell.identifier)
				tableView.endUpdates()
				CATransaction.commit()
			}
		}
	}

	private func collapseCell(_ cell: AccordionTableViewCell, animated: Bool) {
		if tableView.indexPath(for: cell) != nil {
			if !animated {
				cell.setExpanded(false, animated: false)
				if let idx = (expandedIdentifiers.index { (id) -> Bool in
					return id == cell.identifier
				}) {
					expandedIdentifiers.remove(at: idx)
				}
				tableView.reloadData()
			} else {
				CATransaction.begin()
				CATransaction.setAnimationDuration(0.1)
				CATransaction.setCompletionBlock({ () -> Void in
					DispatchQueue.main.async {
						// 2. collapse cell height
						self.tableView.beginUpdates()
						self.expandedIdentifiers.remove(cell.identifier)
						self.tableView.endUpdates()
					}
				})
				// 1. animate views before collapsing
				cell.setExpanded(false, animated: true)
				CATransaction.commit()
			}
		}
	}

	private func scrollIfNeededAfterExpandingCell(at indexPath: IndexPath, at position: UITableView.ScrollPosition = .bottom) {
		guard shouldScrollIfNeededAfterCellExpand,
			let cell = tableView.cellForRow(at: indexPath) as? AccordionTableViewCell else {
				return
		}
		let cellRect = tableView.rectForRow(at: indexPath)
		let isCompletelyVisible = tableView.bounds.contains(cellRect)
		if cell.expanded && !isCompletelyVisible {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				self.tableView.scrollToRow(at: indexPath, at: position, animated: true)
			}
		}
	}

}

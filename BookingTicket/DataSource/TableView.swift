//
//  TableView.swift
//  BookingTicket
//
//  Created by anhthu on 12/3/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit

class TableView: UITableView {
    override func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableViewScrollPosition, animated: Bool) {
        if autoScrollingEnabled {
            super.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
    
    //MARK: Properties
    
    var autoScrollingEnabled = true
}

extension UITableViewController {
    func hasRowInSection(_ sectionIndex: Int) -> Bool {
        return tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: sectionIndex) > 0
    }
    
    func scrollViewToRowAtIndexPath(_ indexPath: IndexPath, atScrollPosition scrollPosition: UITableViewScrollPosition, animated: Bool) {
        if hasRowInSection(indexPath.section) {
            tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
}

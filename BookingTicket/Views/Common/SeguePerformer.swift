//
//  SeguePerformer.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
protocol SeguePerformer {
    var segueManager: SegueManager { get }
}

extension SeguePerformer {
    func performSegue(_ identifier: String, handler: @escaping SegueManager.Handler) {
        segueManager.performSegue(identifier, handler: handler)
    }
    
    func performSegue<T>(_ identifier: String, handler: @escaping (T) -> Void) {
        segueManager.performSegue(identifier, handler: handler)
    }
    
    func performSegue(_ identifier: String) {
        segueManager.performSegue(identifier)
    }
}

class SegueManagerViewController: UIViewController, SeguePerformer {
    lazy var segueManager: SegueManager = SegueManager(viewController: self)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueManager.prepareForSegue(segue)
    }
}

class SegueManagerCollectionViewController: UICollectionViewController, SeguePerformer {
    lazy var segueManager: SegueManager = SegueManager(viewController: self)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueManager.prepareForSegue(segue)
    }
}

class SegueManagerTableViewController: UITableViewController, SeguePerformer {
    lazy var segueManager: SegueManager = SegueManager(viewController: self)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueManager.prepareForSegue(segue)
    }
}

class SegueManagerNavigationController: UINavigationController, SeguePerformer {
    lazy var segueManager: SegueManager = SegueManager(viewController: self)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueManager.prepareForSegue(segue)
    }
}


//
//  TableViewController.swift
//  Drawer
//
//  Created by Anton Polyakov on 13/09/2018.
//  Copyright © 2018 Gazprombank. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource {
    let tableView = UITableView()
    
    var data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"]
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(self.tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isScrollEnabled = false
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.dataSource = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = data[indexPath.row]
        
        return cell
    }
}

extension TableViewController {
    override var dragableViews: [UIView] { return [self.tableView] }
    
    override var shouldHandlePanGesture: Bool {
        return self.tableView.contentOffset.y <= 0
    }
}

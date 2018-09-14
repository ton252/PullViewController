//
//  PullViewController.swift
//  RootViewController
//
//  Created by Anton Polyakov on 13/09/2018.
//  Copyright © 2018 Gazprombank. All rights reserved.
//

import UIKit

protocol PassthroughTableViewDelegate: class {
    func viewToReceiveTouch(scrollView: UIScrollView, point: CGPoint, with event: UIEvent?) -> UIView?
}
class TableView: UITableView {
    var touchDelegate: PassthroughTableViewDelegate?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let touchDelegate = self.touchDelegate else {
            return super.hitTest(point, with: event)
        }
        
        return touchDelegate.viewToReceiveTouch(scrollView: self, point: point, with: event)
    }
}

class PullViewController: UIViewController, UITableViewDelegate, PassthroughTableViewDelegate {

    let headerView = UIButton(type: .system)
    
    let tableHeaderView = UIView()
    let backgroundView = UIView()
    let tableView = TableView()
    
    var isHeaderHidden = false
    
    var topOffSet: CGFloat = 300 {
        didSet {
            self.layoutViews()
            self.updateScrollIndicatorInsets()
        }
    }
    
    override func loadView() {
        super.loadView()
        self.tableView.tableHeaderView = self.tableHeaderView
        self.tableHeaderView.isHidden = true
        
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.backgroundView)
        self.view.addSubview(self.tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .clear
        
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.touchDelegate = self
        
        self.headerView.setTitle("Button", for: .normal)
        self.headerView.backgroundColor = .green
        
        self.backgroundView.backgroundColor = .orange
        
        self.updateScrollIndicatorInsets()
    }
    
    func updateScrollIndicatorInsets() {
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: self.topOffSet, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutViews()
    }
    
    func layoutViews() {
        let tableHeaderHeight = self.isHeaderHidden ? 0 : self.topOffSet
        
        self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.topOffSet)
        self.tableHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: tableHeaderHeight)

        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: self.topOffSet, left: 0, bottom: 0, right: 0)
        
        self.backgroundView.frame = CGRect(x: 0, y: self.topOffSet, width: self.tableView.frame.width, height: self.view.frame.height - self.topOffSet)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.setHeader(hidden: true, animated: true)
    }
    
    func setHeader(hidden: Bool, animated: Bool = false) {
        self.layoutViews()
        self.isHeaderHidden = hidden
        
        self.tableView.beginUpdates()
        if animated {
            UIView.animate(withDuration: 4.0, delay: 0, options: [], animations: {
                self.tableView.contentOffset = .zero
                self.layoutViews()
                self.tableView.endUpdates()
            }, completion: nil)
        } else {
            self.layoutViews()
            self.tableView.endUpdates()
        }
    }
    
    func viewToReceiveTouch(scrollView: UIScrollView, point: CGPoint, with event: UIEvent?) -> UIView? {
        let point = scrollView.convert(point, to: self.headerView)
        let rect = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.width, height: max(-self.tableView.contentOffset.y + self.topOffSet, 0))
        
        if rect.contains(point) {
            return self.headerView
        } else {
            return self.tableView
        }
    }
    
}

extension PullViewController: UITableViewDataSource {
    
    var data: [String] {
        return  ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"]
    }
    
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


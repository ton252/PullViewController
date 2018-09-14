//
//  ViewController.swift
//  RootViewController
//
//  Created by Anton Polyakov on 11/09/2018.
//  Copyright © 2018 Gazprombank. All rights reserved.
//

import UIKit

protocol RootViewControllerDelegate {
    func postionDidChange(_ position: RootViewController.Postion)
}

class RootViewController: UIViewController {
    
    enum Postion {
        case full
        case partition
    }
    
    var delegate: RootViewControllerDelegate?
    var position: Postion = .partition
    
    var primaryViewController: UIViewController {
        willSet { self.remove(viewController: self.primaryViewController) }
        didSet { self.add(childViewController: self.drawerViewController, superView: self.primaryContentContainer) }
    }
    
    var drawerViewController: UIViewController {
        willSet { self.remove(viewController: self.drawerViewController) }
        didSet { self.add(childViewController: self.drawerViewController, superView: self.drawerViewController.view) }
    }
    
    private lazy var primaryContentContainer: UIView = {
        return UIView()
    }()
    
    private lazy var drawerContentContainer: UIView = {
        return UIView()
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = PassthroughScrollView()
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.touchDelegate = self
        scrollView.delegate = self
        
        return scrollView
    }()
    
    lazy var shadowView: UIView = {
        return UIView()
    }()
    
    init(primaryViewController: UIViewController, drawerViewController: UIViewController) {
        self.primaryViewController = primaryViewController
        self.drawerViewController = drawerViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
    
        self.remove(viewController: self.primaryViewController)
        self.add(childViewController: self.primaryViewController, superView: self.primaryContentContainer)
        
        self.remove(viewController: self.drawerViewController)
        self.add(childViewController: self.drawerViewController, superView: self.drawerContentContainer)
        
        self.view.addSubview(primaryContentContainer)
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(self.shadowView)
        self.scrollView.addSubview(self.drawerContentContainer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.tag = 0
        
        self.drawerContentContainer.tag = 1
        self.drawerViewController.view.tag = 11
        
        self.primaryContentContainer.tag = 2
        self.primaryViewController.view.tag = 22
        
        self.changePosition()
    }
    
    // MARK: - Private Methods
    
    @objc private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        
    }
    
    private func remove(viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    private func add(childViewController: UIViewController, superView: UIView) {
        self.addChildViewController(childViewController)
        superView.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: self)
    }
    
    var topOffset: CGFloat = 330 {
        didSet { self.layoutViews() }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutViews()
    }
    
    func layoutViews() {
        let bounds = self.view.bounds
        let width = self.view.bounds.width
        let height = self.view.bounds.height

        self.scrollView.frame = bounds
        
        self.primaryContentContainer.frame = bounds
        self.primaryViewController.view.frame = self.primaryContentContainer.bounds
        
        let drawerFrame = CGRect(x: 0, y: self.topOffset, width: width, height: height)
        
        self.drawerContentContainer.frame = drawerFrame
        self.drawerViewController.view.frame = self.drawerContentContainer.bounds
        self.shadowView.frame = drawerFrame
        
        self.scrollView.contentSize = CGSize(width: width, height: drawerFrame.origin.y + drawerFrame.size.height)
    }
}

extension RootViewController: PassthroughScrollViewDelegate {
    func shouldTouchPassthroughScrollView(scrollView: PassthroughScrollView, point: CGPoint) -> Bool {
        return !drawerContentContainer.bounds.contains(drawerContentContainer.convert(point, from: scrollView))
    }
    
    func viewToReceiveTouch(scrollView: PassthroughScrollView, point: CGPoint) -> UIView? {
        if self.drawerContentContainer.bounds.contains(self.drawerContentContainer.convert(point, from: scrollView)) {
            return self.drawerViewController.view
        } else {
            return self.primaryContentContainer
        }
    }
}

extension RootViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if self.scrollView.contentOffset.y > self.scrollView.contentSize.height - self.scrollView.bounds.height {
//            self.scrollView.contentOffset.y = self.scrollView.contentSize.height - self.scrollView.bounds.height
//            self.position = .full
//        } else {
//            self.position = .partition
//        }
//        self.changePosition()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.scrollView.contentOffset.y = self.scrollView.contentOffset.y
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            self.scrollView.contentOffset.y = 0
        }) { _ in
            self.scrollView.contentOffset.y = 0
            print("completion")
        }
    }
    
    func changePosition() {
        (self.drawerViewController as? RootViewControllerDelegate)?.postionDidChange(self.position)
    }
}


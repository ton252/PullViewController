//
//  ViewController.swift
//  Drawer
//
//  Created by Anton Polyakov on 13/09/2018.
//  Copyright © 2018 Gazprombank. All rights reserved.
//

import UIKit

protocol DrawerViewController {
    var dragableViews: [UIView] { get }
    var shouldHandlePanGesture: Bool { get }
}

extension UIViewController: DrawerViewController {
    @objc var dragableViews: [UIView] { return [self.view] }
    @objc var shouldHandlePanGesture: Bool {  return true }
}

class ViewController: UIViewController {
    
    enum State {
        case closed
        case open
    }
    
    // MARK: - Public Properties
    
    private var currentState: State = .open
    
    var topOffset: CGFloat = 300
    
    var drawerViewController: DrawerViewController & UIViewController = UIViewController() {
        willSet { self.remove(viewController: self.drawerViewController) }
        didSet { self.add(childViewController: self.drawerViewController, superView: self.drawerContainer) }
    }
    
    var primaryViewController = UIViewController() {
        willSet { self.remove(viewController: self.primaryViewController) }
        didSet { self.add(childViewController: self.primaryViewController, superView: self.primaryContainer) }
    }
    
    // MARK: - Private Properties
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var drawerContainer: UIView = {
        return UIView()
    }()
    
    private var primaryContainer: UIView = {
        return UIView()
    }()
    
    private var runningAnimators: [UIViewPropertyAnimator] = []
    private var animationProgress: [CGFloat] = []
    
    // MARK: - Initializers
    
    init(primaryViewController: UIViewController, drawerViewController: UIViewController) {
        self.primaryViewController = primaryViewController
        self.drawerViewController = drawerViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        self.panGestureRecognizer.delegate = self
        self.panGestureRecognizer.cancelsTouchesInView = true
        
        self.remove(viewController: self.primaryViewController)
        self.add(childViewController: self.primaryViewController, superView: self.primaryContainer)
        
        self.remove(viewController: self.drawerViewController)
        self.add(childViewController: self.drawerViewController, superView: self.drawerContainer)
        
        self.view.addSubview(self.primaryContainer)
        self.view.addSubview(self.drawerContainer)
        
        self.drawerViewController.dragableViews.forEach { $0.addGestureRecognizer(self.panGestureRecognizer) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutViews()
    }
    
    func layoutViews() {
        self.layoutView(for: self.currentState)
    }
    
    func layoutView(for state: State) {
        let dcY = state == .open ? self.topOffset : 0
        
        self.primaryContainer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.drawerContainer.frame = CGRect(x: 0, y: dcY, width: self.view.frame.width, height: self.view.frame.height)
        
        self.primaryViewController.view.frame = self.primaryContainer.bounds
        self.drawerViewController.view.frame = self.drawerContainer.bounds
    }
    
    // MARK: - Private Methods
    
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
    
    var previousPoint: CGPoint = .zero
    var fraction: CGFloat = 0
    
    @objc private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {        
        let currentPoint = gestureRecognizer.translation(in: self.view)
 
        switch gestureRecognizer.state {
        case .began:
            self.fraction = 0
            self.previousPoint = currentPoint
            
            self.animateTransitionIfNeeded(to: currentState.opposite, duration: 0.7)
            self.runningAnimators.forEach { $0.pauseAnimation() }
            self.animationProgress = runningAnimators.map { $0.fractionComplete }
            
        case .changed:
            self.fraction = (self.previousPoint.y - currentPoint.y) / (self.view.frame.height - self.topOffset)
            if self.currentState == .closed { self.fraction *= -1 }

            for (index, animator) in self.runningAnimators.enumerated() {
                animator.fractionComplete = self.animationProgress[index] + fraction
            }
        case .failed, .ended, .cancelled:
            var isReversed = false
            let velocity = gestureRecognizer.velocity(in: self.view).y
            
            switch self.currentState {
            case .open:
                isReversed = fraction <= 0 || velocity > 0
            case .closed:
                isReversed = fraction <= 0 || velocity < 0
            }
            
            runningAnimators.first?.isReversed = isReversed
            
//            let velocity = gestureRecognizer.velocity(in: self.view).y
//            print("\(fraction) \(gestureRecognizer.velocity(in: self.view).y)")
//            runningAnimators.first?.isReversed = fraction <= 0 || velocity > 0
            
            // continue all animations
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        case .possible:
            break
        }
    }
    
    // MARK: - Animation
    
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }
        
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.75, animations: {
            self.layoutView(for: state)
        })

        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                break
            }
            
            self.layoutViews()
            self.runningAnimators.removeAll()
        }
        
        transitionAnimator.startAnimation()
        self.runningAnimators.append(transitionAnimator)
    }

}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ViewController.State {
    var opposite: ViewController.State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}



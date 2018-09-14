//
//  PassthroughScrollView.swift
//  RootViewController
//
//  Created by Anton Polyakov on 12/09/2018.
//  Copyright © 2018 Gazprombank. All rights reserved.
//

import UIKit

import UIKit

protocol PassthroughScrollViewDelegate: class {
    func shouldTouchPassthroughScrollView(scrollView: PassthroughScrollView, point: CGPoint) -> Bool
    func viewToReceiveTouch(scrollView: PassthroughScrollView, point: CGPoint) -> UIView?
}

class PassthroughScrollView: UIScrollView {
    weak var touchDelegate: PassthroughScrollViewDelegate?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard
            let touchDelegate = touchDelegate,
            let viewToReceiveTouch = touchDelegate.viewToReceiveTouch(scrollView: self, point: point),
            touchDelegate.shouldTouchPassthroughScrollView(scrollView: self, point: point)
        else {
            return super.hitTest(point, with: event)
        }
        
        return viewToReceiveTouch.hitTest(viewToReceiveTouch.convert(point, from: self), with: event)
    }
}

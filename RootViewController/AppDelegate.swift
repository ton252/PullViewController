//
//  AppDelegate.swift
//  RootViewController
//
//  Created by Anton Polyakov on 11/09/2018.
//  Copyright © 2018 Gazprombank. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)

//        let p = MapViewController()
//        p.view.backgroundColor = .green
//
//        let d = TableViewController()
//        d.view.backgroundColor = .white
//
//        let vc = RootViewController(primaryViewController: p, drawerViewController: d)
//        vc.shadowView.backgroundColor = .white
//        vc.shadowView.layer.shadowColor = UIColor.black.cgColor
//        vc.shadowView.layer.shadowOpacity = 1
//        vc.shadowView.layer.shadowOffset = CGSize.zero
//        vc.shadowView.layer.shadowRadius = 10
//
//        let vc = PullViewController()
        
        let p = UIViewController()
        let d = TableViewController()
        let vc = ViewController.init(primaryViewController: p, drawerViewController: d)
        
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
        return true
    }

}


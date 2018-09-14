//
//  MapViewController.swift
//  Drawer
//
//  Created by Anton Polyakov on 13/09/2018.
//  Copyright © 2018 Gazprombank. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.mapView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.mapView.frame = self.view.bounds
    }
}

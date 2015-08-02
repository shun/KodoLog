//
//  GoogleMapsViewController.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/08/02.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit
import GoogleMaps;

class GoogleMapsViewController: UIViewController {

    override func viewDidLoad() {
        LogTrace.sharedInstance.info(format: "");
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var camera = GMSCameraPosition.cameraWithLatitude(43.027944, longitude: 141.461893, zoom: 6)
        var mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        self.view = mapView

        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(43.027944, 141.461893)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        LogTrace.sharedInstance.info(format: "");
    }
}

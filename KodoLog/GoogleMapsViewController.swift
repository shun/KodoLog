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

    @IBOutlet weak var btnLocation: CustomButton!
    @IBOutlet weak var btnGPSCircle: CustomButton!
    @IBOutlet weak var btnLink: CustomButton!

    override func viewDidLoad() {
        LogTrace.sharedInstance.info();
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        var camera = GMSCameraPosition.cameraWithLatitude(43.027944, longitude: 141.461893, zoom: 6)
        var mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.myLocationEnabled = true
        self.view.insertSubview(mapView, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        LogTrace.sharedInstance.info();
    }

    @IBAction func touchDownLocation(sender: AnyObject) {
        btnLocation.toggle()
    }

    @IBAction func touchDownGPSCircle(sender: AnyObject) {
        btnGPSCircle.toggle()
    }

    @IBAction func touchDownLink(sender: AnyObject) {
        btnLink.toggle()
    }

    func drawoverlays() {

    }

    func drawlink() {

    }

    func drawGPSCircles() {

    }

    func drawLocationMarker() {

    }
}

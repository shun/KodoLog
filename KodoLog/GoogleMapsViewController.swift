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
    }

    override func viewWillAppear(animated: Bool) {
        LogTrace.sharedInstance.info();
        let mapView = createMapView()
        self.view.insertSubview(mapView, atIndex: 0)
    }

    override func viewDidDisappear(animated: Bool) {
        LogTrace.sharedInstance.info();
        self.view.subviews[0].removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        LogTrace.sharedInstance.info();
    }

    func createMapView() -> GMSMapView{
        var camera = GMSCameraPosition.cameraWithLatitude(43.027944, longitude: 141.461893, zoom: 6)
        var mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.myLocationEnabled = true

        return mapView
    }

    @IBAction func touchDownLocation(sender: AnyObject) {
        btnLocation.toggle()
        drawoverlays()
    }

    @IBAction func touchDownGPSCircle(sender: AnyObject) {
        btnGPSCircle.toggle()
        drawoverlays()
    }

    @IBAction func touchDownLink(sender: AnyObject) {
        btnLink.toggle()
        drawoverlays()
    }


    func drawoverlays() {
        let wrapper = CPPWrapper()
        let logpaths = SensorLogManager.sharedInstance.getLoglist()
        let lastlogpath = logpaths[logpaths.count-1]

        LogTrace.sharedInstance.debug(format: "start")
        wrapper.load(lastlogpath)
        LogTrace.sharedInstance.debug(format: "end")
        wrapper.getLine(0)
//        SensorLogManager.sharedInstance.loadLogData(lastlogpath)

    }

    func drawlink() {

    }

    func drawGPSCircles() {

    }

    func drawLocationMarker() {

    }
}

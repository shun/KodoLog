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
    private var m_mapview:GMSMapView?
    private var m_filepath:String = ""
    private let m_cppwrapper:CPPWrapper = CPPWrapper()

    override func viewDidLoad() {
        LogTrace.sharedInstance.info();
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        LogTrace.sharedInstance.info();
        let mapView = createMapView()
        self.view.insertSubview(mapView, atIndex: 0)
        m_mapview = mapView
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

    func createMapView() -> GMSMapView {
        var camera = GMSCameraPosition.cameraWithLatitude(43.027944, longitude: 141.461893, zoom: 16)
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
        m_mapview?.clear()
        let logpaths = SensorLogManager.sharedInstance.getLoglist()
        let lastlogpath = logpaths[logpaths.count-1]

        if ((m_filepath == "") || (m_filepath != lastlogpath) ){
            m_filepath = lastlogpath
            LogTrace.sharedInstance.debug(format: "start")
            m_cppwrapper.load(lastlogpath)
            LogTrace.sharedInstance.debug(format: "end")
        }

        let coords:[AnyObject] = m_cppwrapper.getCoords()
        if (btnLocation.togglests) {
        }

        if (btnGPSCircle.togglests) {
        }

        if (btnLink.togglests) {
            self.drawlink(coords)
        }
    }

    func drawlink(coords:[AnyObject]) {
        var paths: GMSMutablePath = GMSMutablePath()

        var idx: Int = 0
        for (idx = 0; idx < coords.count; idx++) {
            let coord = coords[idx] as! [String:Double]
            let para = CLLocationCoordinate2DMake(coord["latitude"]!, coord["longitude"]!)
            paths.addCoordinate(para)
        }

        let polyline = GMSPolyline(path: paths)
        polyline.map = m_mapview
    }

    func drawGPSCircles() {

    }

    func drawLocationMarker() {

    }
}

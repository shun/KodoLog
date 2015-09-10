//
//  GoogleMapsViewController.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/08/02.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit
import GoogleMaps;

class GoogleMapsViewController: UIViewController, GMSMapViewDelegate, SensorManagerDelegate, CKCalendarDelegate {

    @IBOutlet weak var btnLocation: CustomButton!
    @IBOutlet weak var btnGPSCircle: CustomButton!
    @IBOutlet weak var btnLink: CustomButton!
    @IBOutlet weak var sliderLocation: UISlider!
    @IBOutlet weak var lblLocationTime: CustomLabel!

    private var m_mapview:GMSMapView?
    private var m_filepath:String = ""
    private let m_cppwrapper:CPPWrapper = CPPWrapper()
    private var m_links:GMSPolyline?
    private var m_didMoveByOperation: Bool = false
    private var m_calendar:CKCalendarView?

    override func viewDidLoad() {
        LogTrace.sharedInstance.info();
        super.viewDidLoad()

        m_calendar = CKCalendarView(startDay: startMonday)
        m_calendar?.frame = self.view.frame
        m_calendar?.hidden = true
        m_calendar?.delegate = self
        self.view.addSubview(m_calendar!);

        // Do any additional setup after loading the view, typically from a nib.
        sliderLocation.minimumValue = 0.0
        sliderLocation.maximumValue = 0.0
        sliderLocation.addTarget(self, action: "sliderChangedLocation:", forControlEvents: UIControlEvents.ValueChanged)

        lblLocationTime.hidden = true

    }

    override func viewWillAppear(animated: Bool) {
        LogTrace.sharedInstance.info();
        let mapView = createMapView()
        self.view.insertSubview(mapView, atIndex: 0)
        m_mapview = mapView
        m_mapview?.delegate = self
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
        let coordinate = SensorManager.sharedInstance.lastlocation
        var camera = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude: coordinate.longitude, zoom: 16)
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


    func clearOverlays() {
        m_mapview?.clear()
        if (btnLocation.togglests) {
            btnLocation.toggle()
        }

        if (btnGPSCircle.togglests) {
            btnGPSCircle.toggle()
        }

        if (btnLink.togglests) {
            btnLink.toggle()
        }
    }

    func drawoverlays() {
        m_mapview?.clear()

        let items:[AnyObject] = m_cppwrapper.getItems()
        if (btnLocation.togglests) {
        }

        if (btnGPSCircle.togglests) {
            self.drawGPSCircles(items)
        }

        if (btnLink.togglests) {
            self.drawlink(items)
        }
    }

    func drawlink(items:[AnyObject]) {
        if (m_links != nil) {
            m_links?.map = m_mapview;
            return
        }

        var paths: GMSMutablePath = GMSMutablePath()

        var idx: Int = 0
        for (idx = 0; idx < items.count; idx++) {
            let item = items[idx] as! [String:Double]
            let para = CLLocationCoordinate2DMake(item["latitude"]!, item["longitude"]!)
            paths.addCoordinate(para)
        }

        let polyline = GMSPolyline(path: paths)
        polyline.map = m_mapview
    }

    func drawGPSCircles(items:[AnyObject]) {
        var idx: Int = 0

        for (idx = 0; idx < items.count; idx++) {
            let item = items[idx] as! [String:Double]
            let center = CLLocationCoordinate2DMake(item["latitude"]!, item["longitude"]!)
            if (item["haccuracy"]! <= 0) {
                continue
            }
            var circle = GMSCircle(position: center, radius: item["haccuracy"]!)
            circle.strokeColor = UIColor.redColor()
            circle.map = m_mapview;
        }
    }

    func drawLocationMarker(item:Dictionary<NSObject, AnyObject>) {
        let position = CLLocationCoordinate2DMake(item["latitude"] as! Double, item["longitude"] as! Double);
        var marker = GMSMarker(position: position)
        let datetime:[String] = (item["time"] as! String).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        marker.title = datetime[1];
        marker.flat = true
        marker.map = m_mapview;
        m_mapview?.selectedMarker = marker
    }

    func sliderChangedLocation(sender: UISlider) {
        if let item = m_cppwrapper.getItem(UInt(sender.value)) {
            updateCurrentPosition(CLLocationCoordinate2DMake(item["latitude"] as! Double, item["longitude"] as! Double))
            let datetime:[String] = (item["time"] as! String).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            showTip("Here", message: datetime[1])
        }
    }

    func showTip(title: String, message: String) {
        if (lblLocationTime.hidden == true) {
            lblLocationTime.hidden = false
        }
        lblLocationTime.text = message
    }


    @IBAction func showCalendar(sender: AnyObject) {
        m_calendar?.hidden = false
    }

    func updateCurrentPosition(coordinate: CLLocationCoordinate2D) {
        var updatedcamera = GMSCameraUpdate.setTarget(coordinate)
        m_mapview?.moveCamera(updatedcamera)
    }

    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
//        LogTrace.sharedInstance.info(format:"%f/%f", arguments:coordinate.latitude, coordinate.longitude)
        m_calendar?.hidden = true
    }

    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
//        LogTrace.sharedInstance.info()
        m_didMoveByOperation = true
        lblLocationTime.hidden = true
        m_calendar?.hidden = true
    }

    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        m_didMoveByOperation = false
        m_calendar?.hidden = true
        return false
    }

    func calendar(calendar: CKCalendarView!, configureDateItem dateItem: CKDateItem!, forDate date: NSDate!) {
        let filter = Utility.getDateTimeString(date, format: "yyyyMMdd")
        let list = SensorLogManager.sharedInstance.getDateList(filter)

        if (list.count == 0) {
            return
        }

        dateItem.backgroundColor = Utility.getColorByRGB(249, g: 191,b: 69)
    }

    func calendar(calendar: CKCalendarView!, didSelectDate date: NSDate!) {
        if (date == nil) {
            m_calendar?.hidden = true
            return
        }

        let datestring = Utility.getDateTimeString(date, format: "yyyyMMdd")
        LogTrace.sharedInstance.info(format: "select : %@", arguments:datestring)

        let logpath = SensorLogManager.sharedInstance.getLoglist(datestring)

        if (logpath.count == 0) {
            // ありえん
            m_cppwrapper.clear()
            m_calendar?.hidden = true
            drawoverlays()
            return
        }

        if ((m_filepath == "") || (m_filepath != logpath[0]) ){
            m_filepath = logpath[0]
            LogTrace.sharedInstance.debug(format: "start")
            m_cppwrapper.load(logpath[0])
            LogTrace.sharedInstance.debug(format: "end")
            sliderLocation.maximumValue = Float(m_cppwrapper.getSize() - 1);
        }
        m_calendar?.hidden = true
        drawoverlays()
    }

    func updateLocation(coordinate: CLLocationCoordinate2D) {
        LogTrace.sharedInstance.info()
        if (m_didMoveByOperation == true) {
            // スクロール中などは現在地を追従しない
            return
        }
        updateCurrentPosition(coordinate)
    }
}

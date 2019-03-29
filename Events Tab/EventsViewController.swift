//
//  EventsViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import GoogleMaps
import FloatingPanel

class EventsViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    private let locationManager = CLLocationManager()
    
    var fpc: FloatingPanelController!
    var eventsVC: BookmarkedEventsViewController!
    
    var swipeUpImg = UIImageView()
    var swipeDownImg = UIImageView()
    
    var bookmarkedEvents: [BookmarkedEvent] = [] {
        didSet {
            eventsVC.bookmarkedEvents = bookmarkedEvents
        }
    }

    var tappedMarker: GMSMarker?
    var infoWindow: InfoWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        setupFPC()
        
        infoWindow = InfoWindow(eventTitle: "123", date: "123", bookmarkCount: "123")
        
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2DMake(22.301603, 114.182119)
            let marker = MapMarker(name: "1234567890", icon: UIImage(named: "gif6_thumbnail")!)
            //let marker = GMSMarker()
            marker.position = position
            marker.tracksViewChanges = false
            marker.title = "Hello World"
            marker.snippet = "DLLMCH"
            marker.map = self.mapView
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
}


//MARK: Network calls
extension EventsViewController {
    private func getBookmarkedEvents() {
        EventService.getBookmarkedEvents().done { response in
            self.bookmarkedEvents = response.bookmarkedEventsList.reversed()
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //if let completion = completion { completion() }
            }.catch { error in }
    }
}

//MARK: UISetup
extension EventsViewController {
    private func setupUI() {
    }
    
    private func setupNavBar() {
        navigationItem.title = "Events"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray()]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        //navigationController?.navigationBar.barTintColor = .darkGray()
    }
}

//MARK: Google Maps
extension EventsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        tappedMarker = marker
        
        let pos = marker.position
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.75)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
        mapView.animate(toLocation: pos)
        CATransaction.commit()
        
//        let point = mapView.projection.point(for: pos)
//        let newPoint = mapView.projection.coordinate(for: point)
//        let camera = GMSCameraUpdate.setTarget(newPoint)
        
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(0.7)
//        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
//        mapView.animate(with: camera)
//        CATransaction.commit()
        
        infoWindow?.center = mapView.projection.point(for: pos)
        infoWindow?.center.y -= 170
        mapView.addSubview(infoWindow!)
        UIView.animate(withDuration: 0.2) {
            self.infoWindow?.alpha = 1
        }
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2, animations: { self.infoWindow?.alpha = 0 }) { _ in
            self.infoWindow?.removeFromSuperview()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if let tappedMarker = tappedMarker {
            let pos = tappedMarker.position
            infoWindow?.center = mapView.projection.point(for: pos)
            infoWindow?.center.y -= 170
        }
    }
}

//MARK: Floating Panel
extension EventsViewController: FloatingPanelControllerDelegate {
    private func setupFPC() {
        // Initialize FloatingPanelController
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        swipeUpImg.image = UIImage(named: "icon_swipe_up")
        swipeUpImg.bounceUpRepeat()
        
        swipeDownImg.image = swipeUpImg.image?.rotate(radians: .pi) //rotate 180 degrees
        swipeDownImg.bounceDownRepeat()
        
        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.grabberHandle.isHidden = true
        fpc.surfaceView.addSubview(swipeUpImg)
        swipeUpImg.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        swipeDownImg.alpha = 0
        fpc.surfaceView.addSubview(swipeDownImg)
        swipeDownImg.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        fpc.surfaceView.cornerRadius = 30
        fpc.surfaceView.shadowHidden = false
        
        // Set a content view controller and track the scroll view
        let eventsVC = storyboard?.instantiateViewController(withIdentifier: "bookmarkedEventsVC") as! BookmarkedEventsViewController
        fpc.set(contentViewController: eventsVC)
        //        eventsVC.textView.delegate = self // MUST call it before fpc.track(scrollView:)
        fpc.track(scrollView: eventsVC.eventsCollectionView)
        self.eventsVC = eventsVC
        
        //  Add FloatingPanel to self.view
        fpc.addPanel(toParent: self)
    }
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        print("dragging panel!")
    }

    func floatingPanelDidChangePosition(_ vc: FloatingPanelController) {
        swipeUpImg.alpha = vc.position == .full ? 0 : 1
        swipeDownImg.alpha = vc.position == .full ? 1 : 0
        
        switch vc.position {
        case .full:
            print("full now!")
                if self.bookmarkedEvents.isEmpty {
                    DispatchQueue.main.async { self.getBookmarkedEvents() }
            }
            
            eventsVC.eventsCollectionView.alpha = 1
            
        case .tip:
            print("tip now!")
            eventsVC.eventsCollectionView.alpha = 0
        default:
            print("unknown position?")
        }
    }
    
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return MyFloatingPanelLayout()
    }
    
    func floatingPanel(_ vc: FloatingPanelController, behaviorFor newCollection: UITraitCollection) -> FloatingPanelBehavior? {
        return MyFloatingPanelBehavior()
    }
}

//MARK: CLLocationManager Delegate
extension EventsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 13, bearing: 0, viewingAngle: 0)
        
        locationManager.stopUpdatingLocation()
    }
}

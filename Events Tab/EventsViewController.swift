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
import fluid_slider

class EventsViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    private let locationManager = CLLocationManager()
    
    var searchRadius = 2000 //meters
    var currentLocation: CLLocationCoordinate2D! {
        didSet {
            let lat = currentLocation.latitude
            let long = currentLocation.longitude

            //prevent duplicate calls
            if oldValue == nil || (lat != oldValue.latitude && long != oldValue.longitude) {
                getNearbyEvents(lat: lat, long: long, radius: searchRadius)
            }
        }
    }
    
    var filterBtn: UIButton!
    var filterMenuView: UIView!
    var radiusSlider = Slider()
    
    var fpc: FloatingPanelController!
    var eventsVC: BookmarkedEventsViewController!
    
    var swipeUpImg = UIImageView()
    var swipeDownImg = UIImageView()
    
    var bookmarkedEvents: [BookmarkedEvent] = [] {
        didSet {
            eventsVC.bookmarkedEvents = bookmarkedEvents
        }
    }

    var nearbyEventsCountLabel: UILabel!
    var nearbyEvents: [NearbyEvent] = [] {
        didSet {
            UIView.transition(with: nearbyEventsCountLabel, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                self.nearbyEventsCountLabel.text = "\(self.nearbyEvents.count) nearby events"
                self.nearbyEventsCountLabel.snp.updateConstraints({ (make) in
                    make.width.equalTo(self.nearbyEventsCountLabel.intrinsicContentSize.width)
                })
            }, completion: { _ in
                if self.filterBtn == nil && self.filterMenuView == nil {
                    self.setupFilterBtn()
                    self.setupFilterMenu()
                }
            })
            
            loadNearbyMarkers()
        }
    }

    var eventDetails: EventDetails?
    
    var tappedMarker: GMSMarker?
    var currentMarkerPosition: CLLocationCoordinate2D?
    var currentVisibleMarkersEventId = [String]()
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
        
        setupUI()
        setupFPC()
    }
  
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.layer.removeAllAnimations()
    }
    
}

//MARK: Network calls
extension EventsViewController {
    private func getBookmarkedEvents() {
        EventService.getBookmarkedEvents().done { response in
            self.bookmarkedEvents = response.list.reversed()
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //if let completion = completion { completion() }
            }.catch { error in }
    }
    
    private func getNearbyEvents(lat: Double, long: Double, radius: Int) {
        EventService.getNearbyEvents(lat: lat, long: long, radius: radius).done { response in
            self.nearbyEvents = response.list
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    private func showInfoWindow(withId id: String, position: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            if self.infoWindow != nil {
                if (self.infoWindow?.isDescendant(of: self.view))! { //infoWindow is visible
                    UIView.animate(withDuration: 0.2, animations: { self.infoWindow?.alpha = 0 }) { _ in
                        self.infoWindow?.removeFromSuperview()
                    }
                }
            }
            
            let lat = position.latitude
            let long = position.longitude
            
            EventService.getEventDetails(eventId: id).done { event in
                if let event = event.item {
                    let venue: String
                    venue = (event.venue?.isEmpty)! ? "\(String(format: "%.5f", lat)) \(String(format: "%.5f", long))" : event.venue!
                    
                    //Calculate distance
                    var distance: Double = 0
                    if !self.nearbyEvents.isEmpty {
                        for event in self.nearbyEvents { //get distance in nearbyEvents because eventDetails didn't provide distance
                            if let nearById = event.id {
                                if id == nearById {
                                    if let eventDistance = event.distance { distance = eventDistance }
                                }
                            }
                        }
                    }
                    let distanceStr: String?
                    if distance <= 999 && distance != 0 { //calculate meters
                        distanceStr = "\(Int(distance))M"
                    } else if distance == 0 || Int(distance) > self.searchRadius { //location is empty OR distance is bigger than searchRadius
                        distanceStr = ">\(self.searchRadius / 1000)KM"
                    } else { //calculate kilometers
                        distanceStr = "\(String(format: "%.1f", distance / 1000))KM"
                    }
                    
                    self.infoWindow = InfoWindow(eventTitle: event.title!, date: event.dateTime!, desc: event.desc!, venue: venue, distance: distanceStr ?? "0")
                    self.infoWindow?.delegate = self
                    //self.infoWindow?.center = self.mapView.projection.point(for: (self.tappedMarker?.position)!)
                    self.infoWindow?.eventId = id
                    self.infoWindow?.center = self.mapView.projection.point(for: position)
                    self.infoWindow?.center.y -= 190
                    self.mapView.addSubview(self.infoWindow!)
                    UIView.animate(withDuration: 0.2) {
                        self.infoWindow?.alpha = 1
                    }
                }
                
                }.ensure {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }.catch { error in }
        }
    }
}

//MARK: UISetup
extension EventsViewController {
    private func setupUI() {
        nearbyEventsCountLabel = UILabel()
        nearbyEventsCountLabel.textColor = UIColor(hexString: "#6F7179")
        nearbyEventsCountLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nearbyEventsCountLabel.text = "Loading..."
        view.addSubview(nearbyEventsCountLabel)
        nearbyEventsCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-12)
            make.height.equalTo(29)
            //make.width.equalTo(nearbyEventsCountLabel.intrinsicContentSize.width)
            make.width.equalTo(200)
            
            switch UIDevice.current.type { //This is a very dumb method... please replace this if there are better soultions...
            case .iPhone_5_5S_5C_SE, .iPhone_6_6S_7_8, .iPhone_X_Xs:
                make.left.equalToSuperview().offset(17)
            case .iPhone_6_6S_7_8_PLUS, .iPhone_Xr, .iPhone_Xs_Max:
                make.left.equalToSuperview().offset(21)
            default: print("cannot create nearbyEventsCountLabel")
            }
        }
    }
    
    private func setupFilterBtn() {
        filterBtn = UIButton()
        let swipeDownImg = UIImage(named: "icon_swipe_down")
        let tintedImg = swipeDownImg!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        filterBtn.setImage(tintedImg, for: .normal)
        filterBtn.tintColor = UIColor(hexString: "#6F7179")
        filterBtn.setTitle("", for: .normal)
        filterBtn.addTarget(self, action: #selector(filterBtnTapped), for: .touchUpInside)
        view.addSubview(filterBtn)
        filterBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(nearbyEventsCountLabel.snp.bottom).offset(1)
            make.size.equalTo(27)
            make.left.equalTo(nearbyEventsCountLabel.snp.right).offset(4)
        }
        
    }
    
    @objc func filterBtnTapped() {
        UIView.animate(withDuration: 0.2) {
            self.filterMenuView.alpha = self.filterMenuView.alpha == 0 ? 1 : 0
        }
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
    }
}

//MARK: Filter Dropdown menu
extension EventsViewController {
    private func setupFilterMenu() {
        let width = nearbyEventsCountLabel.intrinsicContentSize.width + 31 // 31 = filterBtn offset + width
        filterMenuView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: 100)))
        filterMenuView.alpha = 0
        filterMenuView.dropShadow(color: .black, opacity: 0.65, offSet: CGSize(width: -1, height: 1), radius: GlobalCornerRadius.value, scale: true)
        filterMenuView.layer.cornerRadius = GlobalCornerRadius.value
        filterMenuView.backgroundColor = .darkGray()
        view.addSubview(filterMenuView)
        filterMenuView.snp.makeConstraints { (make) in
            make.top.equalTo(nearbyEventsCountLabel.snp.bottom).offset(5)
            make.left.equalTo(nearbyEventsCountLabel.snp.left)
            make.height.equalTo(100)
            make.width.equalTo(width)
        }

        let radiusImgView = UIImageView()
        radiusImgView.image = UIImage(named: "icon_radar")
        filterMenuView.addSubview(radiusImgView)
        radiusImgView.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.size.equalTo(20)
        }
        
        let radiusLabel = UILabel()
        radiusLabel.text = "Radius (KM)"
        radiusLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        radiusLabel.textColor = .white
        filterMenuView.addSubview(radiusLabel)
        radiusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(radiusImgView.snp.right).offset(4)
            make.centerY.equalTo(radiusImgView.snp.centerY)
        }
        
        let labelTextAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.white]
        radiusSlider.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 2
            formatter.maximumFractionDigits = 1
            let string = formatter.string(from: (fraction * 10) as NSNumber) ?? ""
            return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor(hexString: "#11998E")])
        }
        radiusSlider.setMinimumLabelAttributedText(NSAttributedString(string: "0", attributes: labelTextAttributes))
        radiusSlider.setMaximumLabelAttributedText(NSAttributedString(string: "10", attributes: labelTextAttributes))
        radiusSlider.fraction = CGFloat(searchRadius) / 10000
        radiusSlider.contentViewColor = UIColor(hexString: "#11998E")
        radiusSlider.valueViewColor = .white
        filterMenuView.addSubview(radiusSlider)
        radiusSlider.snp.makeConstraints { (make) in
            make.width.equalTo(width - 20)
            make.top.equalTo(radiusImgView.snp.bottom).offset(18)
            make.height.equalTo(40)
            make.left.equalTo(10)
        }
        
        updateNearbyEvents()
    }
    
    //Update nearby events with new radius
    private func updateNearbyEvents() {
        radiusSlider.didEndTracking = { [weak self] _ in
            let value = String(format: "%.2f", (self?.radiusSlider.fraction)!)
            let meter = Int(Float(value)! * 10000)
            print(meter)
            if meter != self?.searchRadius {
                self?.searchRadius = meter
                if let lat = self?.currentLocation.latitude, let long = self?.currentLocation.longitude {
                    
                    //clear all views on map
                    DispatchQueue.main.async {
                        self?.mapView.clear()
                        self?.currentVisibleMarkersEventId.removeAll()
                        if self?.infoWindow != nil {
                            if self?.infoWindow!.alpha != 0 {
                                self?.infoWindow!.alpha = 0
                                self!.infoWindow?.removeFromSuperview()
                            }
                        }
                    }

                    //update with new radius
                    self?.getNearbyEvents(lat: lat, long: long, radius: meter)
                }
            }
        }
    }
}

//MARK: Google Maps
extension EventsViewController: GMSMapViewDelegate, InfoWindowDelegate, BookmarkedEventsViewControllerDelegate {
    private func addMarker(id: String, lat: Double, long: Double, performerName: String, iconUrl: String) {
        DispatchQueue.main.async {
            print("Creating \(id) marker...")
            let position = CLLocationCoordinate2DMake(lat, long)
            let marker = MapMarker(name: performerName)
            marker.opacity = 0
            marker.performerIcon.kf.setImage(with: URL(string: iconUrl)) { result in
                switch result {
                case .success(_):
                    marker.title = id //set id as title for tapped action
                    marker.position = position
                    marker.tracksViewChanges = false
                    marker.map = self.mapView
                    
                    self.currentVisibleMarkersEventId.append(id)
                    UIView.animate(withDuration: 0.2, animations: { marker.opacity = 1 })
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func loadNearbyMarkers() {
        if !nearbyEvents.isEmpty {
            for event in nearbyEvents {
                if let id = event.id {
                    if !currentVisibleMarkersEventId.contains(id) { //check if marker was already added
                        guard let lat = event.location?.coordinates[1] else { fatalError("event lat is not set?") }
                        guard let long = event.location?.coordinates[0] else { fatalError("event long is not set?") }
                        let name = event.organizerProfile?.name
                        let url = event.organizerProfile?.coverImages.randomElement()?.secureUrl
                        
                        addMarker(id: id, lat: lat, long: long, performerName: name!, iconUrl: url!)
                    } else {
                        print("Marker is already visible on map")
                    }
                }
            }
        }
    }
    
    func cellTapped(lat: Double, long: Double, iconUrl: String, name: String, id: String) {
        let position = CLLocationCoordinate2DMake(lat, long)
        
        currentMarkerPosition = position
        tappedMarker = nil
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.75)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
        mapView.animate(toLocation: position)
        CATransaction.commit()
        
        if !currentVisibleMarkersEventId.contains(id) {
            addMarker(id: id, lat: lat, long: long, performerName: name, iconUrl: iconUrl)
        } else {
            print("Marker is already visible on map")
        }
        
        if filterMenuView.alpha != 0 {
            UIView.animate(withDuration: 0.2) {
                self.filterMenuView.alpha = 0
            }
        }
        
        if infoWindow?.alpha == 0 || (infoWindow?.eventId != id) {
            showInfoWindow(withId: id, position: position)
        }
        
        fpc.move(to: .half, animated: true)
    }
    
    func infoWindowMoreBtnTapped() {
        if let id = tappedMarker?.title {
            EventDetailsViewController.push(fromView: self, eventId: id)
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if filterMenuView.alpha != 0 { //first hide filter menu if its not hidden
            UIView.animate(withDuration: 0.2) {
                self.filterMenuView.alpha = 0
            }
        }
        
        if marker != tappedMarker || infoWindow?.alpha == 0 { //prevent the same marker is tapped
            tappedMarker = marker
            currentMarkerPosition = nil
            
            let pos = marker.position
            
            //        var point = mapView.projection.point(for: pos)
            //        point.y = point.y - 200
            //        let newPoint = mapView.projection.coordinate(for: point)
            //        let camera = GMSCameraUpdate.setTarget(newPoint)
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.75)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
            mapView.animate(toLocation: pos)
            CATransaction.commit()
            
            //hide nav bar title on smaller devices
            if UIDevice.current.type == .iPhone_5_5S_5C_SE || UIDevice.current.type == .iPhone_6_6S_7_8 || UIDevice.current.type == .iPhone_X_Xs {
                let fadeTextAnimation = CATransition()
                fadeTextAnimation.duration = 0.2
                fadeTextAnimation.type = CATransitionType.fade
                navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
                navigationItem.title = ""
                
                UIView.animate(withDuration: 0.2) { self.nearbyEventsCountLabel.alpha = 0 }
            }
            
            //first remove existing infoWindow
            UIView.animate(withDuration: 0.2, animations: { self.infoWindow?.alpha = 0 }) { _ in
                self.infoWindow?.removeFromSuperview()
            }
            
            if let id = marker.title {
                showInfoWindow(withId: id, position: pos)
            }
        }

        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //revert change of nav bar title on smaller devices
        if UIDevice.current.type == .iPhone_5_5S_5C_SE || UIDevice.current.type == .iPhone_6_6S_7_8 || UIDevice.current.type == .iPhone_X_Xs {
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 0.2
            fadeTextAnimation.type = CATransitionType.fade
            navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
            navigationItem.title = "Events"
            
            UIView.animate(withDuration: 0.2) { self.nearbyEventsCountLabel.alpha = 1 }
        }
        
        if filterMenuView.alpha != 0 { //first hide filter menu if its not hidden
            UIView.animate(withDuration: 0.2) {
                self.filterMenuView.alpha = 0
            }
        } else { //then check if need hide info window
            if infoWindow != nil {
                if !(infoWindow?.isDescendant(of: view))! { //infoWindow not visible
                    if fpc.position != .tip {
                        fpc.move(to: .tip, animated: true)
                    }
                } else { //infoWindow is visible
                    UIView.animate(withDuration: 0.2, animations: { self.infoWindow?.alpha = 0 }) { _ in
                        self.infoWindow?.removeFromSuperview()
                    }
                }
            }
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if let tappedMarker = tappedMarker {
            let pos = tappedMarker.position
            infoWindow?.center = mapView.projection.point(for: pos)
            infoWindow?.center.y -= 190
        } else if let currentMarkerPosition = currentMarkerPosition {
            infoWindow?.center = mapView.projection.point(for: currentMarkerPosition)
            infoWindow?.center.y -= 190
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
        swipeDownImg.image = UIImage(named: "icon_swipe_down")
        
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
        eventsVC.delegate = self
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
            
        case .half:
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
        currentLocation = location.coordinate
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
        
        locationManager.stopUpdatingLocation()
    }
}

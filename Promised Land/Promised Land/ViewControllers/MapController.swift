//
//  MapController.swift
//  Promised Land
//
//  Created by Dai Pham on 3/20/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController {
    
    // MARK: - api
    func getStation(from team:Team) {
        
        if currentStation != nil {
            print("Mark old region isFinish")
            currentStation!.isFinish = true
            MonitorLocation.shared.stopMonitoring()
            MonitorLocation.shared.clCircularRegions.removeAll()
            if let team = self.team {
                for (i,st) in team.station.enumerated() {
                    if st.id == currentStation!.id {
                        team.station[i] = currentStation!
                        self.team = team
                        Support.setCacheTeam(data: team.toDict())
                        currentStation = nil
                        break
                    }
                }
            }
        }
        
        for station in team.station {
            if station.isFinish {
                continue
            }
            
            if let _ = station.location {
                currentStation = station
                print("prepare next location. start show message")
                guard let st = currentStation else {
                    // should show message end Game
                    self.showMessage(title: "Congratulations", message: "Congratulations to the team on goal", isStart: false)
                    break
                }
                self.showMessage(title: st.title, message: st.message,isStart: true)
                break
            }
        }
        
        // go over all region
        if currentStation == nil {
            // should show message end Game
            self.showMessage(title: "Congratulations", message: "Congratulations to the team on goal", isStart: false)
        }
    }
    
    // MARK: - action
    func touchQuestion(_ sender:UIButton) {
        sender.isHidden = true
        guard let station = currentStation else { return }
        self.showMessage(title: station.title, message: station.message, isStart: true)
    }
    
    func tapAction(_ gestureReconizer:UITapGestureRecognizer) {
        let location = gestureReconizer.location(in:mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        // Add annotation:
        MonitorLocation.shared.getPlaceMark(from: coordinate) { [weak self] placemark in
            guard let _self = self else {return}
            if let placeMark = placemark {
                _self.dropPinZoomIn(placemark: MKPlacemark(placemark: placeMark))
            }
        }
    }
    
    func getDirections(_ sender:UIButton) {
        if let selectedPin = selectedPin {
            
            let request = MKDirectionsRequest()
            request.source = MKMapItem.forCurrentLocation()
            let mapItem = MKMapItem(placemark: selectedPin)
            request.destination = mapItem
            request.transportType = MKDirectionsTransportType.any
            request.requestsAlternateRoutes = true
            let directions = MKDirections(request: request)
            
            directions.calculate(completionHandler: {[weak self] (response, err) in
                guard let _self = self else {return}
                guard let response = response else {
                    //handle the error here
                    return
                }
                
                _self.currentRoutes = response.routes
                for (_,route) in response.routes.enumerated() {
                    _self.mapView.add(route.polyline)
                    
                }
            })
        }
    }
    
    // MARK: - private
    private func  listernEvent() {
        
        let appdelegate =  UIApplication.shared.delegate as! AppDelegate
        appdelegate.onWillEnterForceground = {[weak self] in
            guard let _self = self else {return}
            _self.monitorEvent()
        }
        
        appdelegate.onOpenAppFromNotification = {[weak self] in
            guard let _self = self, let team = _self.team else {return}
            _self.getStation(from: team)
        }
    }
    
    private func monitorEvent() {
        MonitorLocation.shared.onDidEnterRegion = {[weak self] in
            guard let _self = self, let team = _self.team else {return}
            _self.getStation(from: team)
        }
    }
    
    private func showMessage(title:String, message:String,isStart:Bool) {
        let vc = MessageController(nibName: "MessageController", bundle: Bundle.main)
        vc.titleMessage = title
        vc.message = message
        vc.shouldShowStartButton = isStart
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }
    
    fileprivate func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        
        // clear existing pins & overlays
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    private func config() {
        
        searchBar.delegate = self
        mapView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        
        btnQuestion.isHidden = true
        btnQuestion.addTarget(self, action: #selector(touchQuestion(_:)), for: .touchUpInside)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        
        mapView.showsUserLocation = true
        mapView.showsBuildings = false
        mapView.showsTraffic = false
        
    }
    
    fileprivate func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        monitorEvent()
        listernEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        MonitorLocation.shared.onCurrentLocation = {[weak self] location in
//            guard let _self = self else {return}
//
//        }
        
        if self.team == nil {
            if let json = Support.getCacheTeam, let tt = Team.parseFromJSON(json) {
                self.team = tt
            }
        }
        
        guard let team = self.team else {
            Support.changeRootControllerTo(viewcontroller: UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "teamController"))
            return
        }
        
        getStation(from: team)
    }
    
    // MARK: - closures
    
    // MARK: - properties
    var selectedPin:MKPlacemark? = nil
    var currentRoutes:[MKRoute] = []
    var matchingItems:[MKMapItem] = []
    var team:Team?
    var currentStation:Station?
    var shouldShowStart:Bool = true //check user has start next sattion
    
    // MARK: - outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnQuestion: UIButton!
    @IBOutlet weak var trailingSearchBar: NSLayoutConstraint!
}

// MARK: -
extension MapController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation.isKind(of:MKUserLocation.self) {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        var pinView: MKAnnotationView
        let reuseId = "pin"
        if let dequepinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) {
            dequepinView.annotation = annotation
            pinView = dequepinView
        } else {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.canShowCallout = true
        }
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(#imageLiteral(resourceName: "direction").resizeImageWith(newSize: CGSize(width: 20, height: 20)), for: .normal)
        button.addTarget(self, action: #selector(getDirections(_:)), for: .touchUpInside)
        pinView.leftCalloutAccessoryView = button
        pinView.image = #imageLiteral(resourceName: "pin").resizeImageWith(newSize: CGSize(width: 20, height: 20)).tint(with: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1))
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if let first = view.annotation, let selectedPin = self.selectedPin {
                if first.coordinate.latitude == selectedPin.coordinate.latitude && first.coordinate.longitude == selectedPin.coordinate.longitude {
                    mapView.selectAnnotation(first, animated: false)
                    break
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        for (i,route) in currentRoutes.enumerated() {
            let myLineRenderer = MKPolylineRenderer(polyline: route.polyline)
            if i == 0 {
                myLineRenderer.strokeColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).withAlphaComponent(0.7) as UIColor
            } else {
                myLineRenderer.strokeColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.3) as UIColor
            }
            myLineRenderer.lineWidth = 5
            return myLineRenderer
        }
        return MKPolylineRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: -
extension MapController:MesssageControllerDelegate {
    
    func messageControllerStart() {
        print("start tracking current station")
        
        guard let station = currentStation, let location = station.location else { return }
        MonitorLocation.shared.stopMonitoring()
        let region = CLCircularRegion(center: CLLocationCoordinate2DMake(location.latitude, location.longitude), radius: 200, identifier: CURRENT_REGION)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        MonitorLocation.shared.clCircularRegions = [region]
        MonitorLocation.shared.startMonitoring()
    }
    
    func messageControllerShouldMinimize() {
        print("minimize question")
        btnQuestion.isHidden = false
        
    }
    
    func messageControllerExitZone() {
        
    }
}

// MARK: -
extension MapController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.isHidden =  self.matchingItems.count == 0
            self.tableView.reloadData()
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.trailingSearchBar.constant = 0
            searchBar.searchBarStyle = .default
            self.view.layoutIfNeeded()
        })
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        tableView.isHidden = true
        searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.2, animations: {
            self.trailingSearchBar.constant = 60
            searchBar.searchBarStyle = .minimal
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: -
extension MapController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.matchingItems[indexPath.row]
        self.dropPinZoomIn(placemark:item.placemark)
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        tableView.isHidden = true
        searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.2, animations: {
            self.trailingSearchBar.constant = 60
            self.searchBar.searchBarStyle = .minimal
            self.view.layoutIfNeeded()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let item = matchingItems[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: item.placemark)
        return cell
    }
}

// MARK: -
extension MapController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
            if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.isEnabled = true
            }
        }
    }
}

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
    
    // MARK: - action
    func tapAction(_ gestureReconizer:UITapGestureRecognizer) {
        let location = gestureReconizer.location(in:mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        // Add annotation:
        MonitorLocation.shared.getPlaceMark(from: coordinate) { [weak self] placemark in
            guard let _self = self else {return}
            if let placeMark = placemark {
                let region = CLCircularRegion(center: coordinate, radius: 50, identifier: CURRENT_REGION)
                region.notifyOnEntry = true
                region.notifyOnExit = true
                MonitorLocation.shared.clCircularRegions = [region]
                MonitorLocation.shared.stopMonitoring()
                MonitorLocation.shared.startMonitoring()
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
            guard let _self = self else {return}
            _self.showMessage()
        }
    }
    
    private func monitorEvent() {
        MonitorLocation.shared.onDidEnterRegion = {
            self.showMessage()
        }
    }
    
    private func showMessage() {
        if !MonitorLocation.shared.isEnteringRegion {return}
        let vc = MessageController(nibName: "MessageController", bundle: Bundle.main)
        vc.titleMessage = "Hey"
        vc.message = "Please read the answer from question?"
        self.present(vc, animated: false, completion: nil)
        vc.onDissmiss = {[weak self] in
            guard let _self = self else {return}
            MonitorLocation.shared.stopMonitoring()
        }
    }
    
    private func dropPinZoomIn(placemark:MKPlacemark){
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
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    private func config() {
        
        searchBar.delegate = self
        mapView.delegate = self
        
        MonitorLocation.shared.onCurrentLocation = {[weak self] location in
            guard let _self = self else {return}
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            _self.mapView.setRegion(region, animated: true)
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
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
    
    // MARK: - closures
    
    // MARK: - properties
    var selectedPin:MKPlacemark? = nil
    var currentRoutes:[MKRoute] = []
    var matchingItems:[MKMapItem] = []
    
    // MARK: - outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
}

// MARK: -
extension MapController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation.isKind(of:MKUserLocation.self) {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(#imageLiteral(resourceName: "direction").resizeImageWith(newSize: CGSize(width: 20, height: 20)), for: .normal)
        button.addTarget(self, action: #selector(getDirections(_:)), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
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
            print(self.matchingItems)
        }
    }
}

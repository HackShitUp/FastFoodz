//
//  MapViewController.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation





class MapViewController: UIViewController {
    
    // MARK: - Class Vars

    // MARK: - UIPanGestureRecognizer
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - MKMapView
        mapView.showsUserLocation = true
        mapView.delegate = self

        // MARK: - UIPanGestureRecognizer
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMapViewPanGesture(_:)))
        panGestureRecognizer.delegate = self
        mapView.addGestureRecognizer(panGestureRecognizer)
    }
    
    /// Handle the pan gesture for the map view
    /// - Parmaeter sender: Any object that calls this method
    @objc func handleMapViewPanGesture(_ sender: UIPanGestureRecognizer) {
//        let fourthFrame = CGRect(x: UIScreen.main.bounds.width - (UIScreen.main.bounds.width/4.0), y: 0.0, width: UIScreen.main.bounds.width/4.0, height: UIScreen.main.bounds.height)
//        let location = sender.location(in: nil)
//        let translation = sender.translation(in: nil)
//
//        switch sender.state {
//        case .began:
//            // MARK: - Mapview
//            // Enable/Disable the scroll view
//            mapView.isScrollEnabled = fourthFrame.contains(location) ? false : true
//        default:
//            // MARK: - Mapview
//            // Enable/Disable the scroll view
//            mapView.isScrollEnabled = sender.state == .changed ? false : true
//
//            // MARK: - UIScrollView
//            // Hack since we know this view's superview is a scroll view
//            (view.superview as? UIScrollView)?.contentOffset = CGPoint(x: translation.x, y: 0.0)
//        }
    }
    
    /// Add the annotations to the MKMapView by using the MainData
    func addAnnotationsWithCurrentLocation() {
        // MARK: - CLLocation
        if let location = MainData.currentLocation {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, latitudinalMeters: CLLocationDistance(1_000), longitudinalMeters: CLLocationDistance(1_000))
            // MARK: - MKMapView
            self.mapView.setRegion(region, animated: false)
            
            // Only execute the following codeblock if we haven't already fetched nearby places
            guard MainData.nearbyPlaces.isEmpty else {
                print("\(#file)/\(#line) - MainData already has Place objects")
                return
            }
            
            //  MARK: - YelpAPIFactory
            YelpAPIFactory.getPlaces(coordinates: location.coordinate, terms: ["pizza", "mexican", "chinese", "burgers"]) { (error: Error?, places: [Place]?) in
                if error == nil {
                    
                    // MARK: - MainData
                    MainData.nearbyPlaces = places ?? []
                    
                    // MARK: - MKPointAnnotation
                    // Map the Place objects to MKPointAnnotation objects
                    let pointAnnotations = (places ?? []).map { (place: Place) -> MKPointAnnotation in
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = place.location?.coordinate ?? location.coordinate
                        return annotation
                    }

                    // If it's not empty, place them onto the MapView!
                    if !pointAnnotations.isEmpty {
                        // Execute in the main thread
                        DispatchQueue.main.async {
                            pointAnnotations.forEach({self.mapView.addAnnotation($0)})
                        }
                    }
                    
                } else {
                    print("\(#file)/\(#line) - Error: \(error?.localizedDescription as Any)")
                }
            }
            
        } else {
            print("\(#file)/\(#line) - Error unwrapping the CLLocation object")
        }
    }
}



// MARK: - UIGestureRecognizer
extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}



// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Identifier
        let identifier = "Pin"

        // Don't show the annotation for the user's location
        if annotation is MKUserLocation {
            return nil
        }
        
        // MARK: - MKAnnotationView
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "pin")
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // Vibrate the device
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        // Are you guys sure you guys don't want haptic feedback?
        // MARK: - UISelectionFeedbackGenerator
//        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
//        selectionFeedbackGenerator.selectionChanged()
    }
}

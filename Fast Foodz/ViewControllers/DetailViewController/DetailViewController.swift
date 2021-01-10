//
//  DetailViewController.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/10/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import MapKit
import NavigationTransitionController



class DetailViewController: UIViewController {
    
    // MARK: - Class Vars
    
    // MARK: - Place
    var place: Place!
    
    // MARK: - MKRoute
    var routes: [MKRoute] = []
    
    // MARK: - NavigationBarItem
    var backItem, shareItem: NavigationBarItem!
    
    // MARK: - NavigationBar
    var navigationBar: NavigationBar!

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var callButton: UIButton!
    
    /// MARK: - Init
    /// - Parameter place: A Place object
    init(place: Place) {
        super.init(nibName: "DetailViewController", bundle: nil)
        
        // MARK: - Place
        self.place = place
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View Controller Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - NavigationBarItem
        backItem = NavigationBarItem(image: UIImage(cgImage: UIImage(named: "chevron")!.cgImage!, scale: 1.0, orientation: .down), tintColor: UIColor.black, offset: 0.0, method: {
            // MARK: - NavigationTransitionController
            self.navigationTransitionController?.dismissNavigation()
        })
        
        // MARK: - NavigationBarItem
        shareItem = NavigationBarItem(image: UIImage(named: "share"), tintColor: UIColor.black, offset: 3.0, method: {
            // MARK: - ShareContext
            ShareContext.present(items: [self.place.url!], viewController: self, completion: nil)
        })
        
        // MARK: - NavigationBar
        navigationBar = NavigationBar(viewController: self, titleAttributedString: NSAttributedString(string: place.name ?? "Details", attributes: [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20.0, weight: .bold)]), alignment: .center, leftBarItems: [backItem], rightBarItems: [shareItem])
        
        // callButton
        callButton.backgroundColor = UIColor.competitionPurple
        callButton.layer.cornerRadius = 16.0
        callButton.clipsToBounds = true
        callButton.setAttributedTitle(NSAttributedString(string: "Call \(place.name ?? "Business")", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 16.0, weight: .semibold)]), for: .normal)
        callButton.addTarget(self, action: #selector(callNumber(_:)), for: .touchUpInside)
        
        // MARK: - StretchyHeaderLayout
        let layout = StretchyHeaderLayout()
        layout.headerReferenceSize = DetailHeaderView.size
        
        // MARK: - UICollectionView
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.register(UINib(nibName: "DetailMapCell", bundle: nil), forCellWithReuseIdentifier: "DetailMapCell")
        collectionView.register(UINib(nibName: "DetailHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DetailHeaderView")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Get the current user's location and the place's location
        if let currentLocation = MainData.currentLocation, let location = place.location {
            // MARK: - MKDirections.Request
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), addressDictionary: nil))
            request.requestsAlternateRoutes = true
            request.transportType = .automobile

            // MARK: - MKDirections
            let directions = MKDirections(request: request)
            directions.calculate { (response: MKDirections.Response?, error: Error?) in
                if error == nil {
                    // MARK: - MKRoute
                    self.routes = response?.routes ?? []
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    
                } else {
                    print("\(#file)/\(#line) - Error: \(error?.localizedDescription as Any)")
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    /// Call the business
    @objc fileprivate func callNumber(_ sender: Any) {
        if let number = place.phone, let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}



// MARK: - UICollectionViewDataSource/UICollectionViewDelegate/UICollectionViewDelegateFlowLayout
extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (UIScreen.main.bounds.height - callButton.frame.maxY) - DetailHeaderView.size.height - SceneDelegate.safeAreaInsets.top - SceneDelegate.safeAreaInsets.bottom)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return DetailHeaderView.size
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // MARK: - DetailHeaderView
        let detailHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DetailHeaderView", for: indexPath) as! DetailHeaderView
        detailHeaderView.updateContent(place: place)
        return detailHeaderView
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // MARK: - DetailMapCell
        let detailMapCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailMapCell", for: indexPath) as! DetailMapCell
        detailMapCell.updateContent(place: place, routes: routes)
        return detailMapCell
    }
}

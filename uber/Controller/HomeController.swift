//
//  HomeController.swift
//  uber
//
//  Created by 오국원 on 2022/04/08.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
import SwiftUI

 private let reuseIdentifier = "LocationCell"

class HomeController: UIViewController {
    //MARK: - Properties
    private let mapView = MKMapView()
    private var locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private var user: User? {
        didSet { locationInputView.user = user }
    }
    
    private final let locationInputViewHeight:CGFloat = 200
    
    //MARK: -Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        fetchUserData()
        fetchDrivers()
        
    }
    //MARK: = API
    
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDriver(location: location) { driver in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
        } else {
            configureUI()
            enableLocationServices(locationManager!)
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(nav, animated: true, completion: nil)
            } //mainthread로 이동, 여기서 문제 만약 이 view로 이동한 후 로그인을 성공한다면 아래 else 문으로 이동하는 것이 아니라 그게 끝이라서 if -> log in - > configure()를 실행할 순서가 필요
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    // MARK: - Helper Functions
    
    
    func configureUI() {
        configureMapView()
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        
        configureTableView()
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func configureLocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {self.tableView.frame.origin.y = self.locationInputViewHeight})
        }

    }
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(tableView)
    }
}

//MARK: - Location Services
extension HomeController:CLLocationManagerDelegate {
    
    func enableLocationServices(_ manager: CLLocationManager) {

        switch manager.authorizationStatus {
        case .notDetermined:
            print("DEBUG: Not determined..")
            manager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            locationManager?.startUpdatingLocation() // 위치 updating ( Starts the generation of updates that report the user's current location )
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest // The best level of accuracy available
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager?.requestAlwaysAuthorization() //더 강한 사용권한 요청 (사용하지 않을 때도 위치접근을 묻는 것)
        @unknown default:
            print("DEBUG: unknown default..")

        }
        
    }
    
    
}

//MARK: -LocationInputActivationViewDelegate

extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
    
}

//MARK: - LocationInputViewDelegate

extension HomeController:LocationInputViewDelegate {
    func dismissLocationInputView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        }) { _ in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3, animations: {self.inputActivationView.alpha = 1 })
        }

    }
    
}

//MARK: - UITableViewDelegate/DataSource

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        return cell
    }
    
    
}

//        if #available(iOS 14, *) {
//            authorizationStatus = manager.authorizationStatus
//        } else {
//            authorizationStatus = CLLocationManager.authorizationStatus()
//        }
//
//        switch authorizationStatus {
//        case .notDetermined:
//            print("DEBUG: Not determined..")
//            locationManager.requestWhenInUseAuthorization()
//        case .restricted, .denied:
//            break
//        case .authorizedAlways:
//            print("DEBUG: Auth always..")
//        case .authorizedWhenInUse:
//            print("DEBUG: Auth when in use..")
//            locationManager.requestAlwaysAuthorization()
//        @unknown default:
//            break
//        }


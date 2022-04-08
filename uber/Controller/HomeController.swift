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

class HomeController: UIViewController {
    //MARK: - Properties
    private let mapView = MKMapView()
    private var locationManager = CLLocationManager()
    //MARK: -Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        signOut()
        
    }
    //MARK: = API
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(nav, animated: false)
            } //mainthread로 이동, 여기서 문제 만약 이 view로 이동한 후 로그인을 성공한다면 아래 else 문으로 이동하는 것이 아니라 그게 끝이라서 if -> log in - > configure()를 실행할 순서가 필요
        } else {
            configureUI()
            enableLocationServices(locationManager)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    // MARK: - Helper Functions
    
    
    func configureUI() {
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
    
}

//MARK: - Location Services
private extension HomeController {
    
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
            
        case .authorizedWhenInUse:
            
            print("DEBUG: Auth when in use..")
            
        @unknown default:
            
            print("DEBUG: unknown default..")
            
        }
        
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


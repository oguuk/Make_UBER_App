//
//  Service.swift
//  uber
//
//  Created by 오국원 on 2022/04/16.
//

import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")

struct Service{
    
    static let shared = Service()
    
    func fetchUserData(uid: String, completion: @escaping(User) -> Void){
        //observeSingleEvnet는 한 번 로드된 후 자주 변경되지 않거나 능동적으로 수신 대기할 필요가 없는 데이터에 유용합니다
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                //observeSingleEvent: fetch just one time 한번 실행이므로 계속 observe할 필요 없음
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchDriver(location: CLLocation,completion: @escaping(User) -> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: {(uid, location) in
                //observe: listen for changes firebas realtimedata
                self.fetchUserData(uid: uid) { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
            
        }
        
    }
    
    func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let desinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        let values = ["pickupCoordinates": pickupArray,
                      "destinationCoordinates": desinationArray,
                      "state": TripState.requested.rawValue] as [String:Any]
        
        REF_TRIPS.child(uid).updateChildValues(values,withCompletionBlock: completion)
    }
    
    func observeTrips(completion: @escaping(Trip) -> Void) {
        //completion으로 Trip을 fetch 했다면 Homecontroller의 observeTrips에서 trip에 접근한다.
        REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            
            completion(trip)
        }
    }
    
    func observeTripCancelled(trip: Trip, completion: @escaping() -> Void) {
        //firebase에서 trip구조가 사라질 때 사용되는 함수
        REF_TRIPS.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { _ in
            completion()
        }
    }
    
    func acceptTrip(trip: Trip, completion: @escaping (Error?,DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = ["driverUid": uid,
                      "state": TripState.accepted.rawValue] as [String : Any]
        
        REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func observeCurrentTrip(completion: @escaping(Trip) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        REF_TRIPS.child(uid).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid  = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    func cancelTrip(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        REF_TRIPS.child(uid).removeValue(completionBlock: completion)
    }
    
    func updateDriverLocation(location: CLLocation){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        geofire.setLocation(location, forKey: uid)
    }
}

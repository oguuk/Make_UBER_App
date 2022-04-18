//
//  DriverAnnotation.swift
//  uber
//
//  Created by 오국원 on 2022/04/17.
//

import MapKit

class DriverAnnotation: NSObject,MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    //dynamic: can update itself
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateAnnotationPosition(withCoordinate coordinate:CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
    
}

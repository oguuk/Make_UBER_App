//
//  DriverAnnotation.swift
//  uber
//
//  Created by 오국원 on 2022/04/17.
//

import MapKit

class DriverAnnotation: NSObject,MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
}

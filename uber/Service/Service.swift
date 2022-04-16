//
//  Service.swift
//  uber
//
//  Created by 오국원 on 2022/04/16.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")

struct Service{
    
    static let shared = Service()
    
    func fetchUserData(completion: @escaping(User) -> Void){
        //observeSingleEvnet는 한 번 로드된 후 자주 변경되지 않거나 능동적으로 수신 대기할 필요가 없는 데이터에 유용합니다
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let user = User(dictionary: dictionary)
            
            print("DEBUG: \(user.email)")
            completion(user)
        }
    }
    
    
}


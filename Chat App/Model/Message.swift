//
//  message.swift
//  Chat App
//
//  Created by Siddique on 03/02/18.
//  Copyright © 2018 Siddique. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromID: String?
    var toID: String?
    var text: String?
    var timestamp: NSNumber?
    init(dictionary: [String: Any]) {
        self.fromID = dictionary["FromID"] as? String ?? ""
        self.toID = dictionary["ToID"] as? String ?? ""
        self.text = dictionary["messages"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? NSNumber
    }
    func chatPartnerId() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
}

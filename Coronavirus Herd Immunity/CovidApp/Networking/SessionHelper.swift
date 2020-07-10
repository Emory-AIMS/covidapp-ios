//
//  SessionHelper.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 14/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

struct SessionHelper {
    
    let defaults = UserDefaults.standard
    
    static let shared = SessionHelper()
    
    func storeToken(_ token: String) {
        defaults.set(token, forKey: "token")
    }
    
    func retrieveToken() -> String? {
        defaults.value(forKey: "token") as? String
    }
}

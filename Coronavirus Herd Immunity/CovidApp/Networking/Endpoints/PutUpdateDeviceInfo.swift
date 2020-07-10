//
//  PutUpdateDeviceInfo.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 14/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

extension Endpoints {
    
    struct PutUpdateDeviceInfo: PutRequest, BodyRequest {
        var path: String { return "/device" }
        public let body: Body
    }
}

extension Endpoints.PutUpdateDeviceInfo {
    struct Body: Codable {
        let id: Int64
        let pushId: String
    }
}

extension APIManager {
    static func updateDeviceInfo(id: Int64, pushID: String, success: @escaping (Bool) -> Void) {
        let request = Endpoints.PutUpdateDeviceInfo(body: .init(id: id, pushId: pushID))
        executeDataRequest(request: request, success: { _ in
            success(true)
        }, failure: { _ in
            success(false)
        })
    }
}

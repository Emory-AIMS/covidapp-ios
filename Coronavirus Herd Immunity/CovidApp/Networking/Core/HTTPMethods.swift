//
//  HTTPMethods.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 14/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

protocol GetRequest: URLRequestConvertible { }

extension GetRequest {
    var method: String { return URLMethod.GET.rawValue }
}

protocol PatchRequest: URLRequestConvertible { }

extension PatchRequest {
    var method: String { return URLMethod.PATCH.rawValue }
}

protocol PutRequest: URLRequestConvertible { }

extension PutRequest {
    var method: String { return URLMethod.PUT.rawValue }
}

protocol DeleteRequest: URLRequestConvertible { }

extension DeleteRequest {
    var method: String { return URLMethod.DELETE.rawValue }
}

protocol PostRequest: URLRequestConvertible { }

extension PostRequest {
    var method: String { return URLMethod.POST.rawValue }
}

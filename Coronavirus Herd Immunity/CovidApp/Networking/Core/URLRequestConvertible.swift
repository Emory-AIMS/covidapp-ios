//
//  URLRequestConvertible.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 14/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

protocol URLRequestConvertible {

    var host: String { get }
    var path: String { get }
    var method: String { get }

    var jsonEncoder: JSONEncoder { get }

    var defaultHeaderValues: [String: String]? { get }
    var headerValues: [String: String]? { get }

    func getUrlQueryParams() -> [String: String]?
    func createHttpBody() throws -> Data?
}

protocol BodyRequest: URLRequestConvertible {
    associatedtype Body: Encodable
    var body: Body { get }
}

protocol QueryParamsRequest: URLRequestConvertible {
    associatedtype Query: Encodable
    var urlQuery: Query { get }
}

extension URLRequestConvertible where Self: BodyRequest {
    func createHttpBody() throws -> Data? {
        return try jsonEncoder.encode(body)
    }
}

extension URLRequestConvertible where Self: QueryParamsRequest {
    func getUrlQueryParams() -> [String: String]? {
        if let result = try? jsonEncoder.encode(urlQuery) {
            let dict = try? JSONSerialization.jsonObject(with: result, options: []) as? [String: Any]
            return dict??.filter { $0.value is CustomStringConvertible }.mapValues { "\($0)" }
        }
        return nil
    }
}

extension URLRequestConvertible {
    var urlQueryParameters: [String: String?]? { return nil }

    var jsonEncoder: JSONEncoder {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        return jsonEncoder
    }

    func getUrlQueryParams() -> [String: String]? {
        return nil
    }

    func createHttpBody() throws -> Data? {
        return nil
    }

    func url(with queryParameters: [URLQueryItem]? = nil) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.queryItems = queryParameters

        guard let hostUrl = URL(string: host), let host = hostUrl.host else {
            throw NetworkingError.couldntCreateUrl
        }
        urlComponents.host = host
        urlComponents.scheme = hostUrl.scheme
        urlComponents.path = "\(hostUrl.path)\(path)"
        guard let url = urlComponents.url else {
            throw NetworkingError.couldntCreateUrl
        }
        return url
    }

    func createUrlRequest() throws -> URLRequest {
        var queryParameters = getUrlQueryParams()?.map { URLQueryItem(name: $0.key, value: $0.value) }
        queryParameters = queryParameters?.sorted(by: { $0.name < $1.name })
        var request = URLRequest(url: try url(with: queryParameters))
        request.httpMethod = method
        var headers = request.allHTTPHeaderFields ?? [:]
        headers.merge(defaultHeaderValues ?? [:], uniquingKeysWith: { (_, new) in new })
        headers.merge(headerValues ?? [:], uniquingKeysWith: { (_, new) in new })
        request.allHTTPHeaderFields = headers
        request.httpBody = try createHttpBody()
        return request
    }

}


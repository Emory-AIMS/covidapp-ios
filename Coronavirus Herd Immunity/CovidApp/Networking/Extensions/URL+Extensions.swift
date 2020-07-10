//
//  URL+Extensions.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 14/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

extension URL {
    var sortedQuery: String? {
        var components = URLComponents()
        components.query = self.query
        components.queryItems = components.queryItems?.sorted(by: { $0.name < $1.name })
        return components.query
    }
}

extension URLRequest {
    func cURLRepresentation() -> String {
        var components = ["$ curl -i"]

        guard let url = self.url else {
            return "Invalid curl command"
        }

        if let httpMethod = self.httpMethod, httpMethod != "GET" {
            components.append("-X \(httpMethod)")
        }

        if URLSession.shared.configuration.httpShouldSetCookies {
            if
                let cookieStorage = URLSession.shared.configuration.httpCookieStorage,
                let cookies = cookieStorage.cookies(for: url), !cookies.isEmpty
            {
                let string = cookies.reduce("") { $0 + "\($1.name)=\($1.value);" }
                components.append("-b \"\(string[..<string.endIndex])))\"")
            }
        }

        var headers: [AnyHashable: Any] = [:]

        if let additionalHeaders = URLSession.shared.configuration.httpAdditionalHeaders {
            for (field, value) in additionalHeaders where field != AnyHashable("Cookie") {
                headers[field] = value
            }
        }

        if let headerFields = self.allHTTPHeaderFields {
            for (field, value) in headerFields where field != "Cookie" {
                headers[field] = value
            }
        }

        for (field, value) in headers {
            components.append("-H \"\(field): \(value)\"")
        }

        if let httpBodyData = self.httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")

            components.append("-d \"\(escapedBody)\"")
        }

        components.append("\"\(url.absoluteString)\"")

        return components.joined(separator: " \\\n\t")
    }
}

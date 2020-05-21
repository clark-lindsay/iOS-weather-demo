//
//  HTTPCLient.swift
//  Weather-Demo
//
//  Created by Clark Lindsay on 5/21/20.
//  Copyright © 2020 Clark Lindsay. All rights reserved.
//

import Foundation

protocol Parsable {
    static func parse(json: JSONMessage) throws -> Parsable
}

typealias JSONMessage = [String: AnyObject]

enum Method: String {
    case GET
}

struct ResourceRequest {
    let path: String
    let method: Method
}

enum ParseResult<T: Parsable> {
    case Error(Error)
    case Result(T)
}

enum ParseResourceError: Error {
    case MalformedURL(messaeg: String?)
    case ParseError(message: String?)
}

struct HTTPClient {
    static func parseResource<T: Parsable>(parseable: ResourceRequest, completion: @escaping (ParseResult<T>) -> Void) {
        let url = URL(string: parseable.path)
        if let url = url {
            let urlSesison = URLSession.shared
            if parseable.method == .GET {
                let task = urlSesison.dataTask(with: url, completionHandler: {
                    (data, response, error) -> Void in
                    var parseResult: ParseResult<T>
                    if let e = error {
                        parseResult = .Error(e)
                    } else {
                        let json: [String: AnyObject]?
                        do { json = try
                             JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject]
                            let result = try T.parse(json: json!)
                            parseResult = ParseResult.Result(result as! T)
                        } catch {
                            let error = ParseResourceError.ParseError(message: "Unable to parse")
                            parseResult = .Error(error)
                        }
                    }
                    DispatchQueue.main.async {
                        completion(parseResult)
                    }
                })
                task.resume()
            }
            else {
                let error = ParseResourceError.MalformedURL(messaeg: "Malformed URL: \(parseable.path)")
                completion(.Error(error))
            }
        }
    }
}

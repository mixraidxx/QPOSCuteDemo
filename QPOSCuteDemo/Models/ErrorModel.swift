//
//  ErrorModel.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 31/05/22.
//

import Foundation
import Alamofire

struct NetworkError: Swift.Error {
  let initialError: AFError
  let backendError: BackendError?
}

struct BackendError: Codable, Swift.Error {
    var status: String
    var message: String
}

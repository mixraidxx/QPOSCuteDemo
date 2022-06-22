//
//  utils.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 30/05/22.
//

import Foundation
import Alamofire
import Combine


protocol ServiceProtocol {
    func initKey(transportKey: String,checkValue: String, crc32: String,_ function: @escaping (InitKeyResponse?, Bool) -> Void)
    func initTransation(bin: String,emvTags: String, last4: String, track2: String, track2Crc: String,serialKey: String, _ function: @escaping (TransactionResponse?, Bool) -> Void)
}

class Service {
    static let shared: ServiceProtocol = Service()
    let url = "http://189.209.169.95:3000/streampay/v1"
    private init() { }
}


extension Service: ServiceProtocol {
    
    
    func initTransation(bin: String,emvTags: String, last4: String, track2: String, track2Crc: String,serialKey: String, _ function: @escaping (TransactionResponse?, Bool) -> Void) {
        let request = TradeRequest(amount: 100, authentication: "pin", cardInformation: CardInformation(bin: bin, cvvLength: 0, cvvPresent: false, emvTags: emvTags, failedCounter: 0, holderName: "", last4: last4, realCounter: 1, serialKey: serialKey, track2: track2, track2Crc32: track2Crc, track2Length: 32), device: Device(serial: "29000100120010700363", version: "100"), entryMode: "chip", isoType: "ISO", reference: "1")
        print(request)
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "commerce-id": "7133219",
            "commerce-name": "COMERCIO DUKPT",
            "X-Auth": "$2b$12$BULF5Lg6pzyI86yeSkSh/.VAd5X4zuO/3XSrkt5U5Lif4JftLFcim",
            "X-Time": "1641258264517",
            "system-fiid": "APGO"
        ]
        AF.request("\(self.url)/retail/charge",method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: TransactionResponse.self) { data in
                guard data.error == nil else {
                    print("Hubo un error")
                    function(nil,false)
                    return
                }
                print(data.value)
                function(data.value, true)
            }
    }
    
    func initKey(transportKey: String,checkValue: String, crc32: String,_ function: @escaping (InitKeyResponse?, Bool) -> Void) {
        let request = InitKeyRequest(isoType: "AGRS", device: Device(serial: "29000100120010700363", version: "100"), rsa: transportKey, rsaName: "A000VLPY06", checkValue: checkValue, crc32: crc32)
        print(request)
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "commerce-id": "7133219",
            "commerce-name": "COMERCIO DUKPT",
            "X-Auth": "$2b$12$BULF5Lg6pzyI86yeSkSh/.VAd5X4zuO/3XSrkt5U5Lif4JftLFcim",
            "X-Time": "1641258264517",
            "system-fiid": "APGO"
            
        ]
        AF.request("\(self.url)/initKeys",method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: InitKeyResponse.self) { data in
                guard data.error == nil else {
                    print("Hubo un error")
                    function(nil,false)
                    return
                }
                print(data.value)
                function(data.value, true)
            }
    }
    
}


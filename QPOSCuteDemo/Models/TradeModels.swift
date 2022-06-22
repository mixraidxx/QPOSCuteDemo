//
//  TradeModels.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 31/05/22.
//

import Foundation


// MARK: - InitKeyRequest
struct InitKeyRequest: Codable {
    let isoType: String
    let device: Device
    let rsa, rsaName, checkValue, crc32: String

    enum CodingKeys: String, CodingKey {
        case isoType, device, rsa
        case rsaName = "rsa_name"
        case checkValue = "check_value"
        case crc32
    }
}

// MARK: - Device
struct Device: Codable {
    let serial, version: String
}

struct GenericResponse: Codable {
    let mensaje: String
}


struct InitKeyResponse: Codable {
    let requestId: String
    let requestDate: String
    let requestStatus: Bool
    let httpCode:   Int
    let errorCode: String
    let description: String
    let authorization: String
    let ksn: String
    let key: String
    let keyCrc32: String
    let keyCheckValue: String
    
    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case requestDate = "request_date"
        case requestStatus  = "request_status"
        case httpCode = "http_code"
        case errorCode = "error_code"
        case description = "description"
        case authorization = "authorization"
        case ksn = "ksn"
        case key = "key"
        case keyCrc32 = "key_crc32"
        case keyCheckValue = "key_check_value"
    }
    
}

// MARK: - TradeRequest
struct TradeRequest: Codable {
    let amount: Double
    let authentication: String
    let cardInformation: CardInformation
    let device: Device
    let entryMode, isoType, reference: String

    enum CodingKeys: String, CodingKey {
        case amount, authentication, cardInformation, device
        case entryMode = "entry_mode"
        case isoType, reference
    }
}

// MARK: - CardInformation
struct CardInformation: Codable {
    let bin: String
    let cvvLength: Int
    let cvvPresent: Bool
    let emvTags: String
    let failedCounter: Int
    let holderName, last4: String
    let realCounter: Int
    let serialKey, track2, track2Crc32: String
    let track2Length: Int

    enum CodingKeys: String, CodingKey {
        case bin
        case cvvLength = "cvv_length"
        case cvvPresent = "cvv_present"
        case emvTags = "emv_tags"
        case failedCounter = "failed_counter"
        case holderName = "holder_name"
        case last4
        case realCounter = "real_counter"
        case serialKey = "serial_key"
        case track2
        case track2Crc32 = "track2_crc32"
        case track2Length = "track2_length"
    }
}



struct TransactionResponse: Codable {
    let requestId: String
    let requestDate: String
    let requestStatus: Bool
    let httpCode: Int
    let errorCode: String
    let description: String
    let id: String
    let traceId: String
    let authorization: String
    let renewKey: Bool
    let binInformation: BinInformation
    let emvTags: String
    let emvResponseCode: String
    
    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case requestDate = "request_date"
        case requestStatus = "request_status"
        case httpCode = "http_code"
        case errorCode = "error_code"
        case description = "description"
        case id = "id"
        case traceId = "trace_id"
        case authorization = "authorization"
        case renewKey = "renew_key"
        case binInformation = "binInformation"
        case emvTags = "emv_tags"
        case emvResponseCode = "emvResponseCode"
    }
}


struct BinInformation: Codable {
    let idBin: Int
    let bin: String
    let bank: String
    let product: String
    let type: String
    let idProcessor: Int
    let brand: String
    
    enum CodingKeys: String, CodingKey {
        case idBin = "id_bin"
        case bin = "bin"
        case bank = "bank"
        case product = "product"
        case type = "type"
        case idProcessor = "id_processor"
        case brand = "brand"
    }
}

//{
//    "request_id": "dae2ac9f-684f-4270-51a3-7e8860efe978",
//    "request_status": false,
//    "http_code": 409,
//    "error_code": "56",
//    "description": "TH CONTACTAR AL EMISOR",
//    "id": "000000000001",
//    "binInformation": {
//        "id_bin": 865,
//        "bin": "528843",
//        "bank": "BANAMEX",
//        "product": "CLASICA",
//        "type": "CREDITO",
//        "id_processor": 3,
//        "brand": "MASTERCARD"
//    },
//    "emv_tags": "5F2A01019F3403403021",
//    "emvResponseCode": ""
//}

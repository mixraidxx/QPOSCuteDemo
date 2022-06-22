//
//  QposService.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 25/05/22.
//

import Foundation
import CRC32



class QposService: NSObject, ObservableObject,QPOSServiceListener  {
    
    
    private lazy var pos: QPOSService = {
        return QPOSService.sharedInstance()
    }()
    private lazy var bt: BTDeviceFinder = {
        return BTDeviceFinder()
    }()
    
    @Published var devices: [String] = []
    @Published var buscando: Bool = false
    @Published var connected: Bool = false
    @Published var tryToconnect: Bool = false
    @Published var info: (model: String, firmware: String, baterryLevel: String,bootloader: String, pci: String)?
    @Published var loading: Bool = false
    @Published var message: String = ""
    
    var conection: ((Bool) -> ())?
    var tlv: String = ""
    private let service = Service.shared
    private let tags: [String] = ["9F27","95","9F26","9F02","9F03","82","9F36","9F1A","5F2A","9A","9C","9F37","9F10","9F1E","9F33","9F35","9F09","9F34","84","5F34","5F20","9F16","9F4E","8E","5F25","4F","9F07","9F0D","9F0F","9F0F","9F39","9B","5F28","9F4C","50","9F06","9F21","9F11","5F24","5F30"]
    private let tagTrack2: [String] = ["57"]
    
    override init() {
        super.init()
        pos.setDelegate(self)
        pos.setPosType(.bluetooth_2mode)
    }
    
    
    func buscarMpos() {
        buscando = true
        devices = []
        bt.setBluetoothDelegate2Mode(self)
        bt.scanQPos2Mode(20)
    }
    
    func stopBluetoothScan(){
        buscando = false
        bt.stopQPos2Mode()
    }
    
    func connectaDevice(name: String){
        tryToconnect = true
        pos.connectBT(name)
        pos.setBTAutoDetecting(true)
    }
    
    func getInfo(){
        pos.getQPosInfo()
    }
    
    func onQposInfoResult(_ posInfoData: [AnyHashable : Any]!) {
        let modelinfo = posInfoData["ModelInfo"] as! String
        let firmware = posInfoData["firmwareVersion"] as! String
        let baterryPercent = posInfoData["batteryPercentage"] as! String
        let bootloader = posInfoData["bootloaderVersion"] as! String
        let pcihardware = posInfoData["PCIHardwareVersion"] as! String
        info = (model: modelinfo, firmware: firmware, baterryLevel: baterryPercent,bootloader: bootloader, pci: pcihardware)
    }
    
    func initTrade(){
        pos.doTrade(20)
    }
    
    func onRequestSetAmount() {
        pos.setAmount("10000", aAmountDescribe: "123", currency: "0156", transactionType: .GOODS)
    }
    
    func onRequestWaitingUser() {
    }
    
    func onRequestTime() {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        let dateString = df.string(from: date)
        pos.sendTime(dateString)
    }
    
    func onRequestTransactionLog(_ tlv: String!) {
    }
    
    func onRequest(_ transactionResult: TransactionResult) {
        
        switch transactionResult {
        case TransactionResult.APPROVED:
            print("Aprobada")
        case TransactionResult.CANCEL:
            print("Cancelada")
        case TransactionResult.DECLINED:
            print("Declinada")
        case TransactionResult.TERMINATED:
            print("Terminada")
        default:
            print("Default")
        }
    }
    
    
    func onRequestQposConnected() {
        tryToconnect = false
        self.connected = true
        self.conection?(true)
    }
    
    func onError(_ errorState: Error) {
    }
    
    func onDoTradeResult(_ result: DoTradeResult, decodeData: [AnyHashable : Any]!) {
        if (result == .ICC){
            pos.doEmvApp(.START)
        }
    }
    
    func onRequestOnlineProcess(_ tlv: String!) {
        self.tlv = tlv
        print("TLV")
        print(tlv)
        getEncrptedData()
    }
    
    func generateTransportKey(){
        self.loading.toggle()
        self.pos.generateTransportKey(10) { data in
            print("Transport key generada")
            print(data)
            guard let transportKey = data!["transportKey"] as? String else {
                print("error on transport Key")
                self.message = "error on transport Key"
                self.loading.toggle()
                return
            }
            guard let checkValue = data!["checkValue"] as? String else {
                print("Error en Check Value")
                self.loading.toggle()
                return
            }
            print("Transport key")
            print(transportKey)
            
            let crc32 = String(CRC32.crc32(transportKey), radix: 16, uppercase: true)
            self.service.initKey(transportKey: transportKey, checkValue: checkValue, crc32: crc32) { response, success in
                print("Respuesta de generar transport key")
                print(response)
                guard response?.errorCode == "00" else {
                    print("Error: \(response?.errorCode)")
                    self.message = response?.description ?? "Ocurrio un error inesperado"
                    self.loading.toggle()
                    return
                }
                
                guard let transportKey = response?.key else {
                    self.loading.toggle()
                    self.message = "Error en transport key"
                    return
                }
                
                guard let ksn = response?.ksn else {
                    self.loading.toggle()
                    self.message = "Error en ksn"
                    return
                }
                
                guard let checkValue = response?.keyCheckValue else {
                    self.loading.toggle()
                    self.message = "Error en check value"
                    return
                }
                
                
                self.pos.updateIPEK(byTransportKey: "00",
                                    tracksn: ksn,
                                    trackipek: transportKey,
                                    trackipekCheckValue: checkValue,
                                    emvksn: ksn,
                                    emvipek: transportKey,
                                    emvipekcheckvalue: checkValue,
                                    pinksn: ksn,
                                    pinipek: transportKey,
                                    pinipekcheckValue: checkValue) { success in
                    print("Update ipek result: \(success)")
                    self.loading.toggle()
                }
            }
            
        }
    }
    
    private func getEncrptedData()  {
        pos.sendCVV("") { [self] success in
            pos.getEncryptedDataBlock(0) { [weak self] result in
                self?.sendOnlineData(result)
            }
        }
    }
    
    
    
    private func sendOnlineData(_ encryptedDataBlock: [AnyHashable : Any]!) {
        var tagsrequiered = ""
        var tagsrequiered2 = ""
        let cardSencitive = encryptedDataBlock["CardSensitiveData"] as! String
        let serial = encryptedDataBlock["KSN"] as! String
        let track2 =  cardSencitive.substrings(with: 0..<48)
        tags.forEach {
            tagsrequiered += $0
        }
        tagTrack2.forEach {
            tagsrequiered2 += $0
        }
        guard let icctags = pos.getICCTagNew(.plaintext, cardType: 0, tagCount: tags.count, tagArrStr: tagsrequiered) else {
            print("Ocurrio un error")
            return
        }
        let tagsString = icctags["tlv"] as! String
        let tagsDecode = self.parseTlv(tlv: tagsString)
        guard let tagTrack = pos.getICCTagNew(.plaintext, cardType: 0, tagCount: tagTrack2.count, tagArrStr: tagsrequiered2) else {
            print("Ocurrio un error con el tag57")
            return
        }
        let tagsString2 = tagTrack["tlv"] as! String
        let decodeTrack2 = self.parseTlv(tlv: tagsString2)
        guard let cardTag = decodeTrack2.first(where: { tlv in
            tlv.tag == "57"
        })?.value else {
            print("Ocurrio un error 2")
            return
        }
        let cardInfo = cardTag.split(separator: "D")
        let cardNumber = String(cardInfo[0])
        let bin = cardNumber.substrings(with: 0..<6)
        let last4 = cardNumber.substring(from: cardNumber.count-4)
        let crc32 = String(CRC32.crc32(track2), radix: 16, uppercase: true)
        service.initTransation(bin: bin, emvTags: tagsString, last4: last4, track2: track2, track2Crc: crc32, serialKey: serial) { [weak self] response, success in
            self?.pos.sendOnlineProcessResult("8A023030", delay: 0)
        }
    }
    private func parseTlv(tlv: String) -> [TLV] {
        let parse = TLVParser.parse(tlv)
        return parse
    }
    
    
    func onLcdShowCustomDisplay(_ isSuccess: Bool) {
        print("sdfsdf")
    }
    
    func onRequestBatchData(_ tlv: String!) {
        print("batch data")
    }
    
    func onRequest(_ displayMsg: Display) {
        
    }
    
    func onRequestNoQposDetected() {
        tryToconnect = false
        self.conection?(false)
    }
    
    func onRequestQposDisconnected() {
        self.connected = false
    }
    
    
}

extension QposService: BluetoothDelegate2Mode {
    func onBluetoothName2Mode(_ bluetoothName: String!) {
        DispatchQueue.main.async {
            self.devices.append(bluetoothName)
        }
        
    }
    
    
    func finishScanQPos2Mode() {
        buscando = false
    }
    
    
    func bluetoothIsPowerOn2Mode() {
        print("bluetooth is power on")
    }
    
    func bluetoothIsPowerOff2Mode() {
        print("bluetooth is power off")
    }
    
    
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substrings(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

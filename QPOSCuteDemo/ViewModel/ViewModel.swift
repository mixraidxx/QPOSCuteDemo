//
//  ViewModel.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 31/05/22.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
    @Published var chatListLoadingError: String = ""
    @Published var showAlert: Bool = false
    @Published var response: String = ""
    
    private var cancellableSet: Set<AnyCancellable> = []
    var dataManager: ServiceProtocol
    
    init(dataManager: ServiceProtocol = Service.shared) {
        self.dataManager = dataManager
//        self.initKey()
    }
    
    
    func createAlert( with error: String ) {
//           chatListLoadingError = error.backendError == nil ? error.initialError.localizedDescription : error.backendError!.message
        chatListLoadingError = error
           self.showAlert = true
       }

}

//
//  QPOSCuteDemoApp.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 23/12/21.
//

import SwiftUI

@main
struct QPOSCuteDemoApp: App {
    @StateObject private var qposService = QposService()
    @StateObject private var viewModel = ViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
               .environmentObject(qposService)
               .environmentObject(viewModel)
        }
    }
}

//
//  InfoView.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 30/05/22.
//

import SwiftUI

struct InfoView: View {
    @EnvironmentObject private var qposService: QposService
    
    
    var body: some View {
            Form {
                Label {
                    Text("Modelo")
                } icon: {
                    Text(qposService.info?.model ?? "")
                }
                .labelStyle(RightLabelStyle())
                
                Label {
                    Text("Firmware")
                } icon: {
                    Text(qposService.info?.firmware ?? "")
                }
                .labelStyle(RightLabelStyle())
                
                Label {
                    Text("Porcentaje de bateria")
                } icon: {
                    Text(qposService.info?.baterryLevel ?? "")
                }
                .labelStyle(RightLabelStyle())
                
                Label {
                    Text("Versión de bootloader")
                } icon: {
                    Text(qposService.info?.bootloader ?? "")
                }
                .labelStyle(RightLabelStyle())
                
                Label {
                    Text("PCI Hardware")
                } icon: {
                    Text(qposService.info?.pci ?? "")
                }
                .labelStyle(RightLabelStyle())

            }
            .navigationTitle("Información")
            .onAppear(){
                qposService.getInfo()
            }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}



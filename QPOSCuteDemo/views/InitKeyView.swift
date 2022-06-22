//
//  InitKeyView.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 09/06/22.
//

import SwiftUI

struct InitKeyView: View {
    @EnvironmentObject private var qposService: QposService
    
    var body: some View {
        if(qposService.loading){
            ProgressView()
        } else {
            Button {
                print("Iniciar llaves")
                qposService.generateTransportKey()
            } label: {
                Label {
                    Text("Carga de llaves")
                } icon: {
                    Image(systemName: "key.icloud")
                }
            }

        }
        
    }
}

struct InitKeyView_Previews: PreviewProvider {
    static var previews: some View {
        InitKeyView()
    }
}

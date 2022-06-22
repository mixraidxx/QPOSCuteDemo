//
//  TransactionView.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 30/05/22.
//

import SwiftUI

struct TransactionView: View {
    @EnvironmentObject private var qposService: QposService
    @State var input = ""
    
    var body: some View {
        Form{
            TextField("cantidad", text: $input)
                .keyboardType(.decimalPad)
            Button {
                print("Inicia tx")
                qposService.initTrade()
            } label: {
                Text("init trade")
            }

        }
        .navigationTitle("Iniciar transacción")
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}

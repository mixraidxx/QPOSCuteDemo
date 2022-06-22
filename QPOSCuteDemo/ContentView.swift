//
//  ContentView.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 23/12/21.
//

import SwiftUI


struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingSheet = false
    @EnvironmentObject private var qposService: QposService
    @EnvironmentObject private var viewModel: ViewModel
    
    var items: [GridItem] {
      Array(repeating: .init(.adaptive(minimum: 120)), count: 2)
    }
    let colors: [Color] = [.red, .green, .blue, .yellow, .purple]
    
    let options: [(nombre: String, imagen: String)] = [
        (nombre: "Iniciar transacción", imagen: "creditcard"),
        (nombre: "Inicializar llaves", imagen: "key"),
        (nombre: "Actualizar llave RSA", imagen: "key.viewfinder"),
        (nombre: "Mostrar información", imagen: "info.circle")
    ]

    
    var body: some View {
        NavigationView{
            VStack{
                if(qposService.connected){
                    ScrollView(.vertical) {
                    LazyVGrid(columns: items) {
                        ForEach((0..<options.count), id: \.self) { index in
                            OptionView(item: options[index])
                            }
                        }
                    .padding(.horizontal)
                    }
                } else {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Text("Conectar dispositivo")
                    }

                }
            }
            .sheet(isPresented: $showingSheet, onDismiss: {
                qposService.stopBluetoothScan()
            }){
                ConnectBluetoothView()
            }
            .navigationTitle("Inicio")
        }
        .navigationViewStyle(.stack)
        .alert(isPresented: $viewModel.showAlert) {
                    Alert(title: Text("Error"), message: Text (viewModel.chatListLoadingError ), dismissButton: .default(Text("OK")))
                }
    }
    
    func OptionView(item: (nombre: String, imagen: String)) -> some View {
        NavigationLink {
            switch item.nombre {
            case "Mostrar información":
                InfoView()
            case "Iniciar transacción":
                TransactionView()
            case "Inicializar llaves":
                InitKeyView()
            default:
                Text("sfgdf")
            }
        } label: {
            VStack(alignment: .center, spacing: 8) {
                Spacer()
                Image(systemName: item.imagen)
                    .font(.system(size: 40))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color(UIColor.label))
                Text(item.nombre)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color(UIColor.label))
                Spacer()
            }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 150,
                maxHeight: 150,
                alignment: .topLeading
                )
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
     
}

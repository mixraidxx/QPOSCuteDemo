//
//  ConnectBluetoothView.swift
//  QPOSCuteDemo
//
//  Created by David Enriquez solis on 27/05/22.
//

import SwiftUI


struct ConnectBluetoothView: View {
    @EnvironmentObject private var qposService: QposService
    @State private var selected = ""
    @State private var showingAlert = false
    @Environment(\.presentationMode) var presentationMode
    

    var body: some View {
        NavigationView{
            Form{
                ForEach(qposService.devices, id: \.self){
                    item in
                    Button(action: {
                        qposService.connectaDevice(name: item)
                        selected = item
                    }, label: {
                        HStack{
                            Text(item)
                                .foregroundColor(Color(UIColor.label))
                            Spacer()
                            if(qposService.tryToconnect && selected == item){
                                ProgressView()
                            }
                        }
                    })
                    .disabled(qposService.tryToconnect)
                }
            }
            .navigationTitle("Dispositivos")
        }
        .alert("Error de conexión", isPresented: $showingAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text("No fue posible conectar al dispositivo, asegurate de seleccionar tu terminal")
        })
        .onAppear(){
            qposService.conection = {
                success in
                guard success else {
                    return showingAlert.toggle()
                }
                presentationMode.wrappedValue.dismiss()
            }
            qposService.buscarMpos()
        }
    }
}

struct ConnectBluetoothView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectBluetoothView()
    }
}


struct RightLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 8) {
            configuration.title
            Spacer()
            configuration.icon
        }
    }
}

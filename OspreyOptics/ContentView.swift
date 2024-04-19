//
//  ContentView.swift
//  Lunar
//
//  Created by Andreas Ink on 4/16/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @StateObject var viewModel = ARViewModel()
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
            .environmentObject(viewModel)
            .overlay {
                Button {
                    viewModel.detectSurfaceDrop()
                } label: {
                    Text(viewModel.state)
                        .font(.title)
                        .minimumScaleFactor(0.4)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundStyle(.thickMaterial)
                        }
                }
            }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var viewModel: ARViewModel
    func makeUIView(context: Context) -> ARView {
        viewModel.startLunar()
        return viewModel.arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  ARGameHeroes
//
//  Created by Swift Learning on 29.07.2022.
//

import SwiftUI
import RealityKit
import ARKit
import RealityKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: String?
    @State private var modelConfirmedForPlacement: String?
    
    private var models: [String] = {
        
        let fileManager = FileManager.default
        
        guard let path = Bundle.main.resourcePath,
                let files = try?
                fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableModels: [String] = []
        for filename in files where filename.hasSuffix("scn") {
            let modelName = filename.replacingOccurrences(of: ".scn", with: "")
            availableModels.append(modelName)
        }
        return availableModels
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnables: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            } else {
                ModelPickerView(isPlacementEnables: self.$isPlacementEnabled, selectedModel: self.$selectedModel,
                                models: self.models)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: String?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelName = self.modelConfirmedForPlacement {
            print("Debug model name \(modelName)")
            
            let filename = modelName + ".scn"
            let modelEntity = try!
            ModelEntity.loadModel(named: filename)
            let anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.addChild(modelEntity)
            uiView.scene.addAnchor(anchorEntity)
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
}

struct ModelPickerView: View {
    @Binding var isPlacementEnables: Bool
    @Binding var selectedModel: String?
    
    var models: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in
                    
                    Button {
                        print("Debug \(self.models[index])")
                        self.selectedModel = self.models[index]
                        self.isPlacementEnables = true
                    } label: {
                        Image(uiImage: UIImage(named: self.models[index])!)
                            .resizable()
                            .frame(height: 60)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                        .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnables: Bool
    @Binding var selectedModel: String?
    @Binding var modelConfirmedForPlacement: String?
    
    var body: some View {
        HStack {
            Button {
                print("Debug Cancel")
                self.resetPlacementParameters()
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 50, height: 50)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(0)
                    
            }
            Button {
                print("Debug Confirm")
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParameters()
            } label: {
                Image(systemName: "checkmark")
                    .frame(width: 50, height: 50)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(0)
            }
        }
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnables = false
        self.selectedModel = nil
    }
}



#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}
#endif

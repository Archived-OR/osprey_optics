//
//  ARViewModel.swift
//  Lunar
//
//  Created by Andreas Ink on 4/16/24.
//

import ARKit
import RealityKit

class ARViewModel: ObservableObject {
    let arView = ARView()
    var arSession: ARSession?
    @Published var state = ""
    func startLunar() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        configuration.planeDetection = [.horizontal, .vertical]
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.session.run(configuration)

    }
    
    let significantDropThreshold: Float = 0.05
    let roverBaseHeight: Float = 2
    
    func detectSurfaceDrop() {
        // Close raycast - representing the current position of the rover
        let closePoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        // Far raycast - a point further ahead in the rover's path
        let farPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY - 200)
        
        // Perform the close raycast
        if let closeResult = arView.raycast(from: closePoint, allowing: .existingPlaneGeometry, alignment: .horizontal).first {
            
            let closeHitTransform = closeResult.worldTransform
            
            // Perform the far raycast
            if let farResult = arView.raycast(from: farPoint, allowing: .existingPlaneGeometry, alignment: .horizontal).first {
                let farHitTransform = farResult.worldTransform
                // Calculate the elevation difference
                let elevationChange = closeHitTransform.columns.3.y - farHitTransform.columns.3.y
                print(elevationChange)
                // If there is a significant drop or rise, update the state
                if elevationChange > significantDropThreshold {
                    // Negative change indicates a drop
                    state = "Significant surface drop detected ahead!"
                } else if farHitTransform.columns.3.y > roverBaseHeight {
                    // If transform is larger than roverBaseHeight, it indicates a rise, like a rock
                    state = "Raised obstacle detected ahead!"
                } else {
                    state = "Surface is relatively level."
                }
            } else {
                state = "Close raycast did not hit a mesh anchor."
            }
        }
    }
}

//
//  ARViewModel.swift
//  OspreyOptics
//
//  Created by Andreas Ink on 4/16/24.
//

import ARKit
import RealityKit

class ARViewModel: ObservableObject {
    
    // Does not update our view, but is class that handles our ARKit logic under the hood
    let arView = ARView()
    
    // Updates our view
    @Published var state = ""
    
    /// Starts ARKit so we can understand the environment
    func startOptic() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        configuration.planeDetection = [.horizontal, .vertical]
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.session.run(configuration)

    }
    
    // A threshold in meters
    let significantDropThreshold: Float = 0.05
    // Height of the rover in meters
    let roverBaseHeight: Float = 2
    
    /// Detects if a rock or crater is ahead
    func detectSurfaceChange() {
        // Close raycast - representing the current position of the rover
        let closePoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        // Far raycast - a point further ahead in the rover's path
        let farPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY - 200)
        
        // Perform the close raycast
        if let closeResult = arView.raycast(from: closePoint, allowing: .existingPlaneGeometry, alignment: .horizontal).first {
            
            // Get the position of the close point relative to where the device started
            let closeHitTransform = closeResult.worldTransform
            
            // Perform the far raycast
            if let farResult = arView.raycast(from: farPoint, allowing: .existingPlaneGeometry, alignment: .horizontal).first {
                // Get the position of the far point relative to where the device started
                let farHitTransform = farResult.worldTransform
                // Calculate the elevation difference
                let elevationChange = closeHitTransform.columns.3.y - farHitTransform.columns.3.y
                print(elevationChange)
                // If there is a significant drop or rise, update the state
                if elevationChange > significantDropThreshold {
                    // Negative change indicates a drop
                    state = "Significant surface drop detected ahead!"
                } else if farHitTransform.columns.3.y > roverBaseHeight {
                    #warning("Please fix logic to detect rocks when the starting or current elevation can change")
                    // If transform is larger than roverBaseHeight, it indicates a rise, like a rock
                    // TODO: Ensure this works when elevation changes
                    // TODO: For example, if one end of the arena is lower than the other
                    // TODO: end, we will run into issues because farHitTransform is
                    // TODO: relative to the start position
                    state = "Raised obstacle detected ahead!"
                } else {
                    state = "Surface is relatively level."
                }
            } else {
                state = "Far raycast did not hit a mesh anchor."
            }
        } else {
            state = "Close raycast did not hit a mesh anchor."
        }
    }
}

import Foundation
import ARKit

extension ARSCNView {
    func getCurrentPositionInFrontOfCamera() -> SCNVector3? {
        guard let pointOfViewTransformMatrix = pointOfView?.transform else { return nil }
        
        // The orientation vector that points in the direction of the camera. The normal of the camera
        let orientation = SCNVector3(-pointOfViewTransformMatrix.m31,
                                     -pointOfViewTransformMatrix.m32,
                                     -pointOfViewTransformMatrix.m33)
        
        // The position of the camera itself
        let location = SCNVector3(pointOfViewTransformMatrix.m41,
                                  pointOfViewTransformMatrix.m42,
                                  pointOfViewTransformMatrix.m43)
        
        return orientation + location
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    SCNVector3Make(left.x + right.x,
                   left.y + right.y,
                   left.z + right.z)
}

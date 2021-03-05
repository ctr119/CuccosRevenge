import Foundation
import ARKit

enum Characters: String {
    case cucco
}

class Cucco: SCNNode {
    private let cuccoSceneName = "art.scnassets/Bonky_the_Cucco.scn"
    private let cuccoNodeName = "cucco"
    
    override init() {
        super.init()
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }
    
    private func commonSetup() {
        guard let cuccoScene = SCNScene(named: cuccoSceneName) else {
            fatalError("Missing cucco scene")
        }
        guard let cuccoNode = cuccoScene.rootNode.childNode(withName: cuccoNodeName, recursively: false) else {
            fatalError("Missing cucco node")
        }
        cuccoNode.name = cuccoNodeName
        
        name = "\(Characters.cucco.rawValue)"
        scale = SCNVector3(0.0005, 0.0005, 0.0005)
        position = SCNVector3(0, 0, -0.2)
        
        addChildNode(cuccoNode)
        
        let physicsShape = SCNPhysicsShape(node: cuccoNode, options: [.keepAsCompound : true])
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
    }
    
    // TODO: test this method
    private func addPhysicsBody() {
        guard let cuccoNode = childNode(withName: cuccoNodeName, recursively: false) else { return }
        let physicsShape = SCNPhysicsShape(node: cuccoNode, options: [.keepAsCompound : true])
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
    }
    
    func isBeingAnimated() -> Bool {
        !animationKeys.isEmpty
    }
    
    func playHittedAnimation() {
        let spinAnimation = CABasicAnimation(keyPath: "position")
        spinAnimation.fromValue = presentation.position
        spinAnimation.toValue = SCNVector3(position.x - 0.2,
                                           position.y - 0.2,
                                           position.z - 0.2)
        spinAnimation.duration = 3
        spinAnimation.repeatCount = 5
        spinAnimation.autoreverses = true
        
        addAnimation(spinAnimation, forKey: "position")
    }
}

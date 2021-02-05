import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    private let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [
            .showWorldOrigin, .showFeaturePoints
        ]
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecogniser)
    }
    
    @IBAction func play(_ sender: UIButton) {
        addCucco()
    }
    
    private func loadBox() {
        let boxNode = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0))
        boxNode.position = SCNVector3(0, 0, -1)
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    private func addCucco() {
        let cucco = Cucco()
        sceneView.scene.rootNode.addChildNode(cucco)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let sceneViewTappedOn = sender.view as? SCNView else { return }
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates, options: nil)
        if !hitTest.isEmpty {
            guard let firstTestResult = hitTest.first else { return }
            let node = firstTestResult.node
            let characterKind = Characters(rawValue: node.name ?? "")
            
            switch characterKind {
            case .cucco:
                guard let cucco = node as? Cucco else { return }
                if !cucco.isBeingAnimated() {
                    SCNTransaction.begin()
                    cucco.playHittedAnimation()
                    SCNTransaction.completionBlock = {
                        cucco.removeFromParentNode()
                    }
                    SCNTransaction.commit()
                }
            default:
                print("Another not important thing was hitted")
            }
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let grassTileNode = makeGrassTileNode(on: planeAnchor)
        node.addChildNode(grassTileNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let grassTileNode = makeGrassTileNode(on: planeAnchor)
        node.addChildNode(grassTileNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
    private func makeGrassTileNode(on planeAnchor: ARPlaneAnchor) -> SCNNode {
        let grassTileNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                                       height: CGFloat(planeAnchor.extent.z)))
        
        grassTileNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Grass Tile")
        grassTileNode.geometry?.firstMaterial?.isDoubleSided = true
        grassTileNode.position = SCNVector3(planeAnchor.center.x,
                                            planeAnchor.center.y,
                                            planeAnchor.center.z)
        grassTileNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        
        return grassTileNode
    }
    
//    private func positionObjectExactlyAtPlanesSurface(hitTestResult: SCNHitTestResult) {
//        let transform = hitTestResult.modelTransform
//        // The third column contains the information about the plane
//        let position = SCNVector3(transform.m13, transform.m23, transform.m33)
//    }
}


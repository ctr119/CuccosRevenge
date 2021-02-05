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
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecogniser)
    }
    
    @IBAction func play(_ sender: UIButton) {
        loadCucco()
    }
    
    private func loadBox() {
        let boxNode = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0))
        boxNode.position = SCNVector3(0, 0, -1)
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    private func loadCucco() {
        guard let cuccoScene = SCNScene(named: "art.scnassets/Bonky_the_Cucco.scn") else { return }
        guard let cuccoNode = cuccoScene.rootNode.childNode(withName: "cucco", recursively: false) else { return }
        cuccoNode.position = SCNVector3(0, 0, -0.2)
        cuccoNode.scale = SCNVector3(0.0005, 0.0005, 0.0005)
        sceneView.scene.rootNode.addChildNode(cuccoNode)
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


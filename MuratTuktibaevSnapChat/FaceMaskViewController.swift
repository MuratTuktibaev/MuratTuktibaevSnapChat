import UIKit
import ARKit
import SceneKit

class FaceMaskViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ARSessionDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let sceneView = ARSCNView(frame: UIScreen.main.bounds)
    var mustache = SCNNode()
    
    let masks = ["mustache1", "mustache2", "mustache3", "mustache4", "mustache5", "mustache6"] // Названия разных масок
    var selectedMaskIndex = 0 // Индекс выбранной маски
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(sceneView)
        sceneView.delegate = self
        
        // Создаем UICollectionView с горизонтальным скроллом
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MaskCell.self, forCellWithReuseIdentifier: "MaskCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.maximumNumberOfTrackedFaces = 2
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return masks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaskCell", for: indexPath) as! MaskCell
        cell.imageView.image = UIImage(named: masks[indexPath.item])
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMaskIndex = indexPath.item
        // Удаляем предыдущие узлы сцены
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
            
            // Создаем новый узел с выбранной маской
            if let currentFrame = sceneView.session.currentFrame {
                let material = SCNMaterial()
                material.locksAmbientWithDiffuse = true
                material.isDoubleSided = false
                material.diffuse.contents = UIImage(named: masks[selectedMaskIndex]) // Используем выбранную маску
                let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)
                let node = SCNNode(geometry: faceGeometry)
                node.geometry?.firstMaterial?.fillMode = .fill
                node.geometry?.materials = [material]
                sceneView.scene.rootNode.addChildNode(node)
            }
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.maximumNumberOfTrackedFaces = 2
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

class MaskCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FaceMaskViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let material = SCNMaterial()
        material.locksAmbientWithDiffuse = true
        material.isDoubleSided = false
        material.diffuse.contents = UIImage(named: masks[selectedMaskIndex]) // Используем выбранную маску
        guard let device = sceneView.device else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .fill
        node.geometry?.materials = [material]
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        faceGeometry.update(from: faceAnchor.geometry)
    }
}

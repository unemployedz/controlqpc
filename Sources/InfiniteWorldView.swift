import SwiftUI
import SceneKit

private final class GameInput: ObservableObject {
    @Published var movement = CGPoint.zero
    @Published var jumpRequested = false
    @Published var cameraDelta = CGPoint.zero
}

struct InfiniteWorldView: View {
    @StateObject private var input = GameInput()
    @State private var showMenu = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                BaseplateSceneView(input: input)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("BLOCKWORLD")
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                .tracking(2)
                            Text("R6 • INFINITE BASEPLATE")
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .tracking(1.2)
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        Spacer()
                        Button { showMenu = true } label: {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 42, height: 42)
                                .background(.black.opacity(0.48), in: RoundedRectangle(cornerRadius: 13))
                                .overlay(RoundedRectangle(cornerRadius: 13).stroke(.white.opacity(0.16), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    Spacer()
                    HStack(alignment: .bottom) {
                        VirtualJoystick(value: $input.movement)
                            .frame(width: 128, height: 128)
                        Spacer()
                        Button {
                            input.jumpRequested = true
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 18, weight: .black))
                                Text("JUMP")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .tracking(1)
                            }
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(.black.opacity(0.5), in: Circle())
                            .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 1))
                        }
                        .padding(.trailing, 10)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 12))
                }
            }
            .preferredColorScheme(.dark)
            .alert("Paused", isPresented: $showMenu) {
                Button("Resume", role: .cancel) { }
                Button("Reset character", role: .destructive) {
                    input.movement = .zero
                    input.jumpRequested = true
                }
            } message: {
                Text("Prototype build • local single-player world")
            }
        }
    }
}

private struct VirtualJoystick: View {
    @Binding var value: CGPoint
    @State private var origin = CGPoint.zero
    private let radius: CGFloat = 42

    var body: some View {
        GeometryReader { proxy in
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            ZStack {
                Circle()
                    .fill(.black.opacity(0.38))
                    .overlay(Circle().stroke(.white.opacity(0.18), lineWidth: 1))
                    .frame(width: 112, height: 112)
                Circle()
                    .fill(.white.opacity(0.13))
                    .overlay(Circle().stroke(.white.opacity(0.36), lineWidth: 1))
                    .frame(width: 52, height: 52)
                    .position(x: center.x + value.x * radius, y: center.y + value.y * radius)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Circle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    let dx = gesture.location.x - center.x
                    let dy = gesture.location.y - center.y
                    let distance = max(1, hypot(dx, dy))
                    let scale = min(radius, distance) / distance
                    value = CGPoint(x: (dx * scale) / radius, y: (dy * scale) / radius)
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.7)) {
                        value = .zero
                    }
                })
        }
    }
}

private struct BaseplateSceneView: UIViewRepresentable {
    @ObservedObject var input: GameInput

    func makeCoordinator() -> Coordinator { Coordinator(input: input) }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = context.coordinator.scene
        view.delegate = context.coordinator
        view.backgroundColor = UIColor(red: 0.48, green: 0.69, blue: 0.91, alpha: 1)
        view.isPlaying = true
        view.rendersContinuously = true
        view.antialiasingMode = .multisampling2X
        view.preferredFramesPerSecond = 60
        view.allowsCameraControl = false
        view.pointOfView = context.coordinator.camera
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.input = input
    }

    final class Coordinator: NSObject, SCNSceneRendererDelegate {
        let scene = SCNScene()
        let camera = SCNNode()
        var input: GameInput
        private let player = SCNNode()
        private let torso = SCNNode()
        private let leftLeg = SCNNode()
        private let rightLeg = SCNNode()
        private var tiles: [String: SCNNode] = [:]
        private var lastTime: TimeInterval = 0
        private var verticalVelocity: Float = 0
        private var grounded = true
        private var walkPhase: Float = 0
        private var cameraYaw: Float = 0
        private var cameraPitch: Float = 0.22

        init(input: GameInput) {
            self.input = input
            super.init()
            buildWorld()
        }

        private func material(_ color: UIColor, roughness: CGFloat = 0.9) -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.roughness.contents = roughness
            material.lightingModel = .physicallyBased
            return material
        }

        private func box(_ size: SCNVector3, color: UIColor) -> SCNNode {
            let node = SCNNode(geometry: SCNBox(width: CGFloat(size.x), height: CGFloat(size.y), length: CGFloat(size.z), chamferRadius: 0.025))
            node.geometry?.materials = [material(color)]
            return node
        }

        private func buildWorld() {
            scene.background.contents = UIColor(red: 0.48, green: 0.69, blue: 0.91, alpha: 1)
            scene.lightingEnvironment.contents = UIColor(white: 0.9, alpha: 1)
            scene.lightingEnvironment.intensity = 0.7

            let ambient = SCNNode()
            let ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.intensity = 500
            ambientLight.color = UIColor(white: 0.8, alpha: 1)
            ambient.light = ambientLight
            scene.rootNode.addChildNode(ambient)

            let sun = SCNNode()
            let sunLight = SCNLight()
            sunLight.type = .directional
            sunLight.intensity = 900
            sunLight.castsShadow = true
            sunLight.shadowMode = .deferred
            sunLight.shadowRadius = 5
            sunLight.shadowColor = UIColor.black.withAlphaComponent(0.22)
            sun.light = sunLight
            sun.eulerAngles = SCNVector3(-0.9, 0.5, 0)
            scene.rootNode.addChildNode(sun)

            camera.camera = SCNCamera()
            camera.camera?.fieldOfView = 62
            camera.camera?.zNear = 0.1
            camera.camera?.zFar = 500
            scene.rootNode.addChildNode(camera)

            buildR6()
            updateTiles()
            updateCamera()
        }

        private func buildR6() {
            player.position = SCNVector3(0, 0.12, 0)
            scene.rootNode.addChildNode(player)

            let legs = box(SCNVector3(0.38, 0.78, 0.38), color: UIColor(red: 0.12, green: 0.25, blue: 0.78, alpha: 1))
            let leftArm = box(SCNVector3(0.36, 0.82, 0.36), color: UIColor(red: 0.95, green: 0.72, blue: 0.52, alpha: 1))
            let rightArm = box(SCNVector3(0.36, 0.82, 0.36), color: UIColor(red: 0.95, green: 0.72, blue: 0.52, alpha: 1))
            torso.addChildNode(box(SCNVector3(0.82, 0.92, 0.42), color: UIColor(red: 0.12, green: 0.42, blue: 0.86, alpha: 1)))
            torso.position = SCNVector3(0, 1.35, 0)
            player.addChildNode(torso)

            let head = box(SCNVector3(0.62, 0.62, 0.62), color: UIColor(red: 1, green: 0.78, blue: 0.57, alpha: 1))
            head.position = SCNVector3(0, 0.83, 0)
            torso.addChildNode(head)

            leftArm.position = SCNVector3(-0.59, -0.02, 0)
            rightArm.position = SCNVector3(0.59, -0.02, 0)
            torso.addChildNode(leftArm)
            torso.addChildNode(rightArm)

            leftLeg.position = SCNVector3(-0.22, 0.43, 0)
            rightLeg.position = SCNVector3(0.22, 0.43, 0)
            leftLeg.addChildNode(box(SCNVector3(0.38, 0.78, 0.38), color: UIColor(red: 0.12, green: 0.25, blue: 0.78, alpha: 1)))
            rightLeg.addChildNode(box(SCNVector3(0.38, 0.78, 0.38), color: UIColor(red: 0.12, green: 0.25, blue: 0.78, alpha: 1)))
            player.addChildNode(leftLeg)
            player.addChildNode(rightLeg)

            let face = SCNNode(geometry: SCNPlane(width: 0.34, height: 0.13))
            face.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            face.position = SCNVector3(0, 0.01, 0.316)
            head.addChildNode(face)
        }

        private func updateTiles() {
            let px = Int(floor(player.position.x / 20))
            let pz = Int(floor(player.position.z / 20))
            var needed = Set<String>()
            for x in (px - 2)...(px + 2) {
                for z in (pz - 2)...(pz + 2) {
                    let key = "\(x),\(z)"
                    needed.insert(key)
                    if tiles[key] == nil {
                        let tile = SCNNode(geometry: SCNBox(width: 20, height: 0.35, length: 20, chamferRadius: 0))
                        tile.geometry?.materials = [material(UIColor(red: 0.57, green: 0.59, blue: 0.62, alpha: 1))]
                        tile.position = SCNVector3(Float(x) * 20, -0.18, Float(z) * 20)
                        tile.castsShadow = false
                        scene.rootNode.addChildNode(tile)
                        tiles[key] = tile
                        addStuds(to: tile, x: x, z: z)
                    }
                }
            }
            for key in Array(tiles.keys) where !needed.contains(key) {
                tiles[key]?.removeFromParentNode()
                tiles.removeValue(forKey: key)
            }
        }

        private func addStuds(to tile: SCNNode, x: Int, z: Int) {
            let studMaterial = material(UIColor(red: 0.67, green: 0.69, blue: 0.71, alpha: 1))
            for sx in 0..<10 {
                for sz in 0..<10 {
                    let stud = SCNNode(geometry: SCNCylinder(radius: 0.19, height: 0.08))
                    stud.geometry?.materials = [studMaterial]
                    stud.position = SCNVector3(Float(sx) * 2 - 9, 0.21, Float(sz) * 2 - 9)
                    stud.castsShadow = false
                    tile.addChildNode(stud)
                }
            }
        }

        private func updateCamera() {
            let distance: Float = 7.4
            let target = SCNVector3(player.position.x, player.position.y + 1.35, player.position.z)
            let horizontal = cos(cameraPitch) * distance
            camera.position = SCNVector3(
                target.x + sin(cameraYaw) * horizontal,
                target.y + sin(cameraPitch) * distance + 0.4,
                target.z + cos(cameraYaw) * horizontal
            )
            camera.look(at: target)
        }

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            let delta = Float(min(0.05, max(0, time - (lastTime == 0 ? time : lastTime))))
            lastTime = time
            let x = Float(input.movement.x)
            let z = Float(input.movement.y)
            let magnitude = min(1, sqrt(x * x + z * z))
            if magnitude > 0.08 {
                let directionX = x * cos(cameraYaw) + z * sin(cameraYaw)
                let directionZ = z * cos(cameraYaw) - x * sin(cameraYaw)
                let length = max(0.001, sqrt(directionX * directionX + directionZ * directionZ))
                let speed: Float = 4.2
                player.position.x += directionX / length * speed * magnitude * delta
                player.position.z += directionZ / length * speed * magnitude * delta
                player.eulerAngles.y = atan2(directionX, directionZ)
                walkPhase += delta * 9
                leftLeg.eulerAngles.x = sin(walkPhase) * 0.65
                rightLeg.eulerAngles.x = -sin(walkPhase) * 0.65
            } else {
                leftLeg.eulerAngles.x *= 0.78
                rightLeg.eulerAngles.x *= 0.78
            }

            if input.jumpRequested {
                if grounded {
                    verticalVelocity = 6.2
                    grounded = false
                }
                DispatchQueue.main.async { self.input.jumpRequested = false }
            }
            verticalVelocity -= 15 * delta
            player.position.y += verticalVelocity * delta
            if player.position.y <= 0.12 {
                player.position.y = 0.12
                verticalVelocity = 0
                grounded = true
            }

            updateTiles()
            updateCamera()
        }
    }
}

//
//  ContentView.swift
//  3DMotion
//
//  Created by Christos Eteoglou on 2023-12-11.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    @State var motion: CMDeviceMotion? = nil
    let motionManager = CMMotionManager()
    let thresholdPitch: Double = 35 * .pi / 180
    let maxRotationAngle = 20.0
    
    var rotation: (x: Double, y: Double) {
        if let motion = motion {
            let pitchDegrees = min(maxRotationAngle, motion.attitude.pitch > thresholdPitch ? (motion.attitude.pitch - thresholdPitch) * (100.0 / .pi) : 0)
            let rollDegrees = min(maxRotationAngle, motion.attitude.roll * (100.0 / .pi))
            return(x: -pitchDegrees, y: rollDegrees)
        }
        return(x: 0, y:0)
    }
    
    var circleYOffset: CGFloat {
        if let motion = motion, motion.attitude.pitch > thresholdPitch {
            return CGFloat((motion.attitude.pitch - thresholdPitch) * 600.0 / .pi)
        }
        return 0
    }
    
    var body: some View {
        ZStack {
            Image("profile")
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                .rotation3DEffect(
                    .init(degrees: rotation.x),
                                          axis: (x: 1.0, y: 0.0, z: 0.0)
                )
                .rotation3DEffect(
                    .init(degrees: rotation.y),
                                          axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                Circle()
                .frame(width: 70, height: 70)
                .foregroundStyle(.white.opacity(0.6))
                .blur(radius: 40)
                .offset(x: motion != nil ? CGFloat(motion!.gravity.x * 400) : 0,  y: circleYOffset)
            //MARK: 400 is how fast or how much movement you want. For bigger a much bigger noticeable effect i picked 400. All you have to do is manipulate the numbers and create a movement that you like.
            
                .mask {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 300, height: 300)
                        .rotation3DEffect(
                            .init(degrees: rotation.x),
                                                  axis: (x: 1.0, y: 0.0, z: 0.0)
                        )
                        .rotation3DEffect(
                            .init(degrees: rotation.y),
                                                  axis: (x: 0.0, y: 1.0, z: 0.0)
                        )
                }
        }
        .onAppear {
            if motionManager .isDeviceMotionAvailable {
                self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
                self .motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
                    if let validData = data {
                        self.motion = validData
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

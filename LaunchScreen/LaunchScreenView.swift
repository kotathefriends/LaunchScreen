//
//  LaunchScreenView.swift
//  LaunchScreen
//
//  Created by KOTA TAKAHASHI on 2024/05/14.
//

import SwiftUI
import AVKit

struct PlayerView: UIViewControllerRepresentable {
    @Binding var isPlaying: Bool
    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        if isPlaying {
            playerController.player?.play()
        } else {
            playerController.player?.pause()
        }
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: Bundle.main.url(forResource: "Icon_Animation", withExtension: "mp4")!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        playerViewController.videoGravity = .resizeAspectFill
        
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
        
        // ハプティックフィードバックを生成する時間を指数関数で計算（時間軸を逆にする）
        let baseValue: Double = 1.1
        let maxTime: Double = 7.5
        let intervalCount: Int = 80
        
        var hapticTimes: [Double] = []
        
        for i in 0..<intervalCount {
            let time = maxTime - pow(baseValue, Double(i)) + 1
            if time >= 0 {
                hapticTimes.append(time)
            } else {
                break
            }
        }
        
        if let firstTime = hapticTimes.first, firstTime > 0 {
            hapticTimes[0] = 0
        }
        
        let lightThreshold = 0.1
        let mediumThreshold = 0.3
        let heavyThreshold = 0.45
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { time in
            for (index, hapticTime) in hapticTimes.enumerated() {
                if time.seconds >= hapticTime && time.seconds < hapticTime + 0.1 {
                    var generator: UIImpactFeedbackGenerator
                    if index < Int(Double(hapticTimes.count) * lightThreshold) {
                        generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            generator.impactOccurred()
                        }
                    } else if index < Int(Double(hapticTimes.count) * mediumThreshold) {
                        generator = UIImpactFeedbackGenerator(style: .heavy)
                    } else if index < Int(Double(hapticTimes.count) * heavyThreshold) {
                        generator = UIImpactFeedbackGenerator(style: .medium)
                    } else {
                        generator = UIImpactFeedbackGenerator(style: .light)
                    }
                    generator.impactOccurred()
                }
            }
        }
        
        return playerViewController
    }
}

struct LaunchScreenView: View {
    @State private var showOnboarding = false
    @State private var isPlaying = true
    
    var body: some View {
        ZStack {
            PlayerView(isPlaying: $isPlaying)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPlaying.toggle()
                }
            
            VStack {
                Spacer()
                
                Button(action: {
                    showOnboarding = true
                    isPlaying = false
                }) {
                    Text("次へ")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            isPlaying = true
        }) {
            OnboardingView()
        }
    }
}
#Preview {
    LaunchScreenView()
}

//
//  LaunchScreenView.swift
//  LaunchScreen
//
//  Created by KOTA TAKAHASHI on 2024/05/14.
//

import SwiftUI
import AVKit
import AVFoundation

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

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
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
                Image("BuyByFriends_Title")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 304)
                    .padding(.top, 120)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showOnboarding = true
                        isPlaying = false
                    }
                }) {
                    Text("Get started")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(50)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 16)
                
                Text("本アプリでは「Get started」を押した時点で、利用規約とプライバシーポリシーに同意いただいたことになります。")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text("ログイン")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                    .zIndex(1)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}

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
        
        // ハプティックフィードバックを追加
        let hapticTimes = [0.1, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.25, 3.5, 3.75, 4.0, 4.25, 4.5, 4.75, 5.0, 5.25, 5.5, 5.75, 6.0, 6.25, 6.5, 6.75, 7.0, 7.25, 7.5] // フィードバックを発生させる時間（秒）
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { time in
            for hapticTime in hapticTimes {
                if time.seconds >= hapticTime && time.seconds < hapticTime + 0.1 {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
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

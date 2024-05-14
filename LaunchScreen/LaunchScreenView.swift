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
    @Binding var shouldReplay: Bool
    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        if isPlaying {
            playerController.player?.play()
        } else {
            playerController.player?.pause()
        }
        
        if shouldReplay {
            playerController.player?.seek(to: CMTime.zero)
            playerController.player?.play()
            shouldReplay = false
        }
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: Bundle.main.url(forResource: "Icon_Animation", withExtension: "mp4")!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        playerViewController.videoGravity = .resizeAspectFill
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            isPlaying = false
        }
        
        return playerViewController
    }
}

struct LaunchScreenView: View {
    @State private var showOnboarding = false
    @State private var isPlaying = true
    @State private var shouldReplay = false
    
    var body: some View {
        ZStack {
            PlayerView(isPlaying: $isPlaying, shouldReplay: $shouldReplay)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if isPlaying {
                        isPlaying = false
                    } else {
                        shouldReplay = true
                        isPlaying = true
                    }
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

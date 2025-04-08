//
//  SplashScreenView.swift
//  ImageClassifierApp
//
//  Created by Rathi Shetty on 08/04/25.
//

import SwiftUI

// MARK: - SplashScreenView
struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.5

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2)) {
                                logoScale = 1.0
                                logoOpacity = 1.0
                            }
                        }
                    
                    Text("Image Classifier")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

//
//  ContentView.swift
//  ImageClassifierApp
//
//  Created by Rathi Shetty on 02/04/25.
//

import SwiftUI
import PhotosUI
import CoreML
import Vision
import AVFoundation

// MARK: - ContentView
struct ContentView: View {
    // MARK: - Properties
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var classificationResult: String = "Select an image to classify"
    @State private var showCameraView = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient Background
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // MARK: - Image Display
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 2))
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.secondary.opacity(0.4))
                            .frame(height: 300)
                            .overlay(Text("No Image Selected").foregroundColor(.white).font(.title3))
                            .shadow(radius: 5)
                    }

                    // MARK: - Capture & Picker Options
                    HStack(spacing: 20) {
                        PhotoPickerView(selectedItem: $selectedItem, selectedImage: $selectedImage, classifyImage: classifyImage)
                    }
                    
                    // MARK: - Classification Result
                    Text(classificationResult)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.8))
                        .foregroundColor(.blue)
                        .font(.headline)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }
                .padding()
                
                // MARK: - Floating Camera Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showCameraView = true
                        }) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 30)
                        .sheet(isPresented: $showCameraView) {
                            CameraView(selectedImage: $selectedImage, classifyImage: classifyImage)
                        }
                    }
                }
            }
            .navigationTitle("Image Classifier")
        }
    }

    // MARK: - Image Classification
    /// - Tag: classifyImage
    private func classifyImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            classificationResult = "Failed to convert UIImage to CIImage."
            return
        }

        do {
            let config = MLModelConfiguration()
            config.computeUnits = .cpuOnly // Ensuring compatibility
            
            let model = try MobileNetV2(configuration: config)
            let visionModel = try VNCoreMLModel(for: model.model)
            
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.classificationResult = "Error: \(error.localizedDescription)"
                        return
                    }
                    
                    if let results = request.results as? [VNClassificationObservation],
                       let topResult = results.first {
                        self.classificationResult = "✅ \(topResult.identifier) (\(Int(topResult.confidence * 100))%)"
                    } else {
                        self.classificationResult = "❌ Could not classify image."
                    }
                }
            }

            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    DispatchQueue.main.async {
                        self.classificationResult = "Error: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            classificationResult = "Failed to load model: \(error.localizedDescription)"
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

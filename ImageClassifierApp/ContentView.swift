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

// MARK: - PhotoPickerView
struct PhotoPickerView: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedImage: UIImage?
    var classifyImage: (UIImage) -> Void

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                Text(selectedImage == nil ? "Select Photo" : "Change Photo")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    classifyImage(uiImage)
                    
                    // Reset selection to ensure a fresh pick next time
                    selectedItem = nil
                }
            }
        }
    }
}

// MARK: - CameraView
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var classifyImage: (UIImage) -> Void

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.classifyImage(image)
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

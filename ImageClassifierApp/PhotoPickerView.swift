//
//  PhotoPickerView.swift
//  ImageClassifierApp
//
//  Created by Rathi Shetty on 08/04/25.
//

import SwiftUI
import PhotosUI

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

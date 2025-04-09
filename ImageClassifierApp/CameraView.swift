//
//  CameraView.swift
//  ImageClassifierApp
//
//  Created by Rathi Shetty on 08/04/25.
//

import SwiftUI

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


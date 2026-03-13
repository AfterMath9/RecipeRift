//
//  CameraPickerView.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-26.
//

import SwiftUI
import UIKit

struct CameraPickerView: UIViewControllerRepresentable {
    var onPhotoTaken: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPhotoTaken: onPhotoTaken)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onPhotoTaken: (UIImage) -> Void

        init(onPhotoTaken: @escaping (UIImage) -> Void) {
            self.onPhotoTaken = onPhotoTaken
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onPhotoTaken(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

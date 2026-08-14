//
//  KameraView.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import SwiftUI
import UIKit

struct KameraView: UIViewControllerRepresentable {
    var tamamlandi: (Data?) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let ebeveyn: KameraView

        init(_ ebeveyn: KameraView) {
            self.ebeveyn = ebeveyn
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var veri: Data?
            if let resim = info[.originalImage] as? UIImage {
                veri = resim.jpegData(compressionQuality: 1.0)
            }
            ebeveyn.tamamlandi(veri)
            ebeveyn.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            ebeveyn.dismiss()
        }
    }
}

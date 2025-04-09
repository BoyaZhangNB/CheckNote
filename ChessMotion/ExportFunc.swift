//
//  ExportFunc.swift
//  ChessMotion
//
//  Created by 张博亚 on 2025/4/8.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

/// A simple SwiftUI wrapper around UIDocumentPickerViewController for exporting a file.
struct DocumentExporter: UIViewControllerRepresentable {
    let exportURL: URL
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // “forExporting” means the user can pick where to save it.
        let controller = UIDocumentPickerViewController(forExporting: [exportURL], asCopy: true)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // no update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Export cancelled.")
        }
        // If you need to handle success or failure, you can implement these delegate methods:
        // func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) { }
    }
}

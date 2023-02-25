//
//  ContentView.swift
//  Featur
//
//  Created by iakalann on 24/02/2023.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth

struct ProfileView: View {
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    
    // Create a Storage instance
    let storage = Storage.storage()
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                showingImagePicker = true
            }) {
                Image(uiImage: profileImage ?? UIImage(systemName: "person.fill")!)
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    profileImage = image
                    uploadImageToFirebaseStorage(image: image)
                }
            }
            
            // Name and bio fields here
        }
    }
    
    func uploadImageToFirebaseStorage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profile_images/\(Auth.auth().currentUser!.uid)")
        
        let uploadTask = profileImageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    print("Error retrieving download URL: \(error.localizedDescription)")
                    return
                }
                // Save the download URL to the user's profile data
            }
        }
    }

}

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoordinator
    
    var sourceType: UIImagePickerController.SourceType
    var completionHandler: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return ImagePickerCoordinator(completionHandler: completionHandler)
    }
    
    class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var completionHandler: (UIImage) -> Void
        
        init(completionHandler: @escaping (UIImage) -> Void) {
            self.completionHandler = completionHandler
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.originalImage] as? UIImage else {
                print("Error: couldn't retrieve image from picker")
                return
            }
            completionHandler(image)
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

import SwiftUI

struct UploadImageView: View {
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var uploadStatus = "No upload yet"

    var body: some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(Text("Tap to select an image"))
            }
            
            Button("Select Image") {
                isShowingImagePicker = true
            }
            .padding()
            
            Button("Upload Image") {
                guard let image = selectedImage else { return }
                uploadTestImage(image) { result in
                    switch result {
                    case .success(let url):
                        uploadStatus = "Upload succeeded:\n\(url.absoluteString)"
                    case .failure(let error):
                        uploadStatus = "Upload failed:\n\(error.localizedDescription)"
                    }
                }
            }
            .padding()
            
            Text(uploadStatus)
                .multilineTextAlignment(.center)
                .padding()
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .padding()
    }
}

struct UploadImageView_Previews: PreviewProvider {
    static var previews: some View {
        UploadImageView()
    }
}

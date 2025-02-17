import FirebaseStorage
import UIKit

func uploadTestImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        completion(.failure(NSError(domain: "ImageConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image"])))
        return
    }
    
    let imageName = UUID().uuidString + ".jpg"
    let storageRef = Storage.storage().reference().child("recipeImages/\(imageName)")
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    
    storageRef.putData(imageData, metadata: metadata) { metadata, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        storageRef.downloadURL { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                completion(.success(url))
            }
        }
    }
}

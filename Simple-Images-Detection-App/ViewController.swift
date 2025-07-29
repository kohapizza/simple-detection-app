import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    var capturedImage: UIImage?
    var capturedVideoURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // 動画も選べるようにする
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
    }

    @IBAction func takePhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "メディアを選択", message: "取得方法を選んでください", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "カメラで撮影", style: .default, handler: { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true)
            }))
        }

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "フォトライブラリから選択", style: .default, handler: { _ in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true)
            }))
        }

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        capturedImage = nil
        capturedVideoURL = nil
        
        if let mediaType = info[.mediaType] as? String {
            if mediaType == kUTTypeImage as String {
                if let image = info[.originalImage] as? UIImage {
                    capturedImage = image
                }
            } else if mediaType == kUTTypeMovie as String {
                if let url = info[.mediaURL] as? URL {
                    capturedVideoURL = url
                }
            }
        }
        
        picker.dismiss(animated: true) {
            self.performSegue(withIdentifier: "showPhotosViewController", sender: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotosViewController",
           let destVC = segue.destination as? PhotosViewController {
            destVC.takenImage = capturedImage
            destVC.takenVideoURL = capturedVideoURL
        }
    }
}

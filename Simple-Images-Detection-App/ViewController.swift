import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // カメラを使うためのコントローラー
    let imagePicker = UIImagePickerController()
    
    // 撮った写真を入れておく場所（あとで次の画面にわたす）
    var capturedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    // 「写真を撮る」ボタンが押されたときに呼ばれる
    @IBAction func takePhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "画像を選択", message: "画像の取得方法を選んでください", preferredStyle: .actionSheet)
        
        // カメラから
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "カメラで撮影", style: .default, handler: { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true)
            }))
        }

        // フォトライブラリから
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "フォトライブラリから選択", style: .default, handler: { _ in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true)
            }))
        }

        // キャンセル
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))

        present(alert, animated: true)
    }

    // 写真を撮ったあとに呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 撮った画像を取り出す
        if let image = info[.originalImage] as? UIImage {
            capturedImage = image  // 撮った写真を保存しておく
        }
        
        // カメラ画面を閉じる → 次の画面へ移動
        picker.dismiss(animated: true) {
            self.performSegue(withIdentifier: "showPhotosViewController", sender: nil)
        }
    }

    // 写真を撮るのをやめたときに呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // カメラ画面を閉じるだけ
        picker.dismiss(animated: true)
    }

    // 次の画面（写真を表示する画面）へ行く前に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 次に行く画面が PhotosViewController のとき
        if segue.identifier == "showPhotosViewController",
           let destVC = segue.destination as? PhotosViewController {
            // 撮った写真を次の画面にわたす
            destVC.takenImage = capturedImage
        }
    }
}

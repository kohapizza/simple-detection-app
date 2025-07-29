//
//  MachineLearningHelper.swift
//  Simple-Images-Detection-App
//
//  Created by 佐伯小遥 on 2025/05/19.
//

import OpenAI
import UIKit

// 機械学習を手伝ってくれるクラス（1つだけ作ってどこでも使えるようにするために）
class MachineLearningHelper {
    static let shared = MachineLearningHelper()  // 1回だけ使うインスタンス（シングルトン）
    
    typealias Message = ChatQuery.ChatCompletionMessageParam
    typealias Content = Message.ChatCompletionUserMessageParam.Content
    typealias Detail = Content.VisionContent.ChatCompletionContentPartImageParam.ImageURL.Detail
    

    // OpenAIを使うための設定。自分のAPIキーを入力する
    
    private let openAI = OpenAI(apiToken: "API_KEY")
    
    // 画像をもとに、AIに「何が映っているか」を説明してもらう関数
    // 質問のテキストをカスタマイズしてみよう！
    public func generateTextfromImage(imageData: Data) async -> String {
        do {
            // ChatGPT（GPT-4o）に、画像と質問を送って、答えをもらう
            let query = ChatQuery(messages: [
                .user(.init(content: .vision([
                    // 質問のテキスト
                    .chatCompletionContentPartTextParam(.init(text: "以下の画像には何が映っていますか？説明してください。")),
                    // 画像のデータを送る
                    .chatCompletionContentPartImageParam(.init(imageUrl: .init(url: imageData, detail: .auto)))
                ])))
            ], model: .gpt4_o, maxTokens: 100)  // モデルにGPT-4oを指定。最大トークン数は100
            
            // ChatGPTに質問を送り、返事を待つ
            let result = try await openAI.chats(query: query)
            
            // 答えを取り出してテキストとして返す
            if let choice = result.choices.first,
               let text = choice.message.content?.string {
                return text
            }
        } catch {
            // もし失敗したら、エラー内容を出力
            print("分析失敗: \(error)")
        }

        // うまくいかなかった時の出力
        return "分析に失敗しました"
    }
    
    // 複数の画像, textを受け取ってVisionContentを返す
//    private static func buildVisionContents(withImages images: [Data], text: String, detail: Detail = .auto) -> [Content.VisionContent] {
//        var visionContents: [Content.VisionContent] = [.init(chatCompletionContentPartTextParam: .init(text: text))]
//        for data in images {
//            // Base64に変換してData URIスキームとして埋め込む
//            let base64String = data.base64EncodedString()
//            let dataURLString = "data:image/jpeg;base64,\(base64String)"
//            visionContents.append(
//                .init(chatCompletionContentPartImageParam: .init(imageUrl: .init(url: dataURLString, detail: detail)))
//            )
//        }
//        return visionContents
//    }
    
//    private static func buildMessages(text: String, images: [Data], systemMessage: String? = nil, detail: Detail = .auto) -> [ChatQuery.ChatCompletionMessageParam] {
//        let visionContents = buildVisionContents(withImages: images, text: text, detail: detail)
//        var messages: [ChatQuery.ChatCompletionMessageParam] = [.init(role: .user, content: visionContents)!]
//        if let systemMessage {
//            messages.append(.init(role: .system, content: systemMessage)!)
//        }
//        return messages
//    }
//    
//    public func sendMessage(text: String, images: [Data], systemMessage: String? = nil, detail: Detail = .auto, maxTokens: Int? = nil) -> AsyncThrowingStream<ChatStreamResult, Error> {
//        print("Sending \(images.count) images. Total size: \(images.reduce(0) { $0 + $1.count }) bytes")
//        let messages = MachineLearningHelper.buildMessages(text: text, images: images, systemMessage: systemMessage, detail: detail)
//        return sendStream(messages: messages, maxTokens: maxTokens)
//    }
//    
//    private func sendStream(messages: [ChatQuery.ChatCompletionMessageParam], maxTokens: Int? = nil) -> AsyncThrowingStream<ChatStreamResult, Error> {
//        let query = ChatQuery(messages: messages, model: .gpt4_o, maxTokens: maxTokens)
//        return openAI.chatsStream(query: query)
//    }
    

//    func analyzeVideoFrames(videoURL: URL) async throws -> AsyncThrowingStream<ChatStreamResult, Error> {
//        // フレームを抽出（1秒ごと）
//        let cgImages = try await VideoUtils.extractFrames(from: videoURL, timeInterval: 5.0)
//        
//        print("抽出されたフレーム数: \(cgImages.count)")
//        
//        // CGImage -> UIImage -> Data
//        let imageDataArray: [Data] = cgImages.compactMap { cgImage in
//            let uiImage = UIImage(cgImage: cgImage)
//            if let data = uiImage.jpegData(compressionQuality: 0.8) {
//                return data
//            } else {
//                print("⚠️ jpegDataの変換に失敗しました（CGImageから作成したUIImageが不正な可能性）")
//                return nil
//            }
//        }
//        
//        // もし画像が1つも取得できなければエラーにする
//        guard !imageDataArray.isEmpty else {
//            print("❌ jpegData変換後のデータ配列が空です。")
//            throw NSError(domain: "VideoAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "フレームが抽出できませんでした（画像データ生成に失敗）"])
//        }
//        
//        // 質問文
//        let prompt = """
//        以下の画像は、動画から抽出した連続するフレームです。この動画では何が起きていますか？全体の内容を時系列で要約してください。
//        """
//        
//        // MachineLearningHelperからストリームを取得
//        let helper = MachineLearningHelper.shared
//        return helper.sendMessage(
//            text: prompt,
//            images: imageDataArray,
//            detail: .low,
//            maxTokens: 300
//        )
//    }
    
    
}

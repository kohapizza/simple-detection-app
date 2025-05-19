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

    // OpenAIを使うための設定。自分のAPIキーを入力する
    private let openAI = OpenAI(apiToken: "YOUR_API_KEY")
    
    // 画像をもとに、AIに「何が映っているか」を説明してもらう関数
    // 質問のテキストをカスタマイズしてみよう！
    func generateTextfromImage(imageData: Data) async -> String {
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
               let text = choice.message.content {
                return text
            }
        } catch {
            // もし失敗したら、エラー内容を出力
            print("分析失敗: \(error)")
        }

        // うまくいかなかった時の出力
        return "分析に失敗しました"
    }
}

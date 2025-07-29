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
    
    enum ImageSource {
        case data(Data)
        case url(URL)
    }


    // OpenAIを使うための設定。自分のAPIキーを入力する
    
    private let openAI = OpenAI(apiToken: "")
    
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
    
    // MARK: - Private Methods
    private func send(messages: [ChatQuery.ChatCompletionMessageParam], maxTokens: Int? = nil) async throws -> ChatResult {
        let query = ChatQuery(messages: messages, model: .gpt4_o, maxTokens: maxTokens)
        return try await openAI.chats(query: query)
    }

    private func sendStream(messages: [ChatQuery.ChatCompletionMessageParam], maxTokens: Int? = nil) -> AsyncThrowingStream<ChatStreamResult, Error> {
        let query = ChatQuery(messages: messages, model: .gpt4_o, maxTokens: maxTokens)
        return openAI.chatsStream(query: query)
    }

    private static func buildVisionContents(withImages images: [Data], text: String, detail: Detail = .auto) -> [Content.VisionContent] {
        var visionContents: [Content.VisionContent] = [.init(chatCompletionContentPartTextParam: .init(text: text))]
        for data in images {
            visionContents.append(
                .init(chatCompletionContentPartImageParam: .init(imageUrl: .init(url: data, detail: detail)))
            )
        }
        return visionContents
    }

    private static func buildVisionContents(withImage imageSource: ImageSource, text: String, detail: Detail = .auto) -> [Content.VisionContent] {
        var visionContents: [Content.VisionContent] = [.init(chatCompletionContentPartTextParam: .init(text: text))]
        switch imageSource {
        case let .data(imageData):
            visionContents.append(
                .init(chatCompletionContentPartImageParam: .init(imageUrl: .init(url: imageData, detail: detail)))
            )
        case let .url(imageURL):
            visionContents.append(
                .init(chatCompletionContentPartImageParam: .init(imageUrl: .init(url: imageURL.path, detail: detail)))
            )
        }
        return visionContents
    }

    private static func buildMessages(text: String, image: ImageSource? = nil, systemMessage: String? = nil) -> [ChatQuery.ChatCompletionMessageParam] {
        var messages: [ChatQuery.ChatCompletionMessageParam] = []
        if let image {
            messages.append(.init(role: .user, content: MachineLearningHelper.buildVisionContents(withImage: image, text: text))!)
        } else {
            messages.append(.init(role: .user, content: text)!)
        }
        if let systemMessage {
            messages.append(.init(role: .system, content: systemMessage)!)
        }
        return messages
    }

    private static func buildMessages(text: String, images: [Data], systemMessage: String? = nil, detail: Detail = .auto) -> [ChatQuery.ChatCompletionMessageParam] {
        let visionContents = buildVisionContents(withImages: images, text: text, detail: detail)
        var messages: [ChatQuery.ChatCompletionMessageParam] = [.init(role: .user, content: visionContents)!]
        if let systemMessage {
            messages.append(.init(role: .system, content: systemMessage)!)
        }
        return messages
    }

    // MARK: - Public Methods

    public func sendMessage(text: String, image: ImageSource? = nil, systemMessage: String? = nil) async throws -> String {
        let messages = MachineLearningHelper.buildMessages(text: text, image: image, systemMessage: systemMessage)
        return try await send(messages: messages).choices.first?.message.content?.string ?? ""
    }

    public func sendMessage(text: String, image: ImageSource? = nil, systemMessage: String? = nil) -> AsyncThrowingStream<ChatStreamResult, Error> {
        print("\(type(of: self))/\(#function)")
        let messages = MachineLearningHelper.buildMessages(text: text, image: image, systemMessage: systemMessage)
        return sendStream(messages: messages)
    }

    public func sendMessage(text: String, images: [Data], systemMessage: String? = nil, detail: Detail = .auto, maxTokens: Int? = nil) -> AsyncThrowingStream<ChatStreamResult, Error> {
        print("Sending \(images.count) images. Total size: \(images.reduce(0) { $0 + $1.count }) bytes")
        let messages = MachineLearningHelper.buildMessages(text: text, images: images, systemMessage: systemMessage, detail: detail)
        return sendStream(messages: messages, maxTokens: maxTokens)
    }
}

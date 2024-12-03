//
//  ReadJSON.swift
//  TheChase
//
//

import Foundation

//MARK: - structures and methods for defining and reading-in the Quiz Question Data

struct QuizQuestionData: Codable {
    let category : String
    var questions: [QuestionItems]
}

struct QuestionItems: Codable {
    let question_text : String
    let answers : [String]
    let correct : Int
}

func getJSONQuestionData() -> QuizQuestionData? {
    let bundleFolderURL = Bundle.main.url(forResource: "chase_questions", withExtension: "json")!
    do {
        let retrievedData = try Data(contentsOf: bundleFolderURL)
        do {
            let theQuizData = try JSONDecoder().decode(QuizQuestionData.self, from: retrievedData)
            return theQuizData
        } catch {
            print("couldn't decode file contents"); return nil
        }
    } catch {
        print("couldn't retrieve file contents"); return nil
    }
}

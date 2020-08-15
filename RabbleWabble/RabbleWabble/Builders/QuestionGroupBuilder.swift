//
//  QuestionGroupBuilder.swift
//  RabbleWabble
//
//  Created by 변재우 on 20190210//.
//  Copyright © 2019 Razeware, LLC. All rights reserved.
//

import Foundation

public class QuestionGroupBuilder {
	
	//1
	public var questions = [QuestionBuilder()]
	public var title = ""
	
	//2
	public func addNewQuestion() {
		let question = QuestionBuilder()
		questions.append(question)
	}
	
	public func removeQuestion(at index: Int) {
		questions.remove(at: index)
	}
	
	//3
	public func build() throws -> QuestionGroup {
		guard self.title.count > 0 else { throw Error.missingTitle}
		guard self.questions.count > 0 else { throw Error.missingQuestions}
		let questions = try self.questions.map { try $0.build() }
		
		return QuestionGroup(questions: questions, title: title)
	}
	
	public enum Error: String, Swift.Error {
		case missingTitle
		case missingQuestions
	}

}


public class QuestionBuilder {
	
	public var answer = ""
	public var hint = ""
	public var prompt = ""
	
	public func build() throws -> Question {
		guard answer.count > 0 else { throw Error.missingAnswer }
		guard prompt.count > 0 else { throw Error.missingPrompt }
		return Question(answer: answer, hint: hint, prompt: prompt)
	}
	
	public enum Error: String, Swift.Error {
		case missingAnswer
		case missingPrompt
	}
	
}

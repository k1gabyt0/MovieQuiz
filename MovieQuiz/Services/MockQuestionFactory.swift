final class MockQuestionFactory : QuestionFactoryProtocol {
    private var questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather".data(using: .utf8)!,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Dark Knight".data(using: .utf8)!,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Kill Bill".data(using: .utf8)!,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Avengers".data(using: .utf8)!,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Deadpool".data(using: .utf8)!,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Green Knight".data(using: .utf8)!,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Old".data(using: .utf8)!,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild".data(using: .utf8)!,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "Tesla".data(using: .utf8)!,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "Vivarium".data(using: .utf8)!,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        )
    ]
    weak var delegate: QuestionFactoryDelegate?

    func requestNextQuestion() {
        guard let idx = (0..<questions.count).randomElement() else {
            return
        }
        
        let question = questions[safe: idx]
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    func loadData() {}
}

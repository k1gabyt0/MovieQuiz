import UIKit

final class MovieQuizViewController: UIViewController {
    private var questions: Questions = Questions(all: mockQuestions)
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        show(quiz: convert(model: questions.current))
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        let isCorrect = questions.checkCurrentQuestion(answer: false)
        showAnswerResult(isCorrect: isCorrect)
        noButton.isEnabled = false // дисейблим чтобы нельзя было нажать 100 раз
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let isCorrect = questions.checkCurrentQuestion(answer: true)
        showAnswerResult(isCorrect: isCorrect)
        yesButton.isEnabled = false // дисейблим чтобы нельзя было нажать 100 раз
    }
    
    
    private func show(quiz step: QuizStepViewModel) {
        cleanUp()
        
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        questionLabel.text = step.question
    }
    
    private func show(quiz result: QuizResultViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.questions.reset()
            
            let viewModel = self.convert(model: self.questions.current)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        let hasNextQuestion = questions.next()
        if !hasNextQuestion {
            let result = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(questions.correctAnswers)/\(questions.count)",
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: result)
        } else {
            show(quiz: convert(model: questions.current))
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? getDefaultImage(),
            question: model.text,
            questionNumber: "\(questions.currentIdx + 1)/\(questions.count)"
        )
    }
    
    private func cleanUp() {
        imageView.layer.borderColor = nil
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    private func getDefaultImage() -> UIImage {
        UIImage(named: "Default") ?? UIImage()
    }
}

private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
    
    func check(answer: Bool) -> Bool {
        return answer == correctAnswer
    }
}

private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

private struct QuizResultViewModel {
    let title: String
    let text: String
    let buttonText: String
}

private struct Questions {
    private let all: [QuizQuestion]
    private var _currentIdx: Int = 0
    private var _correctAnswers: Int = 0
    
    var current: QuizQuestion {
        all[currentIdx]
    }
    var currentIdx: Int {
        get {
            _currentIdx
        }
        set {
            _currentIdx = newValue
        }
    }
    var count: Int {
        all.count
    }
    
    var correctAnswers: Int {
        set {
            _correctAnswers = newValue
        }
        get {
            _correctAnswers
        }
    }
    
    init(all: [QuizQuestion]) {
        self.all = all
    }
    
    mutating func checkCurrentQuestion(answer: Bool) -> Bool {
        let isCorrect = current.check(answer: answer)
        if isCorrect {
            correctAnswers += 1
        }
        return isCorrect
    }
    
    mutating func next() -> Bool {
        if currentIdx >= all.count - 1 {
            return false
        }
        currentIdx += 1
        return true
    }
    
    mutating func reset() {
        currentIdx = 0
        correctAnswers = 0
    }
}

private var mockQuestions: [QuizQuestion] = [
    QuizQuestion(
        image: "The Godfather",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizQuestion(
        image: "The Dark Knight",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizQuestion(
        image: "Kill Bill",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizQuestion(
        image: "The Avengers",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizQuestion(
        image: "Deadpool",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizQuestion(
        image: "The Green Knight",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    QuizQuestion(
        image: "Old",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    ),
    QuizQuestion(
        image: "The Ice Age Adventures of Buck Wild",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    ),
    QuizQuestion(
        image: "Tesla",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    ),
    QuizQuestion(
        image: "Vivarium",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    )
]

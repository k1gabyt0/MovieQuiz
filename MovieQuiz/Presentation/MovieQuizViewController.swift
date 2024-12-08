import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var correctAnswersCount: Int = 0
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            show(quiz: convert(model: firstQuestion))
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let isCorrect = currentQuestion.check(answer: false)
        if isCorrect {
            correctAnswersCount += 1
        }
        
        showAnswerResult(isCorrect: isCorrect)
        noButton.isEnabled = false // дисейблим чтобы нельзя было нажать 100 раз
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let isCorrect = currentQuestion.check(answer: true)
        if isCorrect {
            correctAnswersCount += 1
        }
        
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
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            correctAnswersCount = 0
            
            if let firstQuestion = questionFactory.requestNextQuestion() {
                currentQuestionIndex = 0
                currentQuestion = firstQuestion
                show(quiz: convert(model: firstQuestion))
            }
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
        if currentQuestionIndex == questionsAmount-1 {
            let result = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswersCount)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: result)
            return
        }
        
        if let nextQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = nextQuestion
            currentQuestionIndex += 1
            show(quiz: convert(model: nextQuestion))
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? getDefaultImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
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

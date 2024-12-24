import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private let token = "<ТОКЕН ВСТАВИТЬ СЮДА>"
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswersCount: Int = 0
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol = AlertPresenter()
    private var statisticsService: StatisticsServiceProtocol = StatisticsService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(token: token), delegate: self)
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.controller = self
        self.alertPresenter = alertPresenter
        
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let isCorrect = currentQuestion.isCorrect(answer: false)
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
        
        let isCorrect = currentQuestion.isCorrect(answer: true)
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
        let alertText = """
        \(result.text)
        Количество сыгранных квизов: \(statisticsService.gamesCount)
        Рекорд: \(statisticsService.bestGame.correct)/\(statisticsService.bestGame.total) (\(statisticsService.bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticsService.totalAccuracy))%
        """
        
        let alertModel = AlertModel(
            title: result.title,
            message: alertText,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                correctAnswersCount = 0
                currentQuestionIndex = 0
                
                questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter.showAlert(alert: alertModel)
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
            let thisGame = GameResult(correct: correctAnswersCount, total: questionsAmount, date: Date())
            statisticsService.store(game: thisGame)
            
            let result = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(thisGame.correct)/\(thisGame.total)",
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: result)
            return
        }
        
        currentQuestionIndex += 1
        questionFactory?.requestNextQuestion()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func cleanUp() {
        imageView.layer.borderWidth = 0
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    private func getDefaultImage() -> UIImage {
        UIImage(named: "Default") ?? UIImage()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
            
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswersCount = 0
            
            showLoadingIndicator()
            self.questionFactory?.requestNextQuestion()
        }
            
        alertPresenter.showAlert(alert: model)
    }
}

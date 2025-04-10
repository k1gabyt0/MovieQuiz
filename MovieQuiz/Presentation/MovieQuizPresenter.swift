import UIKit

final class MovieQuizPresenter {
    private var questionFactory: QuestionFactoryProtocol!
    private var statisticsService: StatisticsServiceProtocol!
    
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswersCount: Int = 0
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(_ viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticsService = StatisticsService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory.loadData()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        questionFactory.requestNextQuestion()
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let isCorrect = currentQuestion.isCorrect(answer: false)
        if isCorrect {
            correctAnswersCount += 1
        }
        
        showAnswerResult(isCorrect: isCorrect)
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let isCorrect = currentQuestion.isCorrect(answer: true)
        if isCorrect {
            correctAnswersCount += 1
        }
        
        showAnswerResult(isCorrect: isCorrect)
    }
    
    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            let thisGame = GameResult(correct: correctAnswersCount, total: questionsAmount, date: Date())
            statisticsService.store(game: thisGame)
            
            let result = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(thisGame.correct)/\(thisGame.total)",
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: result)
            return
        }
        
        switchToNextQuestion()
        requestNextQuestion()
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNextQuestionOrResults()
        }
    }
    
    func getGameEndText(quiz result: QuizResultViewModel) -> String {
        return """
        \(result.text)
        Количество сыгранных квизов: \(statisticsService.gamesCount)
        Рекорд: \(statisticsService.bestGame.correct)/\(statisticsService.bestGame.total) (\(statisticsService.bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticsService.totalAccuracy))%
        """
    }
    
    private func requestNextQuestion() {
        viewController?.showLoadingIndicator()
        defer { viewController?.hideLoadingIndicator() }
        
        questionFactory.requestNextQuestion()
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async {
            self.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        
        requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}

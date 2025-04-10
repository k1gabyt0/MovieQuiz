import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenterProtocol!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter = MovieQuizPresenter(self)
        self.alertPresenter = AlertPresenter(self)
        
        activityIndicator.hidesWhenStopped = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
        noButton.isEnabled = false // дисейблим чтобы нельзя было нажать 100 раз
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
        yesButton.isEnabled = false // дисейблим чтобы нельзя было нажать 100 раз
    }
    
    
    func show(quiz step: QuizStepViewModel) {
        cleanUp()
        
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        questionLabel.text = step.question
    }
    
    func show(quiz result: QuizResultViewModel) {
        let alertText = presenter.getGameEndText(quiz: result)
        
        let alertModel = AlertModel(
            title: result.title,
            message: alertText,
            buttonText: result.buttonText,
            accesibilityIdentifier: "Game results",
            completion: { [weak self] in
                guard let self = self else { return }
                
                presenter.restartGame()
            }
        )
        
        alertPresenter.showAlert(alert: alertModel)
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
         imageView.layer.masksToBounds = true
         imageView.layer.borderWidth = 8
         imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
     }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
            
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            accesibilityIdentifier: "Error message"
        ) { [weak self] in
            guard let self = self else { return }
            
            presenter.restartGame()
        }
            
        alertPresenter.showAlert(alert: model)
    }
    
    private func cleanUp() {
        imageView.layer.borderWidth = 0
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    private func getDefaultImage() -> UIImage {
        UIImage(named: "Default") ?? UIImage()
    }
}

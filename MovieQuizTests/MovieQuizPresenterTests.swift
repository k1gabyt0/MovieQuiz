import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerStub()
        let sut = MovieQuizPresenter(viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Текст вопроса", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Текст вопроса")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

final class MovieQuizViewControllerStub: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {}
    func show(quiz result: QuizResultViewModel) {}
    
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    
    func showNetworkError(message: String) {}
}

import Foundation

struct QuizQuestion {
    let image: Data
    let text: String
    let correctAnswer: Bool
    
    func isCorrect(answer: Bool) -> Bool {
        return answer == correctAnswer
    }
}

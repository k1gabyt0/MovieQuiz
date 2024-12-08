import Foundation

struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
    
    func check(answer: Bool) -> Bool {
        return answer == correctAnswer
    }
}

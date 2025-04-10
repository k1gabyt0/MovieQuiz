import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ anotherResult: GameResult) -> Bool {
        correct > anotherResult.correct
    }
}

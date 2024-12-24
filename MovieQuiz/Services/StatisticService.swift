import Foundation

final class StatisticsService: StatisticsServiceProtocol {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        
        case answers
        case games
        case correctAnswers
    }
    private var answers: Int {
        set {
            storage.set(newValue, forKey: Keys.answers.rawValue)
        }
        get {
            storage.integer(forKey: Keys.answers.rawValue)
        }
    }

    private var correctAnswers: Int {
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.games.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.games.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let bestGameCorrect = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let bestGameTotal = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let bestGameDate = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: bestGameCorrect, total: bestGameTotal, date: bestGameDate)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        if answers == 0 {
            return 0
        }
        return Double(correctAnswers) / Double(answers) * 100
    }
    
    func store(game result: GameResult) {
        gamesCount += 1
        answers += result.total
        correctAnswers += result.correct
        if result.isBetterThan(bestGame) {
            bestGame = result
        }
    }
}

import Foundation

protocol StatisticsServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(game result: GameResult)
}

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient: NetworkRouting
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    private enum CustomError: LocalizedError {
        case errorMessage(String)
        
        var errorDescription: String? {
            switch self {
            case .errorMessage(let msg):
                return msg
            }
        }
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                   
                    let errMsg = mostPopularMovies.errorMessage
                    if !errMsg.isEmpty {
                        handler(.failure(CustomError.errorMessage(errMsg)))
                        return
                    }
                    if mostPopularMovies.items.isEmpty{
                        handler(.failure(CustomError.errorMessage("there are no movies")))
                        return
                    }
                    
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

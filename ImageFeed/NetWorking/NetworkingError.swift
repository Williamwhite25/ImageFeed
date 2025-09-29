
import Foundation

enum NetworkError: Error {
    case invalidRequest
    case decodingError(Error)
    case requestAlreadyInProgress
    case invalidResponse
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

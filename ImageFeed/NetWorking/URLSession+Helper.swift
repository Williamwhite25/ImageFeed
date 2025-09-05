import Foundation

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnMain: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async { completion(result) }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                if 200 ..< 300 ~= response.statusCode {
                    fulfillCompletionOnMain(.success(data))
                } else {
                    fulfillCompletionOnMain(.failure(NetworkError.httpStatusCode(response.statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnMain(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnMain(.failure(NetworkError.urlSessionError))
            }
        }
        return task
    }
}

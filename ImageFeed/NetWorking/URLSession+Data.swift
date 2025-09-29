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
                    let errorMessage = "[dataTask]: NetworkError - код ошибки \(response.statusCode)"
                    print(errorMessage)
                    fulfillCompletionOnMain(.failure(NetworkError.httpStatusCode(response.statusCode)))
                }
            } else if let error = error {
                let errorMessage = "[dataTask]: URLRequestError - \(error.localizedDescription)"
                print(errorMessage)
                fulfillCompletionOnMain(.failure(NetworkError.urlRequestError(error)))
            } else {
                let errorMessage = "[dataTask]: URLSessionError"
                print(errorMessage)
                fulfillCompletionOnMain(.failure(NetworkError.urlSessionError))
            }
        }
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}



//import Foundation
//
//extension URLSession {
//    func data(
//        for request: URLRequest,
//        completion: @escaping (Result<Data, Error>) -> Void
//    ) -> URLSessionTask {
//        let fulfillCompletionOnMain: (Result<Data, Error>) -> Void = { result in
//            DispatchQueue.main.async { completion(result) }
//        }
//        
//        let task = dataTask(with: request) { data, response, error in
//            if let data = data, let response = response as? HTTPURLResponse {
//                if 200 ..< 300 ~= response.statusCode {
//                    fulfillCompletionOnMain(.success(data))
//                } else {
//                    fulfillCompletionOnMain(.failure(NetworkError.httpStatusCode(response.statusCode)))
//                }
//            } else if let error = error {
//                fulfillCompletionOnMain(.failure(NetworkError.urlRequestError(error)))
//            } else {
//                fulfillCompletionOnMain(.failure(NetworkError.urlSessionError))
//            }
//        }
//        return task
//    }
//}

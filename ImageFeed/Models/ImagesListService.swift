
import Foundation

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var isLoading = false

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true

        let nextPage = lastLoadedPage + 1
                
        let urlString = "\(Constants.defaultBaseURL)/photos?page=\(nextPage)&client_id=\(Constants.accessKey)"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

       
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.isLoading = false }

            if let error = error {
                print("Error fetching photos: \(error)")
                return
            }

            guard let data = data else {
                return
            }

            
            do {
                let decoder = JSONDecoder()
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                
               
                let newPhotos = photoResults.map { Photo(from: $0) }
                self?.photos.append(contentsOf: newPhotos)
                self?.lastLoadedPage = nextPage

                // Обновляем UI на главном потоке
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
            } catch {
                print("Error decoding photos: \(error)")
            }
        }
        task.resume() 
    }
}




//
//import Foundation
//
//final class ImagesListService {
//    private(set) var photos: [Photo] = [] // Массив для хранения загруженных фотографий
//    private var lastLoadedPage: Int? // Номер последней загруженной страницы
//    private var isLoading = false // Флаг для проверки, идет ли сейчас загрузка
//    
//    // Замыкание для обновления UI
//    var onPhotosUpdated: (() -> Void)?
//
//    // Функция для получения следующей страницы фотографий
//    func fetchPhotosNextPage() {
//        // Проверяем, идет ли сейчас загрузка
//        guard !isLoading else {
//            return // Если загрузка идет, выходим из функции
//        }
//
//        isLoading = true // Устанавливаем флаг загрузки
//
//        // Определяем номер следующей страницы
//        let nextPage = (lastLoadedPage ?? 0) + 1
//        
//        // Пример сетевого запроса (замените на ваш метод загрузки)
//        let urlString = "https://example.com/photos?page=\(nextPage)"
//        guard let url = URL(string: urlString) else {
//            isLoading = false
//            return // Если не удалось создать URL, выходим из функции
//        }
//
//        // Выполняем запрос
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            defer { self?.isLoading = false } // Сбрасываем флаг после завершения запроса
//            
//            // Обработка ошибок
//            if let error = error {
//                print("Error fetching photos: \(error)")
//                return
//            }
//
//            guard let data = data else {
//                return // Если нет данных, выходим
//            }
//
//            // Декодируем полученные данные в массив Photo
//            do {
//                let decoder = JSONDecoder()
//                let photoResponse = try decoder.decode([Photo].self, from: data)
//                self?.photos.append(contentsOf: photoResponse) // Добавляем новые фотографии в массив
//                self?.lastLoadedPage = nextPage // Обновляем номер последней загруженной страницы
//
//                // Обновляем UI на главном потоке
//                DispatchQueue.main.async {
//                    self?.onPhotosUpdated?() // Вызываем замыкание для обновления UI
//                }
//            } catch {
//                print("Error decoding photos: \(error)")
//            }
//        }
//        task.resume() // Запускаем запрос
//    }
//}

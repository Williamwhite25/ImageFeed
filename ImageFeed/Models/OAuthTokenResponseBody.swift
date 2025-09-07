<<<<<<< HEAD


=======
>>>>>>> d5e9bcf49a06540daeebccb1100a45df8f5f2041
import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

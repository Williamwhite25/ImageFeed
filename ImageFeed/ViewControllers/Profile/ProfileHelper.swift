import UIKit

enum ProfileHelper {
    static let defaultName = "Имя не указано"
    static let defaultLogin = "@неизвестный_пользователь"
    static let defaultBio = "Профиль не заполнен"

    static func formattedName(from profile: Profile) -> String {
        let trimmed = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultName : trimmed
    }

    static func formattedLogin(from profile: Profile) -> String {
        let trimmed = profile.loginName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultLogin : trimmed
    }

    static func formattedBio(from profile: Profile) -> String {
        let bio = profile.bio ?? ""
        let trimmed = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultBio : trimmed
    }

    static func avatarURL(from string: String?) -> URL? {
        guard let s = string?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else {
            return nil
        }
        return URL(string: s)
    }

    static func placeholderAvatar(sizePointSize: CGFloat = 70) -> UIImage? {
        UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: sizePointSize, weight: .regular, scale: .large))
    }
}

import ActivityKit
import Foundation

struct QuitSmokingActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let avoidedCigarettes: Int
        let savedMoney: Double
    }

    let quitDate: Date
}

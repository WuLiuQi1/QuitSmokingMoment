import Foundation
import SwiftData

@Model
final class QuitProfile {
    var cigarettesPerDay: Int
    var packPrice: Double
    var cigarettesPerPack: Int
    var smokingYears: Int
    var quitDate: Date

    init(
        cigarettesPerDay: Int = 10,
        packPrice: Double = 20,
        cigarettesPerPack: Int = 20,
        smokingYears: Int = 5,
        quitDate: Date = .now
    ) {
        self.cigarettesPerDay = cigarettesPerDay
        self.packPrice = packPrice
        self.cigarettesPerPack = cigarettesPerPack
        self.smokingYears = smokingYears
        self.quitDate = quitDate
    }
}

@Model
final class CravingRecord {
    var createdAt: Date
    var intensity: Int
    var trigger: String
    var didSmoke: Bool
    var cigaretteCount: Int

    init(
        createdAt: Date = .now,
        intensity: Int,
        trigger: String = "",
        didSmoke: Bool = false,
        cigaretteCount: Int = 0
    ) {
        self.createdAt = createdAt
        self.intensity = intensity
        self.trigger = trigger
        self.didSmoke = didSmoke
        self.cigaretteCount = cigaretteCount
    }
}


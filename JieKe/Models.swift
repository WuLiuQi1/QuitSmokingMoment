import Foundation
import SwiftData

@Model
final class QuitProfile {
    var cigarettesPerDay: Int
    var packPrice: Double
    var cigarettesPerPack: Int
    var smokingYears: Int
    var tarMilligramsPerCigarette: Double
    var quitDate: Date
    var highRiskScenes: String

    init(cigarettesPerDay: Int = 10, packPrice: Double = 20, cigarettesPerPack: Int = 20, smokingYears: Int = 5, tarMilligramsPerCigarette: Double = 10, quitDate: Date = .now, highRiskScenes: String = "") {
        self.cigarettesPerDay = cigarettesPerDay
        self.packPrice = packPrice
        self.cigarettesPerPack = cigarettesPerPack
        self.smokingYears = smokingYears
        self.tarMilligramsPerCigarette = tarMilligramsPerCigarette
        self.quitDate = quitDate
        self.highRiskScenes = highRiskScenes
    }
}

@Model
final class CravingRecord {
    var createdAt: Date
    var intensity: Int
    var trigger: String
    var mood: String
    var note: String
    var copingMethod: String
    var didSmoke: Bool
    var cigaretteCount: Int
    var attachmentImageData: Data?
    var voiceMemoData: Data?

    init(createdAt: Date = .now, intensity: Int, trigger: String = "", mood: String = "平静", note: String = "", copingMethod: String = "", didSmoke: Bool = false, cigaretteCount: Int = 0, attachmentImageData: Data? = nil, voiceMemoData: Data? = nil) {
        self.createdAt = createdAt
        self.intensity = intensity
        self.trigger = trigger
        self.mood = mood
        self.note = note
        self.copingMethod = copingMethod
        self.didSmoke = didSmoke
        self.cigaretteCount = cigaretteCount
        self.attachmentImageData = attachmentImageData
        self.voiceMemoData = voiceMemoData
    }
}

@Model
final class DailyReflection {
    var createdAt: Date
    var mood: String
    var note: String

    init(createdAt: Date = .now, mood: String = "平静", note: String = "") {
        self.createdAt = createdAt
        self.mood = mood
        self.note = note
    }
}

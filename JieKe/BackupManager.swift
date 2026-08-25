import Foundation
import SwiftData

struct BackupArchive: Codable {
    let exportedAt: Date
    let profile: ProfileBackup?
    let records: [RecordBackup]
    let reflections: [ReflectionBackup]
}

struct ProfileBackup: Codable {
    let cigarettesPerDay: Int
    let packPrice: Double
    let cigarettesPerPack: Int
    let smokingYears: Int
    let tarMilligramsPerCigarette: Double
    let quitDate: Date
    let highRiskScenes: String

    init(_ profile: QuitProfile) {
        cigarettesPerDay = profile.cigarettesPerDay
        packPrice = profile.packPrice
        cigarettesPerPack = profile.cigarettesPerPack
        smokingYears = profile.smokingYears
        tarMilligramsPerCigarette = profile.tarMilligramsPerCigarette
        quitDate = profile.quitDate
        highRiskScenes = profile.highRiskScenes
    }
}

struct RecordBackup: Codable {
    let createdAt: Date
    let intensity: Int
    let trigger: String
    let mood: String
    let note: String
    let copingMethod: String
    let didSmoke: Bool
    let cigaretteCount: Int
    let attachmentImageData: Data?
    let voiceMemoData: Data?

    init(_ record: CravingRecord) {
        createdAt = record.createdAt
        intensity = record.intensity
        trigger = record.trigger
        mood = record.mood
        note = record.note
        copingMethod = record.copingMethod
        didSmoke = record.didSmoke
        cigaretteCount = record.cigaretteCount
        attachmentImageData = record.attachmentImageData
        voiceMemoData = record.voiceMemoData
    }
}

struct ReflectionBackup: Codable {
    let createdAt: Date
    let mood: String
    let note: String

    init(_ reflection: DailyReflection) {
        createdAt = reflection.createdAt
        mood = reflection.mood
        note = reflection.note
    }
}

enum BackupManager {
    static func export(profile: QuitProfile?, records: [CravingRecord], reflections: [DailyReflection]) throws -> URL {
        let archive = BackupArchive(
            exportedAt: .now,
            profile: profile.map(ProfileBackup.init),
            records: records.map(RecordBackup.init),
            reflections: reflections.map(ReflectionBackup.init)
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(archive)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("QuitSmokingMoment-backup-\(Int(Date.now.timeIntervalSince1970)).json")
        try data.write(to: url, options: .atomic)
        return url
    }

    static func load(from url: URL) throws -> BackupArchive {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(BackupArchive.self, from: data)
    }

    @MainActor
    static func restore(_ archive: BackupArchive, profiles: [QuitProfile], records: [CravingRecord], reflections: [DailyReflection], context: ModelContext) throws {
        profiles.forEach(context.delete)
        records.forEach(context.delete)
        reflections.forEach(context.delete)
        if let profile = archive.profile {
            context.insert(QuitProfile(cigarettesPerDay: profile.cigarettesPerDay, packPrice: profile.packPrice, cigarettesPerPack: profile.cigarettesPerPack, smokingYears: profile.smokingYears, tarMilligramsPerCigarette: profile.tarMilligramsPerCigarette, quitDate: profile.quitDate, highRiskScenes: profile.highRiskScenes))
        }
        for record in archive.records {
            context.insert(CravingRecord(createdAt: record.createdAt, intensity: record.intensity, trigger: record.trigger, mood: record.mood, note: record.note, copingMethod: record.copingMethod, didSmoke: record.didSmoke, cigaretteCount: record.cigaretteCount, attachmentImageData: record.attachmentImageData, voiceMemoData: record.voiceMemoData))
        }
        for reflection in archive.reflections {
            context.insert(DailyReflection(createdAt: reflection.createdAt, mood: reflection.mood, note: reflection.note))
        }
        try context.save()
    }
}

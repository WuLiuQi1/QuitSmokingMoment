import Foundation
import HealthKit

@MainActor
final class HealthManager: ObservableObject {
    @Published private(set) var stepCount = 0
    @Published private(set) var heartRate: Double?
    @Published private(set) var sleepHours: Double?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastUpdated: Date?
    private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAccessAndLoad() async {
        guard isAvailable else { errorMessage = "此设备不支持 HealthKit。"; return }
        guard let steps = HKObjectType.quantityType(forIdentifier: .stepCount), let heart = HKObjectType.quantityType(forIdentifier: .heartRate), let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { errorMessage = "无法读取所需的健康数据类型。"; return }
        do {
            try await store.requestAuthorization(toShare: [], read: [steps, heart, sleep])
            await refresh()
        } catch { errorMessage = "未获得健康数据权限，请在系统“健康”中允许戒刻读取数据。" }
    }

    func refresh() async {
        guard isAvailable else { return }
        isLoading = true
        errorMessage = nil
        async let steps: Void = loadSteps()
        async let heart: Void = loadHeartRate()
        async let sleep: Void = loadSleep()
        _ = await (steps, heart, sleep)
        lastUpdated = .now
        isLoading = false
    }

    private func loadSteps() async {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: .now), end: .now)
        stepCount = await withCheckedContinuation { continuation in
            store.execute(HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                continuation.resume(returning: Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0))
            })
        }
    }

    private func loadHeartRate() async {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        heartRate = await withCheckedContinuation { continuation in
            store.execute(HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                continuation.resume(returning: (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
            })
        }
    }

    private func loadSleep() async {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis), let start = Calendar.current.date(byAdding: .day, value: -1, to: .now) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        sleepHours = await withCheckedContinuation { continuation in
            store.execute(HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                let asleepValues: Set<Int> = [HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue, HKCategoryValueSleepAnalysis.asleepCore.rawValue, HKCategoryValueSleepAnalysis.asleepDeep.rawValue, HKCategoryValueSleepAnalysis.asleepREM.rawValue]
                let seconds = (samples as? [HKCategorySample] ?? []).filter { asleepValues.contains($0.value) }.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                continuation.resume(returning: seconds > 0 ? seconds / 3_600 : nil)
            })
        }
    }
}

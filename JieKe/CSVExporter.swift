import Foundation

enum CSVExporter {
    static func export(records: [CravingRecord]) throws -> URL {
        let formatter = ISO8601DateFormatter()
        let header = ["时间", "烟瘾强度", "心情", "诱因", "结果", "抽烟支数", "复盘", "应对方式"]
        let rows = records.map { record in
            [
                formatter.string(from: record.createdAt),
                String(record.intensity),
                record.mood,
                record.trigger,
                record.didSmoke ? "复吸" : "少吸",
                String(record.cigaretteCount),
                record.note,
                record.copingMethod
            ].map(escape).joined(separator: ",")
        }
        let csv = ([header.map(escape).joined(separator: ",")] + rows).joined(separator: "\n")
        let name = "QuitSmokingMoment-\(Int(Date().timeIntervalSince1970)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func escape(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}

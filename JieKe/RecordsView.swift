import SwiftUI

struct RecordsView: View {
    var body: some View {
        ContentUnavailableView(
            "还没有记录",
            systemImage: "square.and.pencil",
            description: Text("记录烟瘾、心情和诱因，更了解自己的戒烟过程。")
        )
        .navigationTitle("记录")
    }
}


import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "lock.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("ChronoLock")
                .font(.title)
            Text("Companion App")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
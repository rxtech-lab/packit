import Foundation

@main
enum PackitCommand {
    static func main() async throws {
        // start time
        let start = Date()
        let configuration = try Packit()
        try await configuration.run()
        // end time
        let end = Date()

        let timeInterval = end.timeIntervalSince(start)
        // leave 4 decimal places
        let time = String(format: "%.4f", timeInterval)
        print("Time: \(time) seconds")
    }
}

@main
enum PackitCommand {
    static func main() async throws {
        let configuration = try Packit()
        try await configuration.run()
    }
}

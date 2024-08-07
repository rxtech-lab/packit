import Foundation
import Glob
import Yams

/**
 * Read the configuration from a file.
 */
func readConfiguration(from path: String) throws -> Configuration {
    let fileManager = FileManager.default
    let currentPath = fileManager.currentDirectoryPath
    let fullPath = "\(currentPath)/\(path)"

    let data = try Data(contentsOf: URL(fileURLWithPath: fullPath))
    // use underscore decoding strategy for snake_case

    return try YAMLDecoder().decode(from: data)
}

class Packit {
    let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    init() throws {
        configuration = try readConfiguration(from: DEFAULT_CONFIGURATION_NAME)
    }

    func run() async throws {
        let patterns = configuration.input.patterns ?? ["*"]
        var ignore = configuration.input.ignore ?? []

        ignore.append(DEFAULT_CONFIGURATION_NAME)
        ignore.append(configuration.output.file)

        let files = try await glob(includePatterns: patterns, excludedPatterns: ignore)
        createOrOverwriteFile(at: URL(fileURLWithPath: configuration.output.file))

        for try await file in files {
            let content = try await readFile(at: file)
            print("Writing \(file.path) to \(configuration.output.file)")
            try await appendToEndFile(filename: file, content: content, at: URL(fileURLWithPath: configuration.output.file))
        }
    }
}

extension Packit {
    /**
     * Find files that match the patterns in the configuration.
     */
    func glob(includePatterns: [String], excludedPatterns: [String]) async throws -> AsyncThrowingStream<URL, Error> {
        let output = try Glob.search(
            directory: .init(filePath: FileManager.default.currentDirectoryPath),
            include: includePatterns.map { try Glob.Pattern($0) },
            exclude: excludedPatterns.map { try Glob.Pattern($0) },
            skipHiddenFiles: true
        )

        return output
    }

    func createOrOverwriteFile(at url: URL) {
        FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
    }

    func readFile(at url: URL) async throws -> String {
        return try String(contentsOf: url, encoding: .utf8)
    }

    /**
     * Append content to a file with its filename and content.
     */
    func appendToEndFile(filename: URL, content: String, at path: URL) async throws {
        let fileHandle = try FileHandle(forWritingTo: path)
        fileHandle.seekToEndOfFile()
        fileHandle.write("\(configuration.output.commentSymbol) File path: \(filename.absoluteString)".data(using: .utf8)!)
        fileHandle.write("\n".data(using: .utf8)!)
        fileHandle.write(content.data(using: .utf8)!)
        fileHandle.closeFile()
    }
}

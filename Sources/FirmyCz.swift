import Foundation
import ArgumentParser

@available(macOS 13.4, *)
@main
struct FirmyCz: ParsableCommand {
    @Option(name: .shortAndLong, help: "page limit, default: 150")
    var limit: UInt32 = 150
    
    @Option(name: .shortAndLong, help: "output file, default: ./data.csv")
    var output: String? = nil
    
    @Flag(name: .shortAndLong, help: "append to output file, defaul: false")
    var append = false
    
    @Argument(help: "search query")
    var query: String
    
    mutating func run() throws {
        query = query.replacingOccurrences(of: " ", with: "+")
        try write(try getFile(), try Scraper(query: query, pageLimit: limit).scrape())
        print("done!")
    }
    
    private func getFile() throws -> FileHandle {
        var filePath = FileManager().currentDirectoryPath + "/data.csv"
        
        if output != nil {
            filePath = output!
        }
        
        if !FileManager().fileExists(atPath: filePath) {
            FileManager().createFile(atPath: filePath, contents: nil)
        }
        
        let file = FileHandle(forWritingAtPath: filePath)
        
        if !append {
            try "".write(toFile: filePath, atomically: false, encoding: .utf8)
        }
        
        return file!
    }
    
    private func write(_ file: FileHandle, _ data: [[String]]) throws {
        print("writing file...")
        try file.seekToEnd()
        for row in data {
            for (i, col) in row.enumerated() {
                try file.write(contentsOf: col.data(using: .utf8)!)
                if i != row.count - 1 {
                    try file.write(contentsOf: ";".data(using: .utf8)!)
                }
            }
            try file.write(contentsOf: "\n".data(using: .utf8)!)
        }
    }
}

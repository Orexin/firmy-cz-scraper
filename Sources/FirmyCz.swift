import Foundation
import ArgumentParser

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
        let scraper = Scraper.init(query: query, pageLimit: limit)
        let data: [[String]] = try scraper.scrape()
        
        for d in data {
            print(d)
        }
    }
    
    func write() throws {
        
    }
}

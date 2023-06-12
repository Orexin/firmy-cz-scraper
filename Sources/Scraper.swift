import Foundation
import SwiftSoup
import Spinner

enum ScraperError: Error {
    case invalidUrl
    case invalidFormat
}

enum ScraperColumns {
    case title
    case address
    case web
    case phone
    case email
    case ico
    case description
    case firmylink
}

struct Scraper {
    private let baseUrl = "https://www.firmy.cz/?q="
    public let query: String
    public let pageLimit: UInt32
    public let formatt: String?
    public var columns: [ScraperColumns] = [ ScraperColumns.title, ScraperColumns.web, ScraperColumns.phone, ScraperColumns.email, ScraperColumns.firmylink ]
    
    public mutating func scrape() throws -> [[String]] {
        try parseFormat()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.orexin.con", attributes: .concurrent)
        
        let s1 = Spinner(.arc, "scraping firmy")
        s1.start()
        var allUrls: [String] = []
        for pageNumber in 1...pageLimit {
            queue.async(group: group) { [self] in
                do {
                    try _ = scrapeUrlsFromPage(pageNumber).map { allUrls.append($0) }
                } catch {
                    return
                }
            }
        }
        group.wait()
        s1.stop()
        print("firmy scraped: \(allUrls.count)")
        
        let s2 = Spinner(.arc, "scraping data")
        s2.start()
        var data: [[String]] = []
        for urlString in allUrls {
            queue.async(group: group) { [self] in
                guard let url = URL(string: urlString) else {
                    return
                }
                data.append(scrapeData(url))
            }
        }
        group.wait()
        s2.stop()
        
        return data
    }
    
    private func scrapeUrlsFromPage(_ pageNumber: UInt32) throws -> [String] {
        let urlString = baseUrl + query + "&page=\(pageNumber)"
        guard let url = URL(string: urlString) else {
            print("Invalid url: \(urlString)")
            throw ScraperError.invalidUrl
        }
        var urls: [String] = []
        let content = try String(contentsOf: url)
        let doc = try SwiftSoup.parse(content)
        let companies = try doc.select("a.companyTitle")
        for company in companies {
            urls.append(try company.attr("href"))
        }
        return urls
    }
    
    private func scrapeData(_ url: URL) -> [String] {
        var data: [String] = []
        do {
            let content = try String(contentsOf: url)
            let doc = try SwiftSoup.parse(content)
            
            // TODO: change the order of columns according to --format
            for col in columns {
                switch col {
                case .title:
                    data.append(try doc.select(".detailPrimaryTitle").text())
                case .address:
                    data.append(try doc.select(".detailAddress").text().replacingOccurrences(of: "Navigovat", with: ""))
                case .web:
                    data.append(try doc.select(".detailWebUrl").text())
                case .phone:
                    data.append(try doc.select(".detailPhone > span").text())
                case .email:
                    data.append(try doc.select(".detailEmail > a").text())
                case .ico:
                    data.append(try doc.select(".detailBusinessInfo").text().replacingOccurrences(of: "Více", with: ""))
                case .firmylink:
                    data.append(url.absoluteString)
                case .description:
                    // TODO: grab description
                    continue
                }
            }
        } catch {
            return data
        }
        return data
    }
    
    private mutating func parseFormat() throws {
        if formatt == nil {
            return
        }
        columns = []
        for col in formatt!.components(separatedBy: ";") {
            switch col {
            case "title":
                columns.append(ScraperColumns.title)
            case "address":
                columns.append(ScraperColumns.address)
            case "web":
                columns.append(ScraperColumns.web)
            case "phone":
                columns.append(ScraperColumns.phone)
            case "email":
                columns.append(ScraperColumns.email)
            case "ico":
                columns.append(ScraperColumns.ico)
            case "firmylink":
                columns.append(ScraperColumns.firmylink)
            case "description":
                // TODO: grab description
                continue
            default:
                throw ScraperError.invalidFormat
            }
        }
    }
}

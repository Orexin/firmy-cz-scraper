import Foundation
import SwiftSoup
import Spinner

enum ScraperError: Error {
    case invalidUrl
}

struct Scraper {
    private let baseUrl = "https://www.firmy.cz/?q="
    public let query: String
    public let pageLimit: UInt32
    
    public func scrape() throws -> [[String]] {
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
            data.append(try doc.select(".detailPrimaryTitle").text())
            data.append(try doc.select(".detailAddress").text().replacingOccurrences(of: "Navigovat", with: ""))
            data.append(try doc.select(".detailWebUrl").text())
            data.append(try doc.select(".detailPhone > span").text())
            data.append(try doc.select(".detailEmail > a").text())
            data.append(try doc.select(".detailBusinessInfo").text().replacingOccurrences(of: "Více", with: ""))
            // TODO: grab description
        } catch {
            return data
        }
        return data
    }
}

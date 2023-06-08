import Foundation
import SwiftSoup

let baseUrl = "https://www.firmy.cz/?q="
let query = "revizni+technik"

// https://www.firmy.cz/?q=revizni+technik&page=2

func scrapeUrlsFromPage(_ pageNumber: Int) -> [String] {
    let urlString = baseUrl + query + "&page=\(pageNumber)"
    guard let url = URL(string: baseUrl + query) else {
        print("\(urlString) is not a valid url")
        return []
    }
    var urls: [String] = []
    do {
        let content = try String(contentsOf: url)
        let doc = try SwiftSoup.parse(content)
        let companies = try doc.select("a.companyTitle")
        for company in companies {
            urls.append(try company.attr("href"))
        }
    } catch {
        print("eeeee")
        return urls
    }
    return urls
}

func scrapeData(_ url: URL) -> [String] {
    var data: [String] = []
    do {
        let content = try String(contentsOf: url)
        let doc = try SwiftSoup.parse(content)
        data.append(try doc.select(".detailPrimaryTitle").text())
        data.append(try doc.select(".detailAddress").text())
        data.append(try doc.select(".detailWebUrl").text())
        data.append(try doc.select(".detailPhone > span").text())
        data.append(try doc.select(".detailEmail > a").text())
        data.append(try doc.select(".detailBusinessInfo").text())
        
    } catch {
        print("jsi pica")
        return data
    }
    return data
}


for n in 1...10 {
    let urls = scrapeUrlsFromPage(n)
    for urlString in urls {
        guard let url = URL(string: urlString) else {
            print("\(urlString) is not a valid url")
            throw URLError(URLError.Code(rawValue: 1)) // wat
        }
        let data = scrapeData(url)
        for d in data {
            print(d, terminator: ";")
        }
        print("")
    }
}

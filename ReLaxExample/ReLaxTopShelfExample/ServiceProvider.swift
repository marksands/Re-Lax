import UIKit
import TVServices
import ReLax

let titles = ["Inside Out", "Ratatouille", "The Incredibles", "Toy Story", "Up"]

class ServiceProvider: NSObject, TVTopShelfProvider {
    private let posterImages: [ParallaxImage] = titles
        .map { $0.lowercased().components(separatedBy: .whitespaces).joined() }
        .map { movie in
            ["5", "4", "3", "2", "1"].map { return "\(movie)-\($0)" }
        }
        .flatMap {
            $0.flatMap { UIImage(named: $0) }
        }
        .map { ParallaxImage(images: $0) }
    
    var topShelfStyle: TVTopShelfContentStyle {
        return .sectioned
    }
    
    var topShelfItems: [TVContentItem] {
        let imagesWithIdentifiers: [(URL, String)] = zip(titles, posterImages)
            .flatMap { (title: String, parallaxImage: ParallaxImage) -> (URL, String)? in
                guard let cachesDirectory = try? FileManager.default.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false) else { return nil }
                let lcrFileURL = cachesDirectory.appendingPathComponent("\(title).lcr")
                
                do {
                    try parallaxImage.imageData().write(to: lcrFileURL, options: [])
                } catch {
                    return nil
                }
                
                return (lcrFileURL, title)
        }
        
        guard let contentIdentifier = TVContentIdentifier(identifier: UUID().uuidString, container: nil) else { fatalError("Error creating content identifier.") }
        guard let contentItem = TVContentItem(contentIdentifier: contentIdentifier) else { fatalError("Error creating content item.") }
        contentItem.title = "Pixar"
        
        contentItem.topShelfItems = imagesWithIdentifiers.map { url, identifier in
            guard let contentIdentifier = TVContentIdentifier(identifier: identifier, container: nil) else { fatalError("Error creating content identifier.") }
            guard let contentItem = TVContentItem(contentIdentifier: contentIdentifier) else { fatalError("Error creating content item.") }
            
            contentItem.title = identifier
            contentItem.displayURL = nil
            contentItem.imageURL = url
            contentItem.imageShape = .poster
            
            return contentItem
        }
        
        return [contentItem]
    }
}

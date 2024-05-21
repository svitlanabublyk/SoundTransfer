import Foundation

struct Episode: Codable {
  var name: String
  var URL: String
}
struct Podcast: Codable {
  var title: String
  var link: String
  var language: String
  var author: String
  var summary: String
  var description: String
  var image: String
  var category: String
  var explicit: Bool
  var episodes: [Episode]
}

func readPodcastFile(nameFile: String) -> Podcast {
  var data: Data = Data()
  do {
    let fileUrl = URL(fileURLWithPath: nameFile)
    data = try Data(contentsOf: fileUrl)
  } catch {
    print("Unexpected file read error:\(error)")
  }
  do {
    let podcast = try JSONDecoder().decode(Podcast.self, from: data)
    return podcast
  } catch {
    print("Unexpecting decoder error \(error)")
  }
  return Podcast(
    title: "",
    link: "",
    language: "",
    author: "",
    summary: "",
    description: "",
    image: "",
    category: "",
    explicit: false,
    episodes: []
    )
}

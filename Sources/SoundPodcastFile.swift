import Foundation

struct Episode: Codable {
  var name: String
  var URL: String
  var info: EpisodeInfo?
}
struct EpisodeInfo: Codable {
  var id: String
  var title: String
  var description: String
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
  var baseURL: String
  var episodes: [Episode]
}

func readPodcastFile(nameFile: String) -> Podcast {
  var data: Data = Data()
  do {
    let fileUrl = URL(fileURLWithPath: nameFile)
    data = try Data(contentsOf: fileUrl)
  } catch {
    writeLog(message: "Unexpected file read error:\(error)", logLevel: .error)
  }
  do {
    let podcast = try JSONDecoder().decode(Podcast.self, from: data)
    return podcast
  } catch {
    writeLog(message: "Unexpecting decoder error \(error)", logLevel: .error)
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
    baseURL: "",
    episodes: []
    )
}

func readEpisodFile(nameFile: String) -> EpisodeInfo {
   var data: Data = Data()
  do {
    let fileUrl = URL(fileURLWithPath: nameFile)
    data = try Data(contentsOf: fileUrl)
  } catch {
    writeLog(message: "Unexpected file read error:\(error)", logLevel: .error)
  }
  do {
    let episode = try JSONDecoder().decode(EpisodeInfo.self, from: data)
    return episode
  } catch {
    writeLog(message: "Unexpecting decoder error \(error)", logLevel: .error)
  }
  return EpisodeInfo(
    id: "",
    title: "",
    description: ""
  )
 }

func addEpisodeInfo( podcast: Podcast, downloadFolder: String) -> Podcast {
  var episodeList: [Episode] = []
  for var elem in podcast.episodes {
    let episodeFileName = downloadFolder + "/" + elem.name + ".info.json"
    let episodeInfo = readEpisodFile(nameFile: episodeFileName)
    elem.info = episodeInfo
    episodeList.append(elem)
  }
  var newPodcast = podcast
  newPodcast.episodes = episodeList
  return newPodcast
}

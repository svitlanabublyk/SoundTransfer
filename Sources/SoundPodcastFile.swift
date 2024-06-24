import Foundation

/**
 Represents an episode of a podcast.

 The `Episode` structure encapsulates information about a podcast episode,
 including its name, URL, and optional detailed information (`EpisodeInfo`).
 */
struct Episode: Codable {
  var name: String
  var URL: String
  var info: EpisodeInfo?
}

/**
 Detailed information about a podcast episode.

 The `EpisodeInfo` structure provides specific details about a podcast episode,
 including its unique identifier (`id`), title, and a detailed description.
 */
struct EpisodeInfo: Codable {
  var id: String
  var title: String
  var description: String
}

/**
 Represents a podcast with its associated metadata and episodes.

 The `Podcast` structure encapsulates various details about a podcast, including its title, author, 
 language, and a list of episodes. It conforms to the `Codable` protocol, allowing for easy 
 encoding and decoding from JSON.
 */
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

/**
 Reads podcast information from a JSON file.

 This function takes the path to a JSON file containing podcast information, reads the file's content,
 and decodes it into a `Podcast` object. If any error occurs during file reading or JSON decoding, 
 an error is logged and a default `Podcast` object is returned.

 - Parameters:
    - nameFile: The path to the JSON file containing the podcast information.

 - Returns:
    A `Podcast` object populated with data from the JSON file. If an error occurs, 
    a default `Podcast` object with empty or default fields is returned.

 - Note:
    The function logs errors to a logging system if file reading or JSON decoding fails.
*/
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

/**
 Reads episode information from a JSON file.

 This function takes the path to a JSON file containing episode information, reads the file's content,
 and decodes it into an `EpisodeInfo` object. If any error occurs during file reading or JSON decoding, 
 an error is logged and a default `EpisodeInfo` object is returned.

 - Parameters:
    - nameFile: The path to the JSON file containing the episode information.

 - Returns:
    An `EpisodeInfo` object populated with data from the JSON file. If an error occurs, 
    a default `EpisodeInfo` object with empty fields is returned.

 - Note:
    The function logs errors to a logging system if file reading or JSON decoding fails.
*/
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

/**
 Adds additional information to each episode in a podcast.

 This function takes a `Podcast` object and a `downloadFolder` path as input. 
 It iterates over each episode in the podcast, reads corresponding episode information from a JSON file 
 located in the specified download folder, and updates the episode's info attribute. 
 The function then returns a new `Podcast` object with updated episodes.

 - Parameters:
    - podcast: The `Podcast` object containing episodes that need additional information.
    - downloadFolder: The folder path where episode info JSON files are stored.

 - Returns: 
    A new `Podcast` object with each episode's info attribute updated based on the corresponding JSON file.

 - Note:
    The JSON files should be named as `<episodeName>.info.json` and located in the `downloadFolder`.
*/
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

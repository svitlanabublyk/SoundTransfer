import RegexBuilder
import Foundation

/**
 Generates an XML representation of a podcast.

 This function takes a `Podcast` object as input and generates an XML string that conforms to the iTunes 
 podcast RSS feed format. It handles the conversion of various podcast properties into their corresponding 
 XML elements. If the macOS version is 13.0 or later, it also removes query parameters from the podcast 
 description using a regular expression.

 - Parameters:
    - podcast: The `Podcast` object containing the information to be converted to XML.

 - Returns:
    A `String` containing the XML representation of the podcast.

 - Note:
    The function logs errors to a logging system if regex creation or application fails.
*/
func generateXML( podcast: Podcast) -> String {
  let explicit = podcast.explicit ? "True" : "False"
  var newDescription = podcast.description
  if #available(macOS 13.0, *) {
    do {
      let regEx = try Regex("\\?[a-zA-Z0-9_=&#]+")
      newDescription.replace(regEx, with: "")
    } catch {
      writeLog(message: "Error making regEx:\(error)", logLevel: .error)
    }
  }
  let episode = episodeXML( p: podcast)
  let rss = """
      <?xml version="1.0" encoding="UTF-8"?>
      <rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
      <channel>
        <title>\(podcast.title)</title>
        <description>
        \(newDescription)
        </description>
        <link>\(podcast.link)</link>
        <language>\(podcast.language)</language>
        <copyright></copyright>
        <itunes:subtitle></itunes:subtitle>
        <itunes:author>\(podcast.author)</itunes:author>
        <itunes:summary>\(podcast.summary)</itunes:summary>
        <itunes:explicit>\(explicit)</itunes:explicit>
        <itunes:owner>
          <itunes:name></itunes:name>
          <itunes:email></itunes:email>
        </itunes:owner>
        <itunes:image href="\(podcast.image)" />
        <itunes:category text="\(podcast.category)"/>
        \(episode)
      </channel>
      </rss>
      """
  return rss
}

/**
 Writes XML content to a file.

 This function takes a file name and a string containing XML content, and writes the content to the specified file.
 If any error occurs during the write operation, an error is logged.

 - Parameters:
    - nameFile: The path to the file where the XML content should be written.
    - content: The XML content to be written to the file.

 - Note:
    The function logs errors to a logging system if the file writing operation fails.
*/
func writeXML( nameFile: String, content: String) {
   do {
     try content.write(toFile: nameFile, atomically: true, encoding: String.Encoding.utf8)
   } catch {
     writeLog(message: "Error writihg XMLfile \(error)", logLevel: .error)
   }
}

/**
 Generates XML representation of podcast episodes.

 This function takes a `Podcast` object as input and generates an XML string for its episodes, 
 formatted according to the iTunes podcast RSS feed specification. It iterates over each episode 
 in the podcast, extracts relevant information, and constructs XML items for each episode. 
 If the macOS version is 13.0 or later, it also removes query parameters from the episode descriptions 
 using a regular expression.

 - Parameters:
    - podcast: The `Podcast` object containing the episodes to be converted to XML.

 - Returns:
    A `String` containing the XML representation of the podcast's episodes.

 - Note:
    The function logs errors to a logging system if regex creation or application fails.
*/
func episodeXML(p podcast: Podcast) -> String {
  var newEpisodes = ""
  for episode in podcast.episodes {
    if let unwrappedInfo = episode.info {
      var newDescription = unwrappedInfo.description
      if #available(macOS 13.0, *) {
        do {
          let regEx = try Regex("\\?[a-zA-Z0-9_=&#]+")
          newDescription.replace(regEx, with: "")
        } catch {
          writeLog(message: "Error making regEx:\(error)", logLevel: .error)
        }
      }
      let eps = """
      <item>
        <title>\(unwrappedInfo.title)</title>
        <itunes:author></itunes:author>
        <itunes:subtitle></itunes:subtitle>
        <description>
        \(newDescription)
        </description>
        <itunes:image href="" />
        <enclosure url="\(podcast.baseURL)/\(episode.name)" length="" type="audio/mpeg"/>
        <guid>\(unwrappedInfo.id)</guid>
        <pubDate></pubDate>
        <itunes:duration></itunes:duration>
      </item>
      """
     newEpisodes += eps
    }
  }
  return newEpisodes
}

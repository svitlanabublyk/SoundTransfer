func generateXML( podcast: Podcast) -> String {
  let explicit = podcast.explicit ? "True" : "False"
  let episode = episodeXML( p: podcast)
  let rss = """
      <?xml version="1.0" encoding="UTF-8"?>
      <rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
      <channel>
        <title>\(podcast.title)</title>
        <description>\(podcast.description)</description>
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

func writeXML( nameFile: String, content: String) {
   do {
     try content.write(toFile: nameFile, atomically: true, encoding: String.Encoding.utf8)
   } catch {
     print("Error writihg XMLfile \(error)")
   }
}

func episodeXML(p podcast: Podcast) -> String {
  var newEpisodes = ""
  for episode in podcast.episodes {
    if let unwrappedInfo = episode.info {
      let eps = """
      <item>
        <title>\(unwrappedInfo.title)</title>
        <itunes:author></itunes:author>
        <itunes:subtitle></itunes:subtitle>
        <description>\(unwrappedInfo.description)</description>
        <itunes:image href="" />
        <enclosure url="/\(episode.name)" length="" type="audio/mpeg"/>
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

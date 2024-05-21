func generateXML( podcast: Podcast) -> String {
  let explicit = podcast.explicit ? "True" : "False"
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

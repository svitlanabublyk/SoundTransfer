func generateXML(title: String, language: String) -> String {
  let rss = """
      <?xml version="1.0" encoding="UTF-8"?>
      <rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
      <channel>
        <title>\(title)</title>
        <link></link>
        <language>\(language)</language>
        <copyright></copyright>
        <itunes:subtitle></itunes:subtitle>
        <itunes:author></itunes:author>
        <itunes:summary></itunes:summary>
        <itunes:owner>
          <itunes:name></itunes:name>
          <itunes:email></itunes:email>
        </itunes:owner>
        <itunes:image href="" />
        <itunes:category text=""/>
      </channel>
      </rss>
      """
  return rss 
}

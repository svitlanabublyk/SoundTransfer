import Foundation


struct Podcast: Codable {
   var name: String 
   var URL: String 
}

func readPodcastFile(nameFile: String) -> [Podcast] {
  var podcasts:[Podcast] = []
  var data: Data = Data()
  do {
    let fileUrl = URL(fileURLWithPath: nameFile)
    data = try Data(contentsOf: fileUrl)
  } catch {
    print("Unexpected file read error:\(error)")
  }
  do {
    podcasts = try JSONDecoder().decode([Podcast].self, from:data)
  } catch{
    print("Unexpecting decoder error \(error)")
  }
  return podcasts
}
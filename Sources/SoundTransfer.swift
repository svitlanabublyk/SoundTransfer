// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@main
struct SoundTransfer: ParsableCommand {
    @Option(help: "Download files to following folder")
    var downloadFolder: String = "."

    mutating func run() throws {
        // Read podcasts
        let listOfNamesFile: String = "listOfSounds.json"
        let podcast = readPodcastFile(nameFile: listOfNamesFile)
        // Download podcasts
        download(listOfNamesFile, downloadFolder)

        // Read EpisodInfo
       let podcastWithInfo = addEpisodeInfo(podcast: podcast, downloadFolder: downloadFolder)
       print(podcastWithInfo)

        // let xml = generateXML(podcast: podcast)
        // let xmlFileName = downloadFolder + "/" + "podcast.xml"
        // writeXML(nameFile: xmlFileName, content: xml)
    }
}

func download(_ listOfNamesFile: String, _ folder: String) {
    let podcast = readPodcastFile(nameFile: listOfNamesFile)
    for episode in podcast.episodes {
        let name = folder + "/" + episode.name
        let url = episode.URL
        downloadFile(nameFile: name, urlYouTube: url)
    }
}

func downloadFile(nameFile: String, urlYouTube: String) {
    let task = Process()
    let executableUrl = URL(fileURLWithPath: "/usr/local/bin/yt-dlp")
    task.executableURL = executableUrl
    let pipeOut = Pipe()
    task.standardOutput = pipeOut
    let pipeError = Pipe()
    task.standardError = pipeError
    let options = ["--output", nameFile, "--extract-audio", "--audio-format", "mp3", "--write-info-json", urlYouTube]
    task.arguments = options

    do {
        try task.run()
        task.waitUntilExit()
    } catch {
        print("Unexpected error: \(error)")
    }

    let out = pipeOut.fileHandleForReading.readDataToEndOfFile()
    let err = pipeError.fileHandleForReading.readDataToEndOfFile()

    let outString = String(data: out, encoding: String.Encoding.utf8) ?? ""
    let errString = String(data: err, encoding: String.Encoding.utf8) ?? ""

    print(outString)
    print(errString)

    print("File downloaded ")
}

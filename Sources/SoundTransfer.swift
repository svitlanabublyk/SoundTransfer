// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import OSLog

enum LogLevel {
    case debug
    case info
    case notice
    case error
    case fault
}
var printLogTerminal: Bool = false

@main
struct SoundTransfer: ParsableCommand {
    @Option(help: "Download files to following folder")
    var downloadFolder: String = "."
    @Flag(help: "Print log messages to terminal")
    var printLog: Bool = false

    mutating func run() throws {
        printLogTerminal = printLog
        writeLog(message: "Application started", logLevel: .notice)
        // Read podcasts
        let listOfNamesFile: String = "listOfSounds.json"
        let podcast = readPodcastFile(nameFile: listOfNamesFile)
        // Download podcasts
        download(listOfNamesFile, downloadFolder)

        // Read EpisodInfo
        let podcastWithInfo = addEpisodeInfo(podcast: podcast, downloadFolder: downloadFolder)
       // print(podcastWithInfo)

        let xml = generateXML(podcast: podcastWithInfo)
        let xmlFileName = downloadFolder + "/" + "podcast.xml"
        writeXML(nameFile: xmlFileName, content: xml)
    }
}

func writeLog( message: String, logLevel: LogLevel) {
    if #available(OSX 11.0, *) {
        if printLogTerminal {
            print(message)
        } else {
            let logger = Logger()
            switch logLevel {
            case .debug:
                logger.debug("\(message, privacy: .public)")
            case .info:
                logger.info("\(message, privacy: .public)")
            case .notice:
                logger.notice("\(message, privacy: .public)")
            case .error:
                logger.error("\(message, privacy: .public)")
            case .fault:
                logger.fault("\(message, privacy: .public)")
            }
        }
    } else {
        print("\(message)")
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
        writeLog(message: "Unexpected error: \(error)", logLevel: .error)
    }

    let out = pipeOut.fileHandleForReading.readDataToEndOfFile()
    let err = pipeError.fileHandleForReading.readDataToEndOfFile()

    let outString = String(data: out, encoding: String.Encoding.utf8) ?? ""
    let errString = String(data: err, encoding: String.Encoding.utf8) ?? ""

    writeLog(message: outString, logLevel: .notice)
    writeLog(message: errString, logLevel: .notice)

    writeLog(message: "File downloaded ", logLevel: .notice)
}

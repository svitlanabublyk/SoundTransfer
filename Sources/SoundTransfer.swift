// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import OSLog

/**
 Represents the severity levels for logging messages.

 The `LogLevel` enum defines various levels of log severity, allowing you to categorize and filter 
 log messages based on their importance or severity.
*/
enum LogLevel {
    case debug
    case info
    case notice
    case error
    case fault
}

/// Global variable that represents output to terminal 
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

/**
 Logs a message with a specified log level.

 This function logs a message with the provided `LogLevel`. If running on macOS 11.0 or later,
 it uses the `Logger` class to log messages according to the specified log level. For earlier versions
 or if `printLogTerminal` is `true`, it prints the message to the terminal.

 - Parameters:
    - message: The message to be logged.
    - logLevel: The severity level of the log message, specified as a `LogLevel` enum value.

 - Note:
    If `printLogTerminal` is `true`, the message is printed to the terminal regardless of the macOS version.
    The function utilizes the `Logger` class for logging on macOS 11.0 or later.
*/
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

/**
 Downloads podcast episodes listed in a specified file to a designated folder.

 This function reads a podcast's information from a file, iterates over each episode, 
 and downloads the episode files to the specified folder.

 - Parameters:
    - listOfNamesFile: The path to the file containing the podcast information.
    - folder: The folder where the episode files will be downloaded.

 - Note:
    The function uses `readPodcastFile(nameFile:)` to read the podcast information from the specified file,
    and `downloadFile(nameFile:urlYouTube:)` to download each episode file.
*/
func download(_ listOfNamesFile: String, _ folder: String) {
    let podcast = readPodcastFile(nameFile: listOfNamesFile)
    for episode in podcast.episodes {
        let name = folder + "/" + episode.name
        let url = episode.URL
        downloadFile(nameFile: name, urlYouTube: url)
    }
}

/**
 Downloads a file from a specified YouTube URL using yt-dlp.

 This function executes yt-dlp with specified options to download audio from a YouTube URL 
 and save it to the specified file path. It logs the process output and any errors encountered 
 during the download.

 - Parameters:
    - nameFile: The file path where the downloaded file should be saved.
    - urlYouTube: The YouTube URL from which to download the audio.

 - Note:
    This function requires yt-dlp to be installed at `/usr/local/bin/yt-dlp` for execution.
    It logs the download process output and errors using `writeLog(message:logLevel:)`.
*/
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

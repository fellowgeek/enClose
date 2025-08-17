//
//  Logger.swift
//  enClose
//
//  Created by Erfan Reed on 8/16/25.
//

import Foundation
import OSLog

class Logger {

    // The singleton OSLog instance used for logging.
    private static let log = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "com.yourcompany.app",
        category: "App"
    )

    // MARK: - Public Logging Methods

    // Logs a debug message.
    // - Parameters:
    //   - message: The message to log.
    //   - file: The file where the log call originated. Default is #file.
    //   - function: The function where the log call originated. Default is #function.
    //   - line: The line number where the log call originated. Default is #line.
    static func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        os_log(
            "[%{public}@.%{public}@:%d] \n🛠️ DEBUG: %{public}@",
            log: log,
            type: .debug,
            fileName,
            function,
            line,
            message
        )
    }

    // Logs an informational message.
    // - Parameters:
    //   - message: The message to log.
    //   - file: The file where the log call originated. Default is #file.
    //   - function: The function where the log call originated. Default is #function.
    //   - line: The line number where the log call originated. Default is #line.
    static func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        os_log(
            "[%{public}@.%{public}@:%d] \nℹ️ INFO: %{public}@",
            log: log,
            type: .info,
            fileName,
            function,
            line,
            message
        )
    }
       
    // Logs a message for unexpected failures.
    //
    // - Parameters:
    //   - message: The message to log.
    //   - file: The file where the log call originated. Default is #file.
    //   - function: The function where the log call originated. Default is #function.
    //   - line: The line number where the log call originated. Default is #line.
    static func error(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        os_log(
            "[%{public}@.%{public}@:%d] \n🚨 ERROR: %{public}@",
            log: log,
            type: .error,
            fileName,
            function,
            line,
            message
        )
    }

    // Logs a message for critical failures.
    // - Parameters:
    //   - message: The message to log.
    //   - file: The file where the log call originated. Default is #file.
    //   - function: The function where the log call originated. Default is #function.
    //   - line: The line number where the log call originated. Default is #line.
    static func fault(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        os_log(
            "[%{public}@.%{public}@:%d] \n🔥 FAULT: %{public}@",
            log: log,
            type: .fault,
            fileName,
            function,
            line,
            message
        )
    }
}

//
//  HeLogger.swift
//
//  Created by herohjk on 2021/04/27.
//

import Foundation


/// 편리하게 사용하기 위한 싱글톤 (HJKLogger.shared.log -> hLogger.log)
public let heLogger = HeLogger.shared


/// 로그 간단 기록.
/// 더욱 더 편리하게 사용하기 위한 전역 함수
/// - Parameters:
///   - message: 로깅할 내용
///   - function: 로그를 호출한 함수 (자동 작성)
///   - file: 로그를 호출한 파일 (자동 작성)
///   - line: 로그를 호출한 파일의 함수 위치 (자동 작성)
public func hlog(
    _ message: String,
    function: String = #function,
    file: String = #file,
    line: Int = #line
) {
    heLogger.log(message, function: function, file: file, line: line)
}


/// 로그 상세 기록.
/// 더욱 더 편리하게 사용하기 위한 전역 함수
/// - Parameters:
///   - level: 로그 레벨, LogLevel
///   - type: 로그 타입, LogType
///   - message: 로깅할 내용
///   - function: 로그를 호출한 함수 (자동 작성)
///   - file: 로그를 호출한 파일 (자동 작성)
///   - line: 로그를 호출한 파일의 함수 위치 (자동 작성)
public func hlog(
    l level: HeLogger.LogLevel,
    t type: HeLogger.LogType,
    _ message: String,
    function: String = #function,
    file: String = #file,
    line: Int = #line
) {
    heLogger.log(l: level, t: type, message, function: function, file: file, line: line)
}

/// 로그에서 무시할 타입 설정.
/// 더욱 더 편리하게 사용하기 위한 전역 함수
/// - Parameters:
///   - type: 설정할 타입
///   - remove: true = 설정 / false = 설정 해제
public func setLogIgnoreType(type: HeLogger.LogType, remove: Bool = false) {
    heLogger.setIgnoreType(type: type, remove: remove)
}

/// 로그에서 무시할 레벨 설정.
/// 더욱 더 편리하게 사용하기 위한 전역 함수
/// - Parameters:
///   - level: 설정할 레벨
///   - remove: true = 설정 / false = 설정 해제
public func setLogIgnoreLevel(level: HeLogger.LogLevel, remove: Bool = false) {
    heLogger.setIgnoreLevel(level: level, remove: remove)
}

/// 간단한 로깅을 위한 HeLogger
public class HeLogger {
    /// 싱글톤. heLogger 대신 HeLogger.shared를 사용해도 되지만, 코드가 길어져서 권장하지는 않습니닷
    public static let shared = HeLogger()
    
    /// HeLogger의 로그 레벨
    ///  - unknown: 알수 없음
    ///  - debug: 디버그 수준
    ///  - realease: 릴리즈 수준
    ///  - info: 정보성 로그
    ///  - warn: 경고
    ///  - fatal: 심각한 오류
    ///  - trace: 디버그보다 조금 더 상세하게
    public enum LogLevel: String {
        /// 디버그 수준
        case debug      = "DEBUG"
        /// 릴리즈 수준
        case release    = "RELEASE"
        /// 정보성 로그
        case info       = "INFO"
        /// 경고 (클로저로 에러 핸들링 가능)
        case warn       = "WARNING"
        /// 심각한 오류 (클로저로 에러 핸들링 가능)
        case fatal      = "ERROR"
        /// 상세한 디버그 수준
        case trace      = "TRACE"
        /// 알 수 없음
        case unknown    = "UNKNOWN"
    }
    
    /// HeLogger의 로그 타입
    ///  - network: 네트워크
    ///  - action: 액션(버튼같은거)
    ///  - parsing: 파싱(json같은?)
    ///  - load: 무언가를 불러오는 작업 도중
    ///  - player: 플레이어 전용
    ///  - web: 웹뷰
    ///  - view: UI뷰
    ///  - download: 다운로드
    ///  - unknown: 알수 없음
    public enum LogType: String {
        /// 네트워크
        case network    = "NETWORK"
        /// UI컨트롤의 액션
        case action     = "ACTION"
        /// 파싱
        case parsing    = "PARSING"
        /// 로드
        case load       = "LOAD"
        /// 플레이어(플레이어 앱 전용)
        case player     = "PLAYER"
        /// 웹뷰
        case web        = "WEB"
        /// UI 뷰
        case view       = "VIEW"
        /// 다운로드 혹은 백그라운드?
        case download   = "DOWNLOAD"
        /// 알 수 없음
        case unknown    = "UNKNOWN"
    }
    
    /// fatal이나 warning의 경우 내보낼 에러 핸들러
    public var errorHandler: ((String) -> Void)?
    
    /// 로그 방식 포맷팅. 지원 종류는 다음과 같음.
    ///  - {$level}: 로그 레벨
    ///  - {$type}: 로그 타입
    ///  - {$time}: 현재 시각
    ///  - {$function}: 호출된 이전 함수
    ///  - {$file}: 호출한 함수의 파일 명
    ///  - {$line}: 호출한 함수 파일의 라인
    ///  - {$message}: 로깅 내용
    public var formatString =
        "[{$time}][{$level}][{$type}][{$function} ({$file}, {$line})]\n{$message}"
    
    
    /// 간단한 로그 기록
    /// - Parameters:
    ///   - message: 로깅할 내용
    ///   - function: 로그를 호출한 함수 (자동 작성)
    ///   - file: 로그를 호출한 파일 (자동 작성)
    ///   - line: 로그를 호출한 파일의 함수 위치 (자동 작성)
    public func log(_ message: String,
                    function: String = #function,
                    file: String = #file,
                    line: Int = #line) {
        log(l: lastLevel, t: lastType, message, function: function, file: file, line: line)
    }
    
    /// 로그 기록
    /// - Parameters:
    ///   - level: 로그 레벨, LogLevel
    ///   - type: 로그 타입, LogType
    ///   - message: 로깅할 내용
    ///   - function: 로그를 호출한 함수 (자동 작성)
    ///   - file: 로그를 호출한 파일 (자동 작성)
    ///   - line: 로그를 호출한 파일의 함수 위치 (자동 작성)
    public func log(l level: LogLevel,
                    t type: LogType,
                    _ message: String,
                    function: String = #function,
                    file: String = #file,
                    line: Int = #line) {
        #if DEBUG
        // 무시항목에 있으면 로그 표시 X
        if (ignoreLevel.filter{ $0 == level }).count > 0 { return }
        if (ignoreType.filter { $0 == type  }).count > 0 { return }
        
        var printMessage = message
        
        printMessage = formatString
            .replacingOccurrences(of: "{$level}", with: level.rawValue)
            .replacingOccurrences(of: "{$type}", with: type.rawValue)
            .replacingOccurrences(of: "{$time}", with: getTime())
            .replacingOccurrences(of: "{$function}", with: function)
            .replacingOccurrences(of: "{$file}", with: file)
            .replacingOccurrences(of: "{$line}", with: String(line))
            .replacingOccurrences(of: "{$message}", with: message)
        
        print(printMessage)
        
        if level == .fatal || level == .warn {
            errorHandler?(message)
        }
        #endif
    }
    
    
    /// 무시할 타입 설정
    /// - Parameters:
    ///   - type: 설정할 타입
    ///   - remove: true = 설정 / false = 설정 해제
    public func setIgnoreType(type: LogType, remove: Bool = false) {
        if remove {
            ignoreType = ignoreType.filter { $0 != type }
        } else {
            if (ignoreType.filter{ $0 == type }).count < 1 {
                ignoreType.append(type)
            }
        }
    }
    
    /// 무시할 레벨 설정
    /// - Parameters:
    ///   - level: 설정할 레벨
    ///   - remove: true = 설정 / false = 설정 해제
    public func setIgnoreLevel(level: LogLevel, remove: Bool = false) {
        if remove {
            ignoreLevel = ignoreLevel.filter { $0 != level }
        } else {
            if (ignoreLevel.filter{ $0 == level }).count < 1 {
                ignoreLevel.append(level)
            }
        }
    }
    
    private var ignoreType  = [LogType]()
    private var ignoreLevel = [LogLevel]()
    
    private var lastType = LogType.unknown
    private var lastLevel = LogLevel.unknown
    private func getTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let nanoSeconds = calendar.component(.nanosecond, from: date)
        return String(
            format: "%02d:%02d:%02d.%03d ",
            hour,
            minutes,
            seconds,
            (nanoSeconds/1_000_000)
        )
    }
}

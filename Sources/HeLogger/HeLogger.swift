//
//  HeLogger.swift
//
//  Created by herohjk on 2021/04/27.
//

import Foundation


/// 편리하게 사용하기 위한 싱글톤 (HJKLogger.shared.log -> hLogger.log)
public let heLogger = HeLogger.shared


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
        case debug      = "DEBUG"
        case release    = "RELEASE"
        case info       = "INFO"
        case warn       = "WARNING"
        case fatal      = "ERROR"
        case trace      = "TRACE"
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
        case network    = "NETWORK"
        case action     = "ACTION"
        case parsing    = "PARSING"
        case load       = "LOAD"
        case player     = "PLAYER"
        case web        = "WEB"
        case view       = "VIEW"
        case download   = "DOWNLOAD"
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
        "===\n[{$level}][{$type}]{$time}\n{$function} ({$file}, {$line})\n{$message}\n==="
    
    
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
        return String(format: "%02d:%02d:%02d.%03d ", hour, minutes, seconds, (nanoSeconds/1000000))
    }
}

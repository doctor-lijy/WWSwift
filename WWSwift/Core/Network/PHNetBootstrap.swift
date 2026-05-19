import Foundation
import PHNet

/// 启动期一次性配置 PHNet（`RuntimeAPPEnv`）：
///
/// - HTTP `configHeader`：业务签名 + 鉴权字段（u-token、token、X-SIG、sidecar 等）
/// - Socket `socketHeader`：socket 握手 header（X-TOKEN、authorization、X-SIG、sidecar、vs 等）
/// - 默认 CDN / 域名 / 主线路：与 weexios `WeexNet.m` 行为对齐
/// - 登录判定：转发到 `SessionStore.isLoggedIn`
///
/// 调用时机：`AppDelegate.application(_:didFinishLaunchingWithOptions:)` 中、`SocketManager.start()` 之前。
enum PHNetBootstrap {
    private static var didConfigure = false

    static func configure(session: SessionStore, environment: EnvironmentManager) {
        guard !didConfigure else { return }
        didConfigure = true

        let runtime = RuntimeAPPEnv.getInstance()

        runtime.setUserLoginCheck { session.isLoggedIn }
        runtime.setSocketHeader { Self.buildSocketHeader(session: session) }
        runtime.setDefaultCDNDomain { Self.defaultCDNDomain }
        runtime.setDefaultDomainList { Self.defaultDomainList }
        runtime.setDefaultNetLineBlock { inCountry in
            Self.defaultNetLine(inCountry: inCountry)
        }

        Self.configHTTPClient(session: session)

        let envType = AppENV(rawValue: UInt(environment.current.phnetEnvRawValue))
        DomainManager.getInstance().`switch`(envType)
    }

    // MARK: - HTTP

    private static func configHTTPClient(session: SessionStore) {
        let client = WeexHttpClient.getInstance()
        client.configHeader = { Self.buildHTTPHeader(session: session) }
        client.errorCallback = { statusCode, code, msg, url in
            // 鉴权失效统一处理（不在此弹 Toast，交由上层 UI 决策）
            NSLog("[PHNet][HTTP] code=\(code) status=\(statusCode) url=\(url) msg=\(msg)")
        }
    }

    private static func buildHTTPHeader(session: SessionStore) -> [String: Any] {
        let currentMillis = Int64(Date().timeIntervalSince1970 * 1000)
        let timestamp = "\(currentMillis)"
        let vs = DeviceInfoProvider.generateVSCode()
        let deviceID = DeviceInfoProvider.deviceID()
        let verName = DeviceInfoProvider.appVersion
        let packageName = DeviceInfoProvider.packageName

        let originSIG = "weex\(timestamp)\(vs)1\(verName)\(packageName)\(deviceID)"
        let xSig = DeviceInfoProvider.md5(originSIG)
        let sidecar = SecurityManager.getInstance().getSideCarSign(originSIG)

        let header: [String: Any] = [
            "terminalType": "1",
            "terminalCode": deviceID,
            "terminalVersion": DeviceInfoProvider.systemVersion,
            "appVersion": verName,
            "terminalModel": DeviceInfoProvider.deviceModel,
            "bundleid": packageName,
            "vs": vs,
            "u-token": session.accessToken ?? "",
            "token": session.isLoggedIn ? (session.userToken ?? "") : "",
            "X-TIMESTAMP": timestamp,
            "X-SIG": xSig,
            "traceId": UUID().uuidString,
            "User-Agent": userAgentString(verName: verName),
            "sidecar": sidecar,
            "language": "en_US",
            "languageType": "en",
            "locale": "en_US",
            "appTheme": "dark",
        ]
        return header
    }

    // MARK: - Socket

    private static func buildSocketHeader(session: SessionStore) -> [AnyHashable: Any] {
        let timestamp = String(Int64(Date().timeIntervalSince1970 * 1000))
        let vs = DeviceInfoProvider.generateVSCode()
        let verName = DeviceInfoProvider.appVersion

        let originSIG = "weex\(timestamp)\(vs)ios\(verName)\(session.rToken ?? "")"
        let xSig = DeviceInfoProvider.md5(originSIG)
        let sidecar = SecurityManager.getInstance().getSideCarSign(originSIG)

        let header: [AnyHashable: Any] = [
            "X-TOKEN": session.rToken ?? "",
            "X-CLIENT-TYPE": "ios",
            "X-CLIENT-VERSION": verName,
            "X-TIMESTAMP": timestamp,
            "X-SIG": xSig,
            "vs": vs,
            "compress": "1",
            "authorization": session.accessToken ?? "",
            "User-Agent": userAgentString(verName: verName),
            "sidecar": sidecar,
        ]
        return header
    }

    // MARK: - Domains

    private static let defaultCDNDomain: [String] = [
        "https://d18a9kav3kmczl.cloudfront.net/",
        "https://d3nnstzrpi75bv.cloudfront.net/",
        "https://64.83.37.193/",
    ]

    private static let defaultDomainList: [String] = ["ngsvsfx.cn", "wxy86j.info"]

    private static func defaultNetLine(inCountry: Bool) -> SubDomainBean {
        let bean = SubDomainBean()
        if inCountry {
            bean.domain = "ngsvsfx.cn"
            bean.alias = "cfn"
            bean.type = "c"
            bean.index = 0
        } else {
            bean.domain = "wxy86j.info"
            bean.alias = "c"
            bean.type = "w"
            bean.index = 0
        }
        return bean
    }

    // MARK: - User-Agent

    private static func userAgentString(verName: String) -> String {
        let dict: [String: String] = [
            "channel": "AppStore",
            "appVersion": verName,
            "model": "iOS",
            "languageType": "en",
            "theme": "dark",
        ]
        return dict.map { " \($0.key)/\($0.value)" }.joined()
    }
}

// MARK: - AppEnvironment -> PHNet AppENV

extension AppEnvironment {
    /// 映射到 PHNet `DomainManager` 的 `AppENV`（rawValue 与 OC `typedef enum` 序号对齐）：
    /// - `AppENV_TEST` = 0
    /// - `AppENV_STG`  = 1
    /// - `AppENV_PROD` = 2
    /// - `AppENV_GRAY` = 3
    /// - `AppENV_IP`   = 4
    /// 备注：OC `typedef enum` 不带 `NS_ENUM` 宏时，Swift 不会暴露常量名，需用 rawValue 构造。
    var phnetEnvRawValue: Int {
        switch self {
        case .mock: return 0 // TEST
        case .test: return 0 // TEST
        case .stg: return 1  // STG
        case .prod: return 2 // PROD
        }
    }
}

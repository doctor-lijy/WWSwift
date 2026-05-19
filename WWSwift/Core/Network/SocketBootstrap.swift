import Foundation
import PHNet

/// 启动 PHNet `SocketManager`。调用时机：`AppDelegate.didFinishLaunching` 中，
/// 在 `PHNetBootstrap.configure` 之后。
///
/// `SocketManager` 内部会按 `RuntimeAPPEnv.socketHeader` 注入鉴权头，建立合约公有 / 私有
/// 通道，并定期心跳。前后台切换通过 `onAppForeground()` 通知，断线由内部自动重连。
enum SocketBootstrap {
    private static var didStart = false

    static func start() {
        guard !didStart else { return }
        didStart = true
        SocketManager.getInstance().start()
    }

    static func onAppForeground() {
        SocketManager.getInstance().onAppForeground()
    }
}

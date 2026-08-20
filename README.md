# 戒刻 · Quit Smoking Moment

纯原生 iOS 戒烟应用，使用 SwiftUI 与 SwiftData 构建。

## 技术基线

- SwiftUI：界面与交互
- SwiftData：本地戒烟、烟瘾与复吸记录
- HealthKit：健康数据（后续接入）
- WidgetKit / ActivityKit：小组件与实时活动（后续接入）
- UserNotifications：提醒（后续接入）
- Charts：原生统计图表

## 本地运行

1. 在 macOS 安装 Xcode 16 或更新版本。
2. 安装 XcodeGen：`brew install xcodegen`。
3. 在项目目录运行 `xcodegen generate`。
4. 打开生成的 `QuitSmokingMoment.xcodeproj`。

## 无签名 IPA

GitHub Actions 的 **Build Unsigned IPA** 工作流会构建 iPhoneOS Release 版本，并上传 `QuitSmokingMoment-unsigned.ipa` artifact。该文件未签名，不能直接安装到普通 iPhone；需自行签名后安装。

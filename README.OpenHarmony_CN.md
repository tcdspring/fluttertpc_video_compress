> 模板版本: v0.0.1

<p align="center">
  <h1 align="center"> <code>video_compress</code> </h1>
</p>

本项目基于 [video_compress](https://pub.dev/packages/video_compress) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  video_compress:
    git:
      url: https://gitcode.com/openharmony-sig/fluttertpc_video_compress.git

...
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [example](/example/lib/main.dart)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;


## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

| Name              | Description           | Type     | Input                                                                                                                                                                                    | Output             | ohos Support |
|-------------------|-----------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|--------------|
| getByteThumbnail  | 获取视频文件缩略图，返回缩略图byte数据 | function | String path, {int quality = 100,int position = -1}                                                                                                                                       | Future<Uint8List?> | yes          |
| getFileThumbnail  | 获取视频文件缩略图，返回缩略图的路径    | function | String path, {int quality = 100,int position = -1}                                                                                                                                       | Future<File>       | yes          |
| getMediaInfo      | 获取视频文件的媒体信息           | function | String path                                                                                                                                                                              | Future<MediaInfo>  | yes          |
| deleteAllCache    | 删除所有缓存文件              | function | /                                                                                                                                                                                        | Future<bool?>      | yes          |
| cancelCompression | 停止当前正在执行的压缩任务         | function | /                                                                                                                                                                                        | Future<void>       | no           |
| compressVideo     | 压缩视频文件                | function | String path,<br> {VideoQuality quality = VideoQuality.DefaultQuality,<br>bool deleteOrigin = false,<br>int? startTime,<br>int? duration,<br>bool? includeAudio,<br>int frameRate = 30}   | Future<MediaInfo?> | yes          |
| setLogLevel       | 动态设置日志等级              | function | int logLevel                                                                                                                                                                             | Future<void>       | no           |
 

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### Parameters

| Name           | Description                | Type         | ohos Support |
|----------------|----------------------------|--------------|--------------|
| path           | 视频文件路径                     | String       | yes          |
| quality        | 设置输出缩略图的图片质量               | int          | yes          |
| position       | 需要获取的缩略图在视频中的时间点，单位为微秒（μs） | int          | yes          |
| frameRate      | 设置压缩视频的帧率                  | int          | yes          |
| includeAudio   | 设置压缩视频是否包含音频流              | bool?        | yes          |
| duration       | 设置压缩视频的时长                  | int?         | yes           |
| startTime      | 开始压缩的时间点                   | int?         | yes          |
| deleteOrigin   | 是否删除原始文件                   | bool         | yes          |
| quality        | 设置压缩视频的质量                       | VideoQuality | yes           |
| logLevel       | 日志等级                       | int          | no          |  


## 5. 遗留问题

- [ ]  ohos 端视频裁剪失败，返回缩略图byte文件类型错误: [issue#25](https://gitcode.com/openharmony-sig/fluttertpc_video_compress/issues/25)

## 6. 其他


## 7. 开源协议


本项目基于 [MIT License](/LICENSE) ，请自由地享受和参与开源。
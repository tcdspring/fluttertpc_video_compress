> Template version: v0.0.1

<p align="center">
  <h1 align="center"> <code>video_compress</code> </h1>
</p>

This project is based on [video_compress](https://pub.dev/packages/video_compress).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

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

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [example](/example/lib/main.dart)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;


## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

| Name              | Description                                                  | Type     | Input                                                                                                                                                                                    | Output             | ohos Support |
|-------------------|--------------------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|--------------|
| getByteThumbnail  | Get Byte Thumbnail return [Future<Uint8List>],               | function | String path, {int quality = 100,int position = -1}                                                                                                                                       | Future<Uint8List?> | yes          |
| getFileThumbnail  | Get File Thumbnail return [Future<File>]                     | function | String path, {int quality = 100,int position = -1}                                                                                                                                       | Future<File>       | yes          |
| getMediaInfo      | Get media information from [path] return [Future<MediaInfo>] | function | String path                                                                                                                                                                              | Future<MediaInfo>  | yes          |
| deleteAllCache    | Delete the cache folder                                      | function | /                                                                                                                                                                                        | Future<bool?>      | yes          |
| cancelCompression | Stop compressing the file that is currently being compressed | function | /                                                                                                                                                                                        | Future<void>       | no           |
| compressVideo     | Compress video from [path]                                   | function | String path,<br> {VideoQuality quality = VideoQuality.DefaultQuality,<br>bool deleteOrigin = false,<br>int? startTime,<br>int? duration,<br>bool? includeAudio,<br>int frameRate = 30}   | Future<MediaInfo?> | yes          |
| setLogLevel       | ynamically change the Log Level                              | function | int logLevel                                                                                                                                                                             | Future<void>       | no           |


## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### Parameters

| Name           | Description                                                                                    | Type           | ohos Support |
|----------------|------------------------------------------------------------------------------------------------|----------------|--------------|
| path           | Media file path                                                                                | String         | yes          |
| quality        | Set the image quality of the output thumbnail                                                  | int            | yes          |
| position       | The time point in the video at which the thumbnail needs to be obtained, in microseconds (μs). | int            | yes          |
| frameRate      | Set the frame rate for compressed video                                                        | int            | yes          |
| includeAudio   | Set whether the compressed video contains audio stream                                         | bool?          | yes          |
| duration       | Set the duration of compressed video                                                           | int?           | yes          |
| startTime      | Start time of compression                                                                      | int?           | yes          |
| deleteOrigin   | Whether to delete the original file                                                            | bool           | yes          |
| quality        | Set the quality of compressed video                                                            | VideoQuality   | yes          |
| logLevel       | Log Level                                                                                      | int            | no           |


## 5. Known Issues

- [ ] ohos video cropping failed, and the returned thumbnail byte file type is incorrect:[issue#25](https://gitcode.com/openharmony-sig/fluttertpc_video_compress/issues/25).

## 6. Others

1. [FFmpeg](https://gitee.com/openharmony-tpc-incubate/FFmpeg/repository/blazearchive/n6.1.2.zip)
2. [ffmpeg-kit](https://codeload.github.com/arthenica/ffmpeg-kit/zip/refs/tags/react.native.v6.0.2)

## 7. License

This project is licensed under [MIT License](/LICENSE).

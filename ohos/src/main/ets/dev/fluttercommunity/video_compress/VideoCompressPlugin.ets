import {
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  Log,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult
} from '@ohos/flutter_ohos';
import dayjs from 'dayjs';
import fs from '@ohos.file.fs';

import bundleManager from '@ohos.bundle.bundleManager';

import { Unity } from './Utility';
import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import { UIAbility } from '@kit.AbilityKit';
import { VideoCompress } from './VideoCompress';
import { TAG } from './Const';

let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO

const CHANNEL_NAME = "video_compress";

enum VideoQuality {
  DefaultQuality = 0, // .atMost(720)
  LowQuality = 1, // .atMost(360)
  MediumQuality = 2, // .atMost(640)
  HighestQuality = 3, // .bitRate(1280 * 720 * 4.toLong())
  Res640x480Quality = 4,
  Res960x540Quality = 5,
  Res1280x720Quality = 6,
  Res1920x1080Quality = 7
}

// function qualityAdaptor(q: VideoQuality): CompressQuality {
//   switch (q) {
//     case VideoQuality.DefaultQuality:
//     case VideoQuality.HighestQuality:
//     case VideoQuality.Res1920x1080Quality:
//     case VideoQuality.Res1280x720Quality:
//     case VideoQuality.Res960x540Quality:
//       return CompressQuality.COMPRESS_QUALITY_HIGH;
//     case VideoQuality.MediumQuality:
//     case VideoQuality.Res640x480Quality:
//       return CompressQuality.COMPRESS_QUALITY_MEDIUM;
//     case VideoQuality.LowQuality:
//       return CompressQuality.COMPRESS_QUALITY_LOW;
//     default:
//       return CompressQuality.COMPRESS_QUALITY_HIGH
//   }
// }

export class VideoCompressPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  getUniqueClassName(): string {
    return "VideoCompressPlugin";
  }

  private methodChannel: MethodChannel | null = null;
  private applicationContext: Context | null = null;
  private ability: UIAbility | null = null;
  private unity: Unity | null = null;
  private videoCompress: VideoCompress | null = null;

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    Log.i(TAG, "onAttachedToAbility");
    this.ability = binding.getAbility();
    this.unity = new Unity(this.ability.context);
    this.videoCompress = new VideoCompress(this.ability.context);
  }

  onDetachedFromAbility(): void {
    Log.i(TAG, "onDetachedFromAbility");
    this.ability = null;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.applicationContext = binding.getApplicationContext();
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.methodChannel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.applicationContext = null;
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    Log.d(TAG, "call: " + call.method)

    try {
      switch (call.method) {
        case 'getByteThumbnail': {
          const path = call.argument("path") as string
          const quality = call.argument("quality") as number
          const position = call.argument("position") as number
          this.videoCompress?.getByteThumbnail(path, quality, position).then(data => {
            result.success(data)
          })
          break;
        }
        case 'getFileThumbnail': {
          const path = call.argument("path") as string
          const quality = call.argument("quality") as number
          const position = call.argument("position") as number
          this.videoCompress?.getFileThumbnail(path, quality, position).then(path => {
            result.success(path)
          })
          break;
        }
        case 'getMediaInfo':
          result.notImplemented()
          break;
        case 'deleteAllCache': {
          this.videoCompress?.deleteAllCache();
          result.success(true)
          break;
        }
        case 'setLogLevel': {
          // const logLevel = call.argument("logLevel") as number;
          result.success(true);
          break;
        }
        case 'cancelCompression':
          result.notImplemented()
          break;
        case 'compressVideo': {
          const path = call.argument("path") as string;
          const quality = call.argument("quality") as number;
          const deleteOrigin = call.argument("deleteOrigin") as boolean;
          const startTime = call.argument("startTime") as number;
          const duration = call.argument("duration") as number;

          Log.d(TAG, JSON.stringify({
            path,
            quality,
            deleteOrigin,
            startTime,
            duration
          }))
          Log.d(TAG, path)

          let includeAudio = call.argument("includeAudio") as boolean | undefined;
          if (includeAudio === undefined) {
            includeAudio = true;
          }

          let frameRate = call.argument("frameRate") as number | undefined;
          if (frameRate === undefined) {
            frameRate = 30;
          }

          const tempDir = this.applicationContext!.tempDir;
          const out: string = dayjs().format('YYYY-MM-DD HH-mm-ss');
          const destPath: string = tempDir + "/VID_" + out + ".mp4";

          Log.d(TAG, destPath)

          this.methodChannel?.invokeMethod("updateProgress", 1)
          this.videoCompress?.compress(path, quality).then(out => {
            if (deleteOrigin) {
              fs.unlinkSync(path);
            }
            this.unity?.getMediaInfoJson(out).then((json) => {
              Log.d(TAG, JSON.stringify(json))
              json['isCancel'] = false;
              this.methodChannel?.invokeMethod("updateProgress", 100)
              result.success(JSON.stringify(json))
            })
          })
          break;
        }
        default:
          result.notImplemented()
      }
    } catch (err) {
      result.error("Name not found", err.message, null)
    }
  }
}

/*
 * Copyright (c) 2024 Shenzhen Kaihong Digital Industry Development Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import FFmpegNapi from 'libvideocompress.so';
import { common } from '@kit.AbilityKit';
import dayjs from 'dayjs';
import { Log } from '@ohos/flutter_ohos';
import { TAG } from './Const';
import fs from '@ohos.file.fs';
import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';
import { Unity } from './Utility';

enum VideoQuality {
  DefaultQuality,
  LowQuality,
  MediumQuality,
  HighestQuality,
  Res640x480Quality,
  Res960x540Quality,
  Res1280x720Quality,
  Res1920x1080Quality
}

export class VideoCompress {
  context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  deleteAllCache() {
    fs.listFileSync(this.context.tempDir).forEach(filename => {
      Log.d(TAG, 'deleteAllCache ' + filename)
      if (filename.indexOf('VID') === 0 || filename.indexOf('thumbnail_') === 0) {
        fs.unlinkSync(this.context.tempDir + "/" + filename)
      }
    })
    fs.listFileSync(this.context.cacheDir).forEach(filename => {
      Log.d(TAG, 'deleteAllCache ' + filename)
      if (filename.indexOf('VID') === 0) {
        fs.unlinkSync(this.context.cacheDir + "/" + filename)
      }
    })
    fs.listFileSync(this.context.getApplicationContext().tempDir).forEach(filename => {
      Log.d(TAG, 'deleteAllCache ' + filename)
      if (filename.indexOf('VID') === 0) {
        fs.unlinkSync(this.context.getApplicationContext().tempDir + "/" + filename)
      }
    })
  }

  compress(path: string, quality: number, includeAudio: boolean, frameRate: number, startTime: number,
    duration: number): Promise<string> {

    const tempDir = getContext().tempDir;
    const out: string = dayjs().format('YYYY-MM-DD_HH-mm-ss');
    const destPath: string = tempDir + "/VID_COMPRESS" + out + ".mp4";

    let cmd = `-y -noautorotate -accurate_seek -fflags +genpts -ss ${startTime} -i ${path} `;

    switch (quality) {
      case VideoQuality.DefaultQuality:
        cmd += `-vf "scale='if(gte(iw/ih,1),640,-1)':'if(lt(iw/ih,1),640,-1)'" `;
        break;
      case VideoQuality.LowQuality:
        cmd += `-vf "scale='if(gte(iw/ih,1),360,-1)':'if(lt(iw/ih,1),360,-1)'" `;
        break;
      case VideoQuality.MediumQuality:
        cmd += `-vf "scale='if(gte(iw/ih,1),720,-1)':'if(lt(iw/ih,1),720,-1)'" `;
        break;
      case VideoQuality.HighestQuality:
        let bitrate = 1280 * 720 * 4 / 1000;
        cmd += `-g 90 -b:v ${bitrate}k `;
        break;
      case VideoQuality.Res640x480Quality:
        cmd += `-vf "scale='if(gt(iw,ih),min(640,iw),-2)':'if(gt(iw,ih),-2,min(480,ih))'" `;
        break;
      case VideoQuality.Res960x540Quality:
        cmd += `-vf "scale='if(gt(iw,ih),min(960,iw),-2)':'if(gt(iw,ih),-2,min(540,ih))'" `;
        break;
      case VideoQuality.Res1280x720Quality:
        cmd += `-vf "scale='if(gt(iw,ih),min(1280,iw),-2)':'if(gt(iw,ih),-2,min(720,ih))'" `;
        break;
      case VideoQuality.Res1920x1080Quality:
        cmd += `-vf "scale='if(gt(iw,ih),min(1920,iw),-2)':'if(gt(iw,ih),-2,min(1080,ih))'" `;
        break;
    }

    if (!includeAudio) {
      cmd += `-an `;
    }
    cmd += `-r ${frameRate} `;
    if (duration > 0) {
      cmd += `-t ${duration} `;
    }
    cmd += destPath;
    Log.d(TAG, cmd);
    return new Promise(resolve => {
      FFmpegNapi.executeFFmpeg(cmd).then((code: number) => {
          if (code === 0) {
            resolve(destPath);
          } else {
            resolve("");
          }
      })
    });
  }

  async getByteThumbnail(path: string, quality: number = 70, position: number = 1) {
    const outFilePath = await this.getFileThumbnail(path, quality, position);
    let file = fs.openSync(outFilePath, fs.OpenMode.READ_WRITE);
    let buf = new ArrayBuffer(fs.statSync(outFilePath).size);
    fs.readSync(file.fd, buf);
    return buf;
  }

  getFileThumbnail(path: string, quality: number = 70, position: number = 1): Promise<string> {
    return new Promise(async resolve => {
      const out: string = dayjs().format('YYYY-MM-DD_HH-mm-ss');
      const outPath = this.context.tempDir + "/thumbnail_" + out + ".jpg";
      quality = 31 - 29 * quality / 100;
      position = position * 1.000 / 1000;
      let cmd = `-i ${path} -ss ${position} -vframes 1 -q:v ${quality} -vf "scale='if(gt(iw,ih),min(512,iw),-2)':'if(gt(iw,ih),-2,min(512,ih))'" ${outPath}`;
      FFmpegNapi.executeFFmpeg(cmd).then((code: number) => {
        if (code === 0) {
          resolve(outPath);
        } else {
          resolve("");
        }
      })
    });
  }

  // arraybuffer 转PixelMap
  toPixelMap(buf: ArrayBuffer) {
    let source = image.createImageSource(buf)
    return source.createPixelMap()
  }

  // PixelMap 转ArrayBuffer
  toArrayBuffer(pixel: PixelMap) {
    let buf = new ArrayBuffer(pixel.getPixelBytesNumber())
    pixel.readPixelsToBuffer(buf)
  }

  async savePixelMap(path: string, pm: PixelMap, quality = 70): Promise<string> {
    const imagePackerApi: image.ImagePacker = image.createImagePacker();
    const packOpts: image.PackingOption = { format: 'image/jpeg', quality: quality };

    const data: ArrayBuffer = await imagePackerApi.packing(pm, packOpts);
    let uri: string = path;
    let file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, data);
    fs.closeSync(file);

    return uri;
  }
}
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

#include "napi/native_api.h"
#include "FFmpegKit.h"
#include "FFmpegKitConfig.h"


std::string parseJsToString(napi_env env, napi_value value) {
    std::string result;
    napi_valuetype type;
    napi_typeof(env, value, &type);
    if (type == napi_undefined) {
        return nullptr;
    }
    size_t length = 0;
    napi_status status = napi_get_value_string_utf8(env, value, nullptr, 0, &length);
    if (status != napi_ok) {
        return nullptr;
    }
    result.resize(length);
    status = napi_get_value_string_utf8(env, value, &result[0], length + 1, nullptr);
    if (status != napi_ok) {
        return nullptr;
    }
    return result;
}

struct CallbackData {
    napi_async_work asyncWork = nullptr;
    napi_deferred deferred = nullptr;
    std::string ffmpegCommand;
    int executeResult = INT_MAX;
};

static napi_value ExecuteFFmpeg(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value promise = nullptr;
    napi_deferred deferred = nullptr;
    napi_create_promise(env, &deferred, &promise);

    auto callbackData = new CallbackData();
    callbackData->deferred = deferred;
    callbackData->ffmpegCommand = parseJsToString(env, args[0]);

    napi_value resourceName = nullptr;
    napi_create_string_utf8(env, "ExecuteFFmpeg", NAPI_AUTO_LENGTH, &resourceName);

    // 创建异步任务
    napi_create_async_work(
        env, nullptr, resourceName,
        [](napi_env env, void *data) {
            CallbackData *callbackData = reinterpret_cast<CallbackData *>(data);
            auto session = ffmpegkit::FFmpegSession::create(
                ffmpegkit::FFmpegKitConfig::parseArguments(callbackData->ffmpegCommand.c_str()));
            ffmpegkit::FFmpegKitConfig::ffmpegExecute(session);
            callbackData->executeResult = ffmpegkit::ReturnCode::isSuccess(session->getReturnCode()) ? 0 : -1;
        },
        [](napi_env env, napi_status status, void *data) {
            CallbackData *callbackData = reinterpret_cast<CallbackData *>(data);
            napi_value result = nullptr;
            napi_create_int32(env, callbackData->executeResult, &result);
            napi_resolve_deferred(env, callbackData->deferred, result);
            napi_delete_async_work(env, callbackData->asyncWork);
            delete callbackData;
        },
        callbackData, &callbackData->asyncWork);
    // 将异步任务加入队列
    napi_queue_async_work(env, callbackData->asyncWork);
    return promise;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"executeFFmpeg", nullptr, ExecuteFFmpeg, nullptr, nullptr, nullptr, napi_default, nullptr}

    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "videocompress",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }

//
//  LFLivePreview.m
//  LFLiveKit
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 live Interactive. All rights reserved.
//

#import "LFLivePreview.h"
#import "UIControl+YYAdd.h"
#import "UIView+YYAdd.h"
#import "LFLiveKit.h"

inline static NSString *formatedSpeed(float bytes, float elapsed_milli) {
    if (elapsed_milli <= 0) {
        return @"N/A";
    }

    if (bytes <= 0) {
        return @"0 KB/s";
    }

    float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
    if (bytes_per_sec >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2f MB/s", ((float)bytes_per_sec) / 1000 / 1000];
    } else if (bytes_per_sec >= 1000) {
        return [NSString stringWithFormat:@"%.1f KB/s", ((float)bytes_per_sec) / 1000];
    } else {
        return [NSString stringWithFormat:@"%ld B/s", (long)bytes_per_sec];
    }
}

@interface LFLivePreview ()<LFLiveSessionDelegate>

@property (nonatomic, strong) UIButton *startLiveButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) LFLiveDebug *debugInfo;
@property (nonatomic, strong) LFLiveSession *session;

@end

@implementation LFLivePreview

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self requestAccessForVideo];
        [self requestAccessForAudio];
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.startLiveButton];
    }
    return self;
}

#pragma mark -- Public Method
- (void)requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
    case AVAuthorizationStatusNotDetermined: {
        // 许可对话没有出现，发起授权许可
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning:YES];
                    });
                }
            }];
        break;
    }
    case AVAuthorizationStatusAuthorized: {
        // 已经开启授权，可继续
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.session setRunning:YES];
        });
        break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
        // 用户明确地拒绝授权，或者相机设备无法访问

        break;
    default:
        break;
    }
}

- (void)requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
    case AVAuthorizationStatusNotDetermined: {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
        break;
    }
    case AVAuthorizationStatusAuthorized: {
        break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
        break;
    default:
        break;
    }
}

#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    NSLog(@"liveStateDidChange: %ld", state);
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
    NSLog(@"debugInfo uploadSpeed: %@", formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli));
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    NSLog(@"errorCode: %ld", errorCode);
}

#pragma mark -- Getter Setter
- (LFLiveSession *)session {
    if (!_session) {
//        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
//        videoConfiguration.videoSize = CGSizeMake(360, 540);
//        videoConfiguration.videoBitRate = 800*1024;
//        videoConfiguration.videoMaxBitRate = 1000*1024;
//        videoConfiguration.videoMinBitRate = 500*1024;
//        videoConfiguration.videoFrameRate = 24;
//        videoConfiguration.videoMaxKeyframeInterval = 48;
//        videoConfiguration.outputImageOrientation = UIInterfaceOrientationPortrait;
//        videoConfiguration.autorotate = NO;
        
        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_High1];
        
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];
        _session.delegate = self;
        _session.showDebugInfo = NO;
        _session.preView = self;
        _session.captureDevicePosition = AVCaptureDevicePositionFront;
        _session.beautyFace = YES;

        /**    自己定制单声道  */
        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 1;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_64Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */

        /**    自己定制高质量音频96K */
        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */

        /**    自己定制高质量音频96K 分辨率设置为540*960 方向竖屏 */

        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

           LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(540, 960);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 24;
           videoConfiguration.videoMaxKeyframeInterval = 48;
           videoConfiguration.orientation = UIInterfaceOrientationPortrait;
           videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;

           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */

        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

           LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(720, 1280);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 15;
           videoConfiguration.videoMaxKeyframeInterval = 30;
           videoConfiguration.landscape = NO;
           videoConfiguration.sessionPreset = LFCaptureSessionPreset360x640;

           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向横屏  */

        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

           LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(1280, 720);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 15;
           videoConfiguration.videoMaxKeyframeInterval = 30;
           videoConfiguration.landscape = YES;
           videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;

           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        */

        /*本地存储*/
//        _session.saveLocalVideo = YES;
//        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
//        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//        _session.saveLocalVideoPath = movieURL;
        
        /*
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.alpha = 0.8;
        imageView.frame = CGRectMake(100, 100, 29, 29);
        imageView.image = [UIImage imageNamed:@"ios-29x29"];
        _session.warterMarkView = imageView;*/
        
    }
    return _session;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.frame = self.bounds;
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _containerView;
}

- (UIButton *)startLiveButton {
    if (!_startLiveButton) {
        _startLiveButton = [UIButton new];
        _startLiveButton.size = CGSizeMake(self.width - 60, 44);
        _startLiveButton.left = 30;
        _startLiveButton.bottom = self.height - 50;
        _startLiveButton.layer.cornerRadius = _startLiveButton.height/2;
        [_startLiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startLiveButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startLiveButton setTitle:@"Start Live" forState:UIControlStateNormal];
        [_startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
        _startLiveButton.exclusiveTouch = YES;
        __weak typeof(self) _self = self;
        [_startLiveButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            _self.startLiveButton.selected = !_self.startLiveButton.selected;
            if (_self.startLiveButton.selected) {
                [_self.startLiveButton setTitle:@"EndLive" forState:UIControlStateNormal];
                LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
                stream.url = @"rtmp://a.rtmp.youtube.com/live2/82d6-652m-bycv-yf9v-19de";
                [_self.session startLive:stream];
            } else {
                [_self.startLiveButton setTitle:@"StartLive" forState:UIControlStateNormal];
                [_self.session stopLive];
            }
        }];
    }
    return _startLiveButton;
}

@end


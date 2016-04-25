//
//  AppDelegate.m
//  musciDemo
//
//  Created by Tangguo on 16/4/25.
//  Copyright © 2016年 何月. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


@interface AppDelegate ()
{
    
    AVAudioPlayer *_audioPlayer;
    NSTimer *_timer;
}

@end

@implementation AppDelegate

// 定时器
-(void)addMusicTimer {
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(updateLrcLineLabelForScrollView) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}


-(void)playMusic
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"李克勤 - 月半小夜曲" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
     NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    _audioPlayer.numberOfLoops = 10000;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    
    [self updateLrcLineLabelForScrollView];
}

/// 总时长字符串
-(NSString *)durationMusicString {
    
    return [NSString stringWithFormat:@"%02d:%02d",(int)_audioPlayer.duration / 60, (int)_audioPlayer.duration % 60];
    
}
/// 总时长
-(NSTimeInterval)durationMusic {
    
    return _audioPlayer.duration;
}
/// 返回当前时长字符串
-(NSString *)currentTimeString {
    
    return [NSString stringWithFormat:@"%02d:%02d",(int)_audioPlayer.currentTime / 60, (int)_audioPlayer.currentTime % 60];
}
/// 返回当前时长
-(NSTimeInterval)currentTime {
    
    return _audioPlayer.currentTime;
}

/// 当前进度
-(CGFloat)musicProgress {
    
    return _audioPlayer.currentTime / _audioPlayer.duration;
}


#pragma mark - 锁屏显歌词
// 在锁屏界面显示歌曲信息(实时换图片MPMediaItemArtwork可以达到实时换歌词的目的)
- (void)updateLrcLineLabelForScrollView
{
    // 如果存在这个类,才能在锁屏时,显示歌词
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        // 核心:字典
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        
        // 标题(音乐名称)
        info[MPMediaItemPropertyTitle] = @"标题(音乐名称)";
        // 艺术家
        info[MPMediaItemPropertyArtist] = @"艺术家";
        // 专辑名称
        info[MPMediaItemPropertyAlbumTitle] = @"专辑名称";
        
        //设置当前时间
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime]=@([self currentTime]);
        
        //总时间
        info[MPMediaItemPropertyPlaybackDuration]= @([self durationMusic]);
        
        // 图片
        info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"李克勤.jpg"]];
        // 唯一的API,单例,nowPlayingInfo字典
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
    }
    
    
    //主屏显示
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    
    
    MPSkipIntervalCommand *skipBackwardIntervalCommand = [rcc skipBackwardCommand];
    [skipBackwardIntervalCommand setEnabled:YES];
    [skipBackwardIntervalCommand addTarget:self action:@selector(skipBackwardEvent)];
    
    MPSkipIntervalCommand *skipForwardIntervalCommand = [rcc skipForwardCommand];
    [skipForwardIntervalCommand setEnabled:YES];
    [skipForwardIntervalCommand addTarget:self action:@selector(skipForwardEvent)];
    
    
    /*
    // Doesn’t show unless prevTrack is enabled
    MPRemoteCommand *seekBackwardCommand = [rcc seekBackwardCommand];
    [seekBackwardCommand setEnabled:NO];
    [seekBackwardCommand addTarget:self action:@selector(seekEvent:)];
    
    // Doesn’t show unless nextTrack is enabled
    MPRemoteCommand *seekForwardCommand = [rcc seekForwardCommand];
    [seekForwardCommand setEnabled:NO];
    [seekForwardCommand addTarget:self action:@selector(seekEvent:)];
    */
    
    //收藏按钮
    MPFeedbackCommand *likeCommand = [rcc likeCommand];
    [likeCommand setEnabled:YES];
    [likeCommand setLocalizedTitle:@"我是收藏"];  // can leave this out for default
    [likeCommand addTarget:self action:@selector(likeEvent)];
    
    //取消按钮
    MPFeedbackCommand *dislikeCommand = [rcc dislikeCommand];
    [dislikeCommand setEnabled:YES];
    [dislikeCommand setActive:YES]; //显示勾勾
    [dislikeCommand setLocalizedTitle:@"我是x掉"]; // can leave this out for default
    [dislikeCommand addTarget:self action:@selector(dislikeEvent)];
    
    //添加按钮
    MPFeedbackCommand *bookmarkCommand = [rcc bookmarkCommand];
    [bookmarkCommand setEnabled:YES];
    [bookmarkCommand setActive:YES];
    [bookmarkCommand setLocalizedTitle:@"加我加我"]; // can leave this out for default
    [bookmarkCommand addTarget:self action:@selector(bookmarkEvent)];
    
}

-(void)skipBackwardEvent
{
    NSLog(@"skipBackwardEvent");
}

-(void)skipForwardEvent
{
    NSLog(@"skipForwardEvent");
}

-(void)seekEvent:(UIEvent *)event
{
    NSLog(@"event=%@",event);
}


-(void)likeEvent
{
    NSLog(@"我是收藏");
}

-(void)dislikeEvent
{
    NSLog(@"我是x掉");
}

-(void)bookmarkEvent
{
    NSLog(@"加我加我");
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPreviousTrack:
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                break;
            case UIEventSubtypeRemoteControlPlay:
                break;
            case UIEventSubtypeRemoteControlPause:
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                break;
            default:
                break;
        }
    }
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[UIApplication sharedApplication] becomeFirstResponder];
    
    [self playMusic];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

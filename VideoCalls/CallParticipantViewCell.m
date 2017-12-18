//
//  CallParticipantViewCell.m
//  VideoCalls
//
//  Created by Ivan Sein on 06.10.17.
//  Copyright © 2017 struktur AG. All rights reserved.
//

#import "CallParticipantViewCell.h"

#import <WebRTC/RTCAVFoundationVideoSource.h>
#import <WebRTC/RTCEAGLVideoView.h>
#import "NCAPIController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+Letters.h"

NSString *const kCallParticipantCellIdentifier = @"CallParticipantCellIdentifier";
NSString *const kCallParticipantCellNibName = @"CallParticipantViewCell";

@interface CallParticipantViewCell()
{
    UIView<RTCVideoRenderer> *_videoView;
}

@end

@implementation CallParticipantViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.audioOffIndicator.hidden = YES;
    self.peerAvatarImageView.hidden = YES;
    self.peerAvatarImageView.layer.cornerRadius = 64;
    self.peerAvatarImageView.layer.masksToBounds = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _displayName = nil;
    _peerNameLabel.text = nil;
    [_videoView removeFromSuperview];
    _videoView = nil;
}

- (void)setUserAvatar:(NSString *)userId
{
    if (userId && userId.length > 0) {
        [self.peerAvatarImageView setImageWithURLRequest:[[NCAPIController sharedInstance] createAvatarRequestForUser:userId]
                                        placeholderImage:nil success:nil failure:nil];
    } else {
        UIColor *guestAvatarColor = [UIColor colorWithRed:0.73 green:0.73 blue:0.73 alpha:1.0]; /*#B9B9B9*/
        [self.peerAvatarImageView setImageWithString:@"?" color:guestAvatarColor circular:true];
    }
}

- (void)setDisplayName:(NSString *)displayName
{
    _displayName = displayName;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.peerNameLabel.text = _displayName;
        // Only for guests
        if (!_displayName || [_displayName isEqualToString:@""]) {
            self.peerNameLabel.text = @"Guest";
        }
    });
}

- (void)setAudioDisabled:(BOOL)audioDisabled
{
    _audioDisabled = audioDisabled;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.audioOffIndicator.hidden = !_audioDisabled;
    });
}

- (void)setVideoDisabled:(BOOL)videoDisabled
{
    _videoDisabled = videoDisabled;
    if (videoDisabled) {
        [_peerAvatarImageView setHidden:NO];
    } else {
        [_peerAvatarImageView setHidden:YES];
    }
}

- (void)setVideoView:(RTCEAGLVideoView *)videoView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_videoView removeFromSuperview];
        _videoView = nil;
        _videoView = videoView;
        [_peerVideoView addSubview:_videoView];
        [self resizeRemoteVideoView];
    });
}

- (void)resizeRemoteVideoView {
    CGRect bounds = self.bounds;
    CGSize videoSize = _videoView.frame.size;
    if (videoSize.width > 0 && videoSize.height > 0) {
        // Aspect fill remote video into bounds.
        CGRect remoteVideoFrame =
        AVMakeRectWithAspectRatioInsideRect(videoSize, bounds);
        CGFloat scale = 1;
        if (remoteVideoFrame.size.width > remoteVideoFrame.size.height) {
            // Scale by height.
            scale = bounds.size.height / remoteVideoFrame.size.height;
        } else {
            // Scale by width.
            scale = bounds.size.width / remoteVideoFrame.size.width;
        }
        remoteVideoFrame.size.height *= scale;
        remoteVideoFrame.size.width *= scale;
        _videoView.frame = remoteVideoFrame;
        _videoView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    } else {
        _videoView.frame = bounds;
    }
}

@end

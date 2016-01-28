//
//  MWLivePhotoManager.h
//  Pods
//
//  Created by Luciano Sugiura on 27/01/16.
//
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^MWLivePhotoManagerCompletionBlock)(PHLivePhoto *livePhoto, NSError *error);
typedef void(^MWLivePhotoManagerProgressBlock)(NSInteger receivedBytes, NSInteger expectedBytes);

@interface MWLivePhotoManager : NSObject

+ (instancetype)sharedManager;

- (void)cancelAnyLoading;

- (void)livePhotoWithImageURL:(NSURL *)imageURL
                     movieURL:(NSURL *)movieURL
                     progress:(MWLivePhotoManagerProgressBlock)progress
                   completion:(MWLivePhotoManagerCompletionBlock)completion;

@end

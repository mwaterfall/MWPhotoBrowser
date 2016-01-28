//
//  MWLivePhotoManager.m
//  Pods
//
//  Created by Luciano Sugiura on 27/01/16.
//
//

#import "MWLivePhotoManager.h"

#import "MWPhotoProtocol.h"
#import "MWPhotoBrowser.h"
#import "NSString+MD5.h"

//--------------------------------------------------------------------------------------------------
#pragma mark - Class extension

@interface MWLivePhotoManager () <NSURLSessionDownloadDelegate>

@property (nonatomic) NSURLSession *imageSession;
@property (nonatomic) NSURLSession *movieSession;
@property (nonatomic) int64_t imageReceivedBytes;
@property (nonatomic) int64_t movieReceivedBytes;
@property (nonatomic) int64_t imageExpectedBytes;
@property (nonatomic) int64_t movieExpectedBytes;
@property (nonatomic) NSURL *imageFileURL;
@property (nonatomic) NSURL *movieFileURL;
@property (nonatomic) BOOL didDownloadImage;
@property (nonatomic) BOOL didDownloadMovie;
@property (nonatomic) MWLivePhotoManagerCompletionBlock completion;
@property (nonatomic) MWLivePhotoManagerProgressBlock progress;

@end

//--------------------------------------------------------------------------------------------------
#pragma mark - Implementation

@implementation MWLivePhotoManager

//--------------------------------------------------------------------------------------------------
#pragma mark - Singleton

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

//--------------------------------------------------------------------------------------------------
#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _imageReceivedBytes = 0;
        _movieReceivedBytes = 0;
        _imageExpectedBytes = 0;
        _movieExpectedBytes = 0;
    }
    return self;
}

//--------------------------------------------------------------------------------------------------
#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (!self.progress) {
        return;
    }
    
    CGFloat currentProgress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    
    if (session == self.imageSession) {
        self.imageReceivedBytes = totalBytesWritten;
        self.imageExpectedBytes = totalBytesExpectedToWrite;
    } else if (session == self.movieSession) {
        self.movieReceivedBytes = totalBytesWritten;
        self.movieExpectedBytes = totalBytesExpectedToWrite;
    }
    
    self.progress(self.imageReceivedBytes + self.movieReceivedBytes,
                  self.imageExpectedBytes + self.movieExpectedBytes);
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    if (session == self.imageSession) {
        
        MWLog(@"Live Photo image downloaded.");
        
        NSError *err = nil;
        
        if (![[NSFileManager defaultManager]
              moveItemAtURL:location
              toURL:self.imageFileURL
              error:&err]) {
            MWLog(@"Error moving Live Photo image: %@", err);
            [self completeWithError:err];
            return;
        }
        
        self.didDownloadImage = YES;
        [self didDownloadLivePhotoAsset];
        
    } else if (session == self.movieSession) {
        
        MWLog(@"Live Photo movie downloaded.");
        
        NSError *err = nil;
        
        if (![[NSFileManager defaultManager]
              moveItemAtURL:location
              toURL:self.movieFileURL
              error:&err]) {
            MWLog(@"Error moving Live Photo movie: %@", err);
            [self completeWithError:err];
            return;
        }
        
        self.didDownloadMovie = YES;
        [self didDownloadLivePhotoAsset];
    }
}

//--------------------------------------------------------------------------------------------------
#pragma mark - Public methods

- (void)cancelAnyLoading {
    [self.imageSession invalidateAndCancel];
    [self.movieSession invalidateAndCancel];
    self.imageSession = nil;
    self.movieSession = nil;
}

- (void)livePhotoWithImageURL:(NSURL *)imageURL
                     movieURL:(NSURL *)movieURL
                     progress:(MWLivePhotoManagerProgressBlock)progress
                   completion:(MWLivePhotoManagerCompletionBlock)completion {
    
    self.progress = progress;
    self.completion = completion;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *tmpDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"MWLivePhotos"];
    
    [fileManager
     createDirectoryAtPath:tmpDirPath
     withIntermediateDirectories:tmpDirPath
     attributes:nil
     error:nil];
    
    NSString *imageFileName = [NSString stringWithFormat:@"%@.jpg", imageURL.absoluteString.md5];
    NSString *movieFileName = [NSString stringWithFormat:@"%@.mov", movieURL.absoluteString.md5];
    
    NSString *imageFilePath = [tmpDirPath stringByAppendingPathComponent:imageFileName];
    NSString *movieFilePath = [tmpDirPath stringByAppendingPathComponent:movieFileName];
    
    NSURL *imageFileURL = [NSURL URLWithString:
                           [NSString stringWithFormat:@"file://%@", imageFilePath]];
    NSURL *movieFileURL = [NSURL URLWithString:
                           [NSString stringWithFormat:@"file://%@", movieFilePath]];
    
    if ([fileManager fileExistsAtPath:imageFilePath] &&
        [fileManager fileExistsAtPath:movieFilePath]) {
        
        MWLog(@"Found cached files for Live Photo.")
        
        NSArray *fileURLs = @[imageFileURL, movieFileURL];
        [self livePhotoWithFileURLs:fileURLs];
        
    } else {
        
        MWLog(@"No cached files for Live Photo - downloading them.");
        
        self.imageFileURL = imageFileURL;
        self.movieFileURL = movieFileURL;
        
        [self
         downloadLivePhotoWithImageURL:imageURL
         movieURL:movieURL];
    }
}

//--------------------------------------------------------------------------------------------------
#pragma mark - Private methods

- (void)completeWithError:(NSError *)error {
    if (self.completion) {
        self.completion(nil, error);
    }
    [self reset];
}

- (void)completeWithLivePhoto:(PHLivePhoto *)livePhoto {
    if (self.completion) {
        self.completion(livePhoto, nil);
    }
    [self reset];
}

- (void)didDownloadLivePhotoAsset {
    if (self.didDownloadImage && self.didDownloadMovie) {
        NSArray *fileURLs = @[self.imageFileURL, self.movieFileURL];
        [self livePhotoWithFileURLs:fileURLs];
        self.imageFileURL = nil;
        self.movieFileURL = nil;
    }
}

- (void)downloadLivePhotoWithImageURL:(NSURL *)imageURL movieURL:(NSURL *)movieURL {
    
    NSURLSessionConfiguration *imageConfig = [NSURLSessionConfiguration
                                              defaultSessionConfiguration];
    
    self.imageSession = [NSURLSession
                         sessionWithConfiguration:imageConfig
                         delegate:self
                         delegateQueue:[NSOperationQueue mainQueue]];
    
    [[self.imageSession downloadTaskWithURL:imageURL] resume];
    
    NSURLSessionConfiguration *movieConfig = [NSURLSessionConfiguration
                                              defaultSessionConfiguration];
    
    self.movieSession = [NSURLSession
                         sessionWithConfiguration:movieConfig
                         delegate:self
                         delegateQueue:[NSOperationQueue mainQueue]];
    
    [[self.movieSession downloadTaskWithURL:movieURL] resume];
}

- (void)livePhotoWithFileURLs:(NSArray *)fileURLs {
    
    [PHLivePhoto
     requestLivePhotoWithResourceFileURLs:fileURLs
     placeholderImage:nil
     targetSize:CGSizeZero
     contentMode:PHImageContentModeAspectFill
     resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
         
         NSError *error;
         if ((error = info[PHLivePhotoInfoErrorKey])) {
             MWLog(@"Error creating Live Photo: %@", error);
             [self completeWithError:error];
             return;
         }
         
         NSNumber *isDegraded = info[PHLivePhotoInfoIsDegradedKey];
         
         MWLog(@"Live Photo created with PHLivePhotoInfoIsDegradedKey: %@", isDegraded);
         
         if (isDegraded && isDegraded.boolValue) {
             return;
         }
         
         [self completeWithLivePhoto:livePhoto];
     }];
}

- (void)reset {
    self.imageFileURL = nil;
    self.movieFileURL = nil;
    [self.imageSession invalidateAndCancel];
    [self.movieSession invalidateAndCancel];
    self.imageSession = nil;
    self.movieSession = nil;
    self.imageReceivedBytes = 0;
    self.movieReceivedBytes = 0;
    self.imageExpectedBytes = 0;
    self.movieExpectedBytes = 0;
    self.didDownloadImage = NO;
    self.didDownloadMovie = NO;
    self.completion = nil;
    self.progress = nil;
}

@end

//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import "XCDYouTubeVideoWebpage.h"

@interface XCDYouTubeVideoWebpage ()
@property (nonatomic, readonly) NSString *html;
@end

@implementation XCDYouTubeVideoWebpage

@synthesize playerConfiguration = _playerConfiguration;
@synthesize videoInfo = _videoInfo;
@synthesize javaScriptPlayerURL = _javaScriptPlayerURL;
@synthesize isAgeRestricted = _isAgeRestricted;
@synthesize regionsAllowed = _regionsAllowed;

- (instancetype) initWithHTMLString:(NSString *)html
{
	if (!(self = [super init]))
		return nil; // LCOV_EXCL_LINE
	
	_html = html;
	
	return self;
}

- (NSDictionary *) playerConfiguration
{
	if (!_playerConfiguration)
	{
		__block NSDictionary *playerConfigurationDictionary;
		NSRegularExpression *playerConfigRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"ytplayer.config\\s*=\\s*(\\{.*?\\});|[\\({]\\s*'PLAYER_CONFIG'[,:]\\s*(\\{.*?\\})\\s*(?:,'|\\))" options:NSRegularExpressionCaseInsensitive error:NULL];
		[playerConfigRegularExpression enumerateMatchesInString:self.html options:(NSMatchingOptions)0 range:NSMakeRange(0, self.html.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		{
			for (NSUInteger i = 1; i < result.numberOfRanges; i++)
			{
				NSRange range = [result rangeAtIndex:i];
				if (range.length == 0)
					continue;
				
				NSString *configString = [self.html substringWithRange:range];
				NSData *configData = [configString dataUsingEncoding:NSUTF8StringEncoding];
				NSDictionary *playerConfiguration = [NSJSONSerialization JSONObjectWithData:configData ?: [NSData new] options:(NSJSONReadingOptions)0 error:NULL];
				if ([playerConfiguration isKindOfClass:[NSDictionary class]])
				{
					playerConfigurationDictionary = playerConfiguration;
					*stop = YES;
				}
			}
		}];
		_playerConfiguration = playerConfigurationDictionary;
	}
	return _playerConfiguration;
}

- (NSDictionary *) videoInfo
{
	if (!_videoInfo)
	{
		NSDictionary *args = self.playerConfiguration[@"args"];
		if ([args isKindOfClass:[NSDictionary class]])
		{
			NSMutableDictionary *info = [NSMutableDictionary new];
			[args enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop)
			{
				if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
					info[key] = [value description];
			}];
			_videoInfo = [info copy];
		}
	}
	return _videoInfo;
}

- (NSURL *) javaScriptPlayerURL
{
	if (!_javaScriptPlayerURL)
	{
		NSString *jsAssets = [self.playerConfiguration valueForKeyPath:@"assets.js"];
		if ([jsAssets isKindOfClass:[NSString class]])
		{
			NSString *javaScriptPlayerURLString = jsAssets;
			if ([jsAssets hasPrefix:@"//"])
				javaScriptPlayerURLString = [@"https:" stringByAppendingString:jsAssets];
			else if ([jsAssets hasPrefix:@"/"])
				javaScriptPlayerURLString = [@"https://www.youtube.com" stringByAppendingString:jsAssets];
			
			_javaScriptPlayerURL = [NSURL URLWithString:javaScriptPlayerURLString];
		}
	}
	return _javaScriptPlayerURL;
}

- (BOOL) isAgeRestricted
{
	if (!_isAgeRestricted)
	{
		NSStringCompareOptions options = (NSStringCompareOptions)0;
		NSRange range = NSMakeRange(0, self.html.length);
		_isAgeRestricted = [self.html rangeOfString:@"og:restrictions:age" options:options range:range].location != NSNotFound;
	}
	return _isAgeRestricted;
}

- (NSSet *) regionsAllowed
{
	if (!_regionsAllowed)
	{
		_regionsAllowed = [NSSet set];
		NSRegularExpression *regionsAllowedRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"meta\\s+itemprop=\"regionsAllowed\"\\s+content=\"(.*)\"" options:(NSRegularExpressionOptions)0 error:NULL];
		NSTextCheckingResult *regionsAllowedResult = [regionsAllowedRegularExpression firstMatchInString:self.html options:(NSMatchingOptions)0 range:NSMakeRange(0, self.html.length)];
		if (regionsAllowedResult.numberOfRanges > 1)
		{
			NSString *regionsAllowed = [self.html substringWithRange:[regionsAllowedResult rangeAtIndex:1]];
			if (regionsAllowed.length > 0)
				_regionsAllowed = [NSSet setWithArray:[regionsAllowed componentsSeparatedByString:@","]];
		}
	}
	return _regionsAllowed;
}

@end

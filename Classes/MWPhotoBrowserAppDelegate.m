//
//  MWPhotoBrowserAppDelegate.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhotoBrowserAppDelegate.h"
#import "MWPhotoBrowser.h"

@implementation MWPhotoBrowserAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

	NSArray *photos = [NSArray arrayWithObjects:
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo1l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo4l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo1l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo4l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo1l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo4l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo1l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3l" ofType:@"jpg"]],
					   [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo4l" ofType:@"jpg"]],
					   nil];
	
//	NSArray *photos = [NSArray arrayWithObjects:
//					   [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg"]],
//					   [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg"]],
//					   [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg"]],
//					   [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg"]],
//					   nil];

	MWPhotoBrowser *vc = [[MWPhotoBrowser alloc] initWithPhotos:photos];
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
	
    // Add the view controller's view to the window and display.
    [window addSubview:nc.view];
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end

//
//  AppDelegate.m
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "AppDelegate.h"
#import "TumbleweedViewController.h"
#import "Tumbleweed.h"

#import "TestFlight.h"
#import "Flurry.h"

#define deviceTokenKey   @"devtok"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController, weed;

/**
  * Catch any exceptions that leak through and report
  */
void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    // analytics
    [Flurry startSession:@"TPPGLUQ1PTGM7XKM8MF3"];
    [TestFlight takeOff:@"bb371df0e59558721f4be65bc1cd34b2_NTg5NDgyMDEyLTAyLTAyIDA5OjIyOjM0LjM0Nzk3MQ"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    self.viewController = [[TumbleweedViewController alloc]initWithNibName:@"TumbleweedViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[Tumbleweed weed] getUserUpdates];
    
    //if remote notification received at launch
    NSDictionary *pushNotificationPayload = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(pushNotificationPayload) {
        [self application:application didReceiveRemoteNotification:pushNotificationPayload];
    }
    
    //generic remote notifications setup and whatnot
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    if (([[NSUserDefaults standardUserDefaults] stringForKey: @"deviceTokenKey"]) &&
        ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)))
    {
        //user has probably disabled push. react accordingly.
    }
    
    return YES;
}

#pragma mark - Remote and Local Notifications 

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token
{    
    NSString *deviceToken = [token description];
    NSLog(@"bytes in hex: %@", deviceToken);
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString: @"<" withString: @""];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString: @">" withString: @""];
    //deviceToken = [deviceToken stringByReplacingOccurrencesOfString: @" " withString: @""];
    //const void *devTokenBytes = [token bytes];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey: deviceTokenKey])
    {
        if (![[[NSUserDefaults standardUserDefaults] stringForKey: deviceTokenKey] isEqualToString: deviceToken])
        {
            [[NSUserDefaults standardUserDefaults] setObject: deviceToken forKey: deviceTokenKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //user allowed push. react accordingly.
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject: deviceToken forKey: deviceTokenKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //user allowed push. react accordingly.
    }
    //NSLog(@"userDef token %@", [[NSUserDefaults standardUserDefaults] stringForKey: deviceTokenKey]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"application: %@ didFailToRegisterForRemoteNotificationsWithError: %@", application, [error localizedDescription]);
}
- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
	NSLog(@"In did receive  Remote Notifications %@", userInfo);
    [[Tumbleweed weed] getUserUpdates];
}

//You can alternately implement the pushNotification API
+(void)pushNotification:(UIApplication*)application notifyData:(NSDictionary *)userInfo
{
    // upgrade tumbleweed level?
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"local notification was fired off");
    //trigger animation of unlocking from here?
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {  return NO; }
    
    NSString *URLString = [url absoluteString];
    [[NSUserDefaults standardUserDefaults] setObject:URLString forKey:@"url"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

#pragma mark - Application LifeCycle

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [viewController pauseLayer:nil];
    NSLog(@"appwill resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */

    [viewController saveAvatarPosition];
    [viewController dismissViewControllerAnimated:NO completion:^{}];
    [viewController dismissModalViewControllerAnimated:NO];
    [[Tumbleweed weed] saveTumbleweed];
    [viewController pauseLayer:nil];
    NSLog(@"did enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    //[[Tumbleweed weed] getUserUpdates];
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    //[viewController resumeLayer:nil];
    NSLog(@"appwill become active");

}


- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}



@end

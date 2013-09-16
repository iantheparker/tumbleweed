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

#define deviceTokenKey   @"devtok"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tweedNavController;

/**
  * Catch any exceptions that leak through and report
  */
void uncaughtExceptionHandler(NSException *exception) {
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    // analytics
    [TestFlight takeOff:@"c3fbe14b-2a0f-4be8-903e-efd0f7c622be"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //TumbleweedViewController *tweedViewController = [TumbleweedViewController sharedClient];
    tweedNavController = [[UINavigationController alloc] initWithRootViewController:[TumbleweedViewController sharedClient]];
    tweedNavController.navigationBarHidden = YES;
    
    self.window.rootViewController = tweedNavController;
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
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
#if TARGET_IPHONE_SIMULATOR
    NSString *simDeviceToken = @"dde7db8a 02cedc6e 455c57b0 72ee77d1 22a78fc9 d2cdxxxd 3023a181 e335d7d6";
    [[NSUserDefaults standardUserDefaults] setObject: simDeviceToken forKey: deviceTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    
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
    //[[Tumbleweed sharedClient] getUserUpdates];
}

//You can alternately implement the pushNotification API
+(void)pushNotification:(UIApplication*)application notifyData:(NSDictionary *)userInfo
{
    // upgrade tumbleweed level?
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!url) {  return NO; }
    NSLog(@"url %@", url);
    //handle each url separately
    if ([[url absoluteString] rangeOfString:@"home"].location != NSNotFound){
        //nomansland://home#access_token=UT0L5SRHLHNCXFUNO3X4NKMIAFANLZBIWG13PA5F4N2L2F2M
        [Foursquare handleOpenURL:url WithBlock:^(NSString *access_token) {
            if (access_token) {
                [[Tumbleweed sharedClient] registerUser];
            }
        }];
    }

    return YES;
}

#pragma mark - Application LifeCycle

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    //NSLog(@"appwill resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */

    [[[tweedNavController viewControllers] objectAtIndex:0] saveAvatarPosition];
    [tweedNavController dismissViewControllerAnimated:NO completion:nil];
    [tweedNavController popToRootViewControllerAnimated:NO];
    
    [[Tumbleweed sharedClient] saveTumbleweed];
    NSLog(@"did enter background");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enteredBackground" object:self];
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
    //if([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"])[[Tumbleweed sharedClient] getUserUpdates];
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
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

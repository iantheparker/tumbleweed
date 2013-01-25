//
//  Tumbleweed.m
//  tumbleweed
//
//  Created by Ian Parker on 2/20/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Tumbleweed.h"

static Tumbleweed *weed = nil;

@interface Tumbleweed()
@property (nonatomic) NSString *fsqId;
@property (nonatomic) NSString *fsqFirstName;
@property (nonatomic) NSString *fsqLastName;
@end


@implementation Tumbleweed

@synthesize locationManager, fsqFirstName, fsqId, fsqLastName, tumbleweedId;
@synthesize tumbleweedLevel, sceneState;

#pragma mark - Lifecycle Methods

+ (Tumbleweed *)weed
{
    @synchronized(self) {
        if (weed == nil) {
            weed = [[self alloc] init];
            [weed loadTumbleweed];
        }
        return weed;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Do Nada
    }
    return self;
}

- (void) loadTumbleweed
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"tumbleweed"])
    {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *myEncodedObject = [defaults objectForKey:@"tumbleweed"];
        fsqId = [myEncodedObject objectForKey:@"fsqId"];
        fsqFirstName = [myEncodedObject objectForKey:@"fsqFirstName"];
        fsqLastName = [myEncodedObject objectForKey:@"fsqLastName"];
        tumbleweedLevel = [[myEncodedObject objectForKey:@"tumbleweedLevel"] intValue];
        sceneState = [myEncodedObject objectForKey:@"sceneState"];
        tumbleweedId = [myEncodedObject objectForKey:@"tumbleweedId"];
        NSLog(@"using stored tumbleweed %@", myEncodedObject);
    }
    else{
        sceneState = [NSMutableArray arrayWithObjects:
                      [NSNumber numberWithBool:NO],
                      [NSNumber numberWithBool:NO],
                      [NSNumber numberWithBool:NO], nil];
    }
}
- (void) saveTumbleweed
{
    NSMutableDictionary *myEncodedObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            fsqId, @"fsqId",
                                            fsqFirstName, @"fsqFirstName",
                                            fsqLastName, @"fsqLastName",
                                            [NSNumber numberWithInt:tumbleweedLevel], @"tumbleweedLevel",
                                            tumbleweedId, @"tumbleweedId",
                                            sceneState, @"sceneState", nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:myEncodedObject forKey:@"tumbleweed"];
    [defaults synchronize];
    NSLog(@"saving tumbleweed %@", myEncodedObject);
    //update game state
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gameSave" object:self];
    
}
#pragma mark - 
#pragma mark - API Methods

- (void) registerUser
{
    NSLog(@"in register");
    if (tumbleweedId) return;
    [Foursquare getUserIdWithBlock:^(NSDictionary *userCred, NSError *error) {
        if (error) {
            NSLog(@"userCred error %@", error);
        }
        else{
            fsqId = [userCred objectForKey:@"id"];
            fsqFirstName = [userCred objectForKey:@"firstName"];
            fsqLastName = [userCred objectForKey:@"lastName"];
            NSLog(@"fsqid: %@, name: %@ %@ level: %d", fsqId, fsqFirstName, fsqLastName, tumbleweedLevel);
            NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"], @"oauth_token",
                                 fsqId, @"foursquare_id",
                                 fsqFirstName, @"first_name",
                                 fsqLastName, @"last_name",
                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"devtok"], @"device_token", nil];
            [[AFTumbleweedClient sharedClient] postPath:@"register" parameters:queryParams
                                                   success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                       tumbleweedId = [JSON objectForKey:@"id"];
                                                       tumbleweedLevel = 0;
                                                       [self saveTumbleweed];
                                                       NSLog(@"tumbleweed id %@, register json %@", tumbleweedId, JSON);
                                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                       NSLog(@"tumbleweed id error %@", error);
                                                   }];
        }
    }];

}
- (BOOL) getUserUpdates
{
    if (!tumbleweedId) return NO;
    __block BOOL update = NO;
    NSString *userPath = [NSString stringWithFormat:@"users/%@", tumbleweedId];
    [[AFTumbleweedClient sharedClient] getPath:userPath parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id JSON) {
                                           int tempLevel = [[[JSON objectForKey:@"user"]objectForKey:@"level"] intValue];
                                           if (tempLevel > tumbleweedLevel) {
                                               tumbleweedLevel = tempLevel;
                                               update = YES;
                                               [self saveTumbleweed];
                                           }
                                           else if ( tempLevel < tumbleweedLevel){
                                               //post update to server if it's behind
                                               [self postUserUpdates];
                                           }
                                           NSLog(@"tumbleweed- getUser json %@", JSON);
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"tumbleweed- getUser error %@", error);
                                       }];
    return update;
}

- (void) getUserWithBlock:(void (^)(NSDictionary *userCred, NSError *error))block
{
    if (!tumbleweedId) return;
    NSString *userPath = [NSString stringWithFormat:@"users/%@", tumbleweedId];
    [[AFTumbleweedClient sharedClient] getPath:userPath parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id JSON) {
                                           tumbleweedLevel = [[[JSON objectForKey:@"user"]objectForKey:@"level"] intValue];
                                           //sceneState = [self milestonesToSceneState:[JSON objectForKey:@"checkins"]];
                                           NSLog(@"tumbleweed- getUser json %@", JSON);
                                           NSDictionary *results = [NSDictionary dictionaryWithDictionary:JSON];
                                           if (block) {
                                               block(results, nil);
                                           }
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"tumbleweed- getUser error %@", error);
                                           if (block) {
                                               block([NSDictionary dictionary], error);
                                               NSLog(@"error from getUser %@", error);
                                           }
                                       }];
}


- (void) postUserUpdates
{
    if (!tumbleweedId) return;
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 tumbleweedId, @"id",
                                 [NSNumber numberWithInt:tumbleweedLevel], @"level", nil];
    [[AFTumbleweedClient sharedClient] postPath:@"updater" parameters:queryParams
                                       success:^(AFHTTPRequestOperation *operation, id JSON) {
                                           NSLog(@"tumbleweed- updateUser json %@", JSON);
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"tumbleweed- updateUser error %@", error);
                                       }];
}







/*
#pragma mark -
#pragma mark - CLLocationManagerDelegate

- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers;
    [locationManager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 300.0)
    {
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        [locationManager stopMonitoringSignificantLocationChanges];
        //[Tumbleweed weed].desertChase.unlocked = true;
        // notify the unlocking -- animate the unlocking when back to app
        //[self scheduleNotificationWithDate:weed.riverBed2.date intervalTime:5];
        
    }
    
}
 */

@end

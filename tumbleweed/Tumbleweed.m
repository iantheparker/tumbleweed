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
@property int tumbleweedId;
@property (nonatomic, readonly) NSString *fsqId;
@property (nonatomic, readonly) NSString *fsqFirstName;
@property (nonatomic, readonly) NSString *fsqLastName;
@end


@implementation Tumbleweed

@synthesize intro, gasStation, deal, bar, riverBed1, riverBed2, desertChase, desertLynch, campFire;
@synthesize locationManager;
@synthesize tumbleweedLevel;

+ (Tumbleweed *)weed
{
    if (!weed) {
        // Create the singleton
        weed = [[super allocWithZone:NULL] init];
    }
    return weed;
}
// Prevent creation of additional instances
+ (id)allocWithZone:(NSZone *)zone
{
    return [self weed];
}

- (id)init {
    if (weed) {
        // Return the old one
        return weed;
    }
    self = [super init];
    return self;
}


- (void) registerUser
{
    //if (_tumbleweedId) return;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"tumbleweedID"]) return;
    [Foursquare getUserIdWithBlock:^(NSDictionary *userCred, NSError *error) {
        if (error) {
            NSLog(@"userCred error %@", error);
        }
        else{
            _fsqId = [userCred objectForKey:@"id"];
            _fsqFirstName = [userCred objectForKey:@"firstName"];
            _fsqLastName = [userCred objectForKey:@"lastName"];
            tumbleweedLevel = [[userCred objectForKey:@"level"] intValue];
            NSLog(@"fsqid: %@, name: %@ %@ level: %d", _fsqId, _fsqFirstName, _fsqLastName, tumbleweedLevel);
            NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"], @"oauth_token",
                                 _fsqId, @"foursquare_id",
                                 _fsqFirstName, @"first_name",
                                 _fsqLastName, @"last_name",
                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"devtok"], @"device_token", nil];
            //NSString *urlstring = [NSString stringWithFormat:@"register?oauth_token=%@&foursquare_id=%@&first_name=%@&last_name=%@&device_token=%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"], _fsqId, _fsqFirstName, _fsqLastName, [[NSUserDefaults standardUserDefaults] stringForKey:@"devtok"]];

            [[AFTumbleweedClient sharedClient] postPath:@"register" parameters:queryParams
                                                   success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                       _tumbleweedId = [[JSON objectForKey:@"id"] intValue];
                                                       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                       [defaults setInteger:_tumbleweedId forKey:@"tumbleweedID"];
                                                       [defaults synchronize];
                                                       NSLog(@"tumbleweed id %d", _tumbleweedId);
                                                       NSLog(@"tumbleweed json %@", JSON);
                                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                       NSLog(@"tumbleweed id error %@", error);
                                                   }];
        }
    }];
}

- (void) getUser
{
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"tumbleweedID"]) return;
    NSString *userPath = [NSString stringWithFormat:@"users/%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"tumbleweedID"]];
    [[AFTumbleweedClient sharedClient] getPath:userPath parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id JSON) {
                                           tumbleweedLevel = [[JSON objectForKey:@"level"] intValue];
                                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                           [defaults setInteger:_tumbleweedId forKey:@"tumbleweedID"];
                                           [defaults synchronize];
                                           NSLog(@"tumbleweed- getUser json %@", JSON);
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"tumbleweed- getUser error %@", error);
                                       }];
}

- (void) getUserWithBlock:(void (^)(NSDictionary *userCred, NSError *error))block
{
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"tumbleweedID"]) return;
    NSString *userPath = [NSString stringWithFormat:@"users/%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"tumbleweedID"]];
    [[AFTumbleweedClient sharedClient] getPath:userPath parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id JSON) {
                                           tumbleweedLevel = [[JSON objectForKey:@"level"] intValue];
                                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                           [defaults setInteger:_tumbleweedId forKey:@"tumbleweedID"];
                                           [defaults synchronize];
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


- (void) updateUser
{
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"tumbleweedID"]) return;
    NSString *userPath = [NSString stringWithFormat:@"users/%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"tumbleweedID"]];
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",tumbleweedLevel], @"level", nil];
    [[AFTumbleweedClient sharedClient] putPath:userPath parameters:queryParams
                                       success:^(AFHTTPRequestOperation *operation, id JSON) {
                                           NSLog(@"tumbleweed- updatetUser json %@", JSON);
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"tumbleweed- updateUser error %@", error);
                                       }];
    //block built-in to auto-update UI when finished
}


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
        [Tumbleweed weed].desertChase.unlocked = true;
        // notify the unlocking -- animate the unlocking when back to app
        //[self scheduleNotificationWithDate:weed.riverBed2.date intervalTime:5];
        
    }
    
}

@end

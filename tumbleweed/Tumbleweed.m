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
- (NSString *)sceneArchivePath;
- (void) loadScenes;
- (void) createScenes;
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
    [self loadScenes];
    return self;
}


- (void)loadScenes
{
    // If we don't currently have an allScenes dict, try to read one from disk
    NSLog(@"loading scenes");
    if (!allScenes) {
        //allScenes = [NSKeyedUnarchiver unarchiveObjectWithFile:[self sceneArchivePath]];
        NSLog(@"loading older allscenes, %@", allScenes);
    }
    // If we do have an archive, then set our class Scenes to the old archive
    if (allScenes)
    {
        gasStation = [allScenes objectForKey:@"gasStation"];
        deal = [allScenes objectForKey:@"deal"];
        bar = [allScenes objectForKey:@"bar"];
        riverBed1 = [allScenes objectForKey:@"riverBed1"];
        riverBed2 = [allScenes objectForKey:@"riverBed2"];
        desertChase = [allScenes objectForKey:@"desertChase"];
        desertLynch = [allScenes objectForKey:@"desertLynch"];
        campFire = [allScenes objectForKey:@"campFire"];
        NSLog(@"allScenes just unarchived%@", allScenes);

        
    }
    // If we tried to read one from disk but does not exist, then create a new one
    else 
    {
        [self createScenes];
        allScenes = [[NSMutableDictionary alloc] init];
        NSLog(@"creating scenes");
    }
}

- (void) createScenes
{
    //read all default values from plist, which is ordered by array index
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"scenes" ofType:@"plist"];
    NSDictionary *mainDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *array = [NSArray arrayWithArray:[mainDict objectForKey:@"Scenes"]];
    
    intro = [[Scene alloc] initWithDictionary:[array objectAtIndex:0]];
    deal  = [[Scene alloc] initWithDictionary:[array objectAtIndex:1]];
    bar = [[Scene alloc] initWithDictionary:[array objectAtIndex:2]];
    gasStation = [[Scene alloc] initWithDictionary:[array objectAtIndex:3]];
    riverBed1 = [[Scene alloc] initWithDictionary:[array objectAtIndex:4]];
    riverBed2 = [[Scene alloc] initWithDictionary:[array objectAtIndex:5]];
    desertChase = [[Scene alloc] initWithDictionary:[array objectAtIndex:6]];
    desertLynch = [[Scene alloc] initWithDictionary:[array objectAtIndex:7]];
    campFire = [[Scene alloc] initWithDictionary:[array objectAtIndex:8]];

}

- (BOOL)saveChanges
{
    //pack Scenes into allScenes for archive
    [allScenes removeAllObjects];
    [allScenes setObject:gasStation forKey:gasStation.name];
    [allScenes setObject:deal forKey:deal.name];
    [allScenes setObject:bar forKey:bar.name];
    [allScenes setObject:riverBed1 forKey:riverBed1.name];
    [allScenes setObject:riverBed2 forKey:riverBed2.name];
    [allScenes setObject:desertChase forKey:desertChase.name];
    [allScenes setObject:desertLynch forKey:desertLynch.name];
    [allScenes setObject:campFire forKey:campFire.name];
    NSLog(@"allScenes before saving campFire and name %@, %@", campFire, campFire.name);
    // returns success or failure
    return [NSKeyedArchiver archiveRootObject:allScenes
                                       toFile:[self sceneArchivePath]];
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

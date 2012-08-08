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
- (NSString *)sceneArchivePath;
- (void) loadScenes;
- (void) createScenes;
@end


@implementation Tumbleweed

@synthesize intro, gasStation, deal, bar, riverBed1, riverBed2, desertChase, desertLynch, campFire;
@synthesize locationManager;

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


- (NSString *)sceneArchivePath
{
    // The returned path will be Sandbox/Documents/possessions.data
    // Both the saving and loading methods will call this method to get the same path,
    // preventing a typo in the path name of either method
    return pathInDocumentDirectory(@"tumbleweedScenes.data");
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
    ASIHTTPRequest *request = [Foursquare getUserId];
    [request startSynchronous];
    NSError *err = [request error];
    if (!err) {
        NSDictionary *userResponse = [NSDictionary dictionaryWithJSONString:[request responseString] error:&err];
        NSString *foursquare_id = [[[userResponse objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
        NSString *foursquare_first_name = [[[userResponse objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"firstName"];
        NSString *foursquare_last_name = [[[userResponse objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"lastName"];
        NSString *urlString = [NSString stringWithFormat:@"%@/register", [[Environment sharedInstance] server_url]];
        NSURL *url = [NSURL URLWithString:urlString];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];   
        [request setPostValue:foursquare_id forKey:@"foursquare_id"];
        [request setPostValue:foursquare_first_name forKey:@"first_name"];
        [request setPostValue:foursquare_last_name forKey:@"last_name"];
        [request setPostValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"devtok"] forKey:@"device_token"];
        request.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"registerUser", @"operation", nil];
        [request setDelegate:self];
        [request setTimeOutSeconds:20];
        [request startAsynchronous];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:foursquare_id forKey:@"foursquare_id"];
        [defaults synchronize];
    }
    else NSLog(@"registration failed %@", err);


}
- (void) postToServer
{
    NSString *urlString = [NSString stringWithFormat:@"%@/user", [[Environment sharedInstance] server_url]];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];   
    [request setPostValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"tumbleweedID"] forKey:@"tumbleweedID"];
    request.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"postToServer", @"operation", nil];
    [request setDelegate:self];
    [request startAsynchronous];
}

#pragma mark - Required ASIHTTP Asynchronous request methods 

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    NSError *err;
    if ([[request.userInfo valueForKey:@"operation"] isEqualToString:@"registerUser"]) {
        NSDictionary *registerResponse = [NSDictionary dictionaryWithJSONString:responseString error:&err];
        //fix the path when dave gives it
        NSString *tumbleweedID = [[[registerResponse objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:tumbleweedID forKey:@"tumbleweedID"];
        [defaults synchronize];
        NSLog(@"tumbleweedID is %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"tumbleweedID"]);
    }    
    else if ([[request.userInfo valueForKey:@"operation"] isEqualToString:@"postToServer"]) {
        NSDictionary *registerResponse = [NSDictionary dictionaryWithJSONString:responseString error:&err];
        NSLog(@"register response %@", registerResponse);
    
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    //if ([[request.userInfo valueForKey:@"operation"] isEqualToString:NSURLErrorNetworkConnectionLost]) {}
    NSLog(@"%@ error! %@", [request.userInfo valueForKey:@"operation"], error);
    // Must add graceful network error like a pop-up saying, get internet!
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Timeout" message:@"Are you sure you have internet right now...?" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] ;
    //[alert show];
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

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
- (void) setSceneConstants;
@end


@implementation Tumbleweed

@synthesize gasStation, deal, bar, riverBed1, riverBed2, desertChase, desertLynch, campFire;

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
        allScenes = [NSKeyedUnarchiver unarchiveObjectWithFile:[self sceneArchivePath]];
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
    [self setSceneConstants];
}

- (void) createScenes
{
    gasStation = [[Scene alloc] init];
    deal  = [[Scene alloc] init];
    bar = [[Scene alloc] init];
    riverBed1 = [[Scene alloc] init];
    riverBed2 = [[Scene alloc] init];
    desertChase = [[Scene alloc] init];
    desertLynch = [[Scene alloc] init];
    campFire = [[Scene alloc] init];

}

- (void) setSceneConstants
{

    gasStation.name = @"gasStation";
    gasStation.categoryId = GAS_TRAVEL_catId;
    gasStation.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gasStation"
                                                                                  ofType:@"mp4"]];
    gasStation.movieThumbnail = [UIImage imageNamed:@"Gas_Station_thumbnail.jpg"];
    //gasStation.movieThumbnail = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"Gas_Station_thumbnail" ofType:@"jpg"]];
    gasStation.posterArt = [UIImage imageNamed:@"bubble5.png"];
    gasStation.accessible = true;

    deal.name = @"deal";
    deal.categoryId = DEAL_catId;
    deal.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                            ofType:@"mp4"]];
    deal.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    deal.posterArt = [UIImage imageNamed:@"bubble5.png"];
    deal.accessible = true;

    bar.name = @"bar";
    bar.categoryId = NIGHTLIFE_catId;
    bar.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                           ofType:@"mp4"]];
    bar.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    bar.posterArt = [UIImage imageNamed:@"bubble5.png"];
    bar.accessible = true;

    riverBed1.name = @"riverBed1";
    riverBed1.categoryId = OUTDOORS_catId;
    riverBed1.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                 ofType:@"mp4"]];
    riverBed1.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    riverBed1.posterArt = [UIImage imageNamed:@"bubble5.png"];

    riverBed2.name = @"riverBed2";
    riverBed2.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                 ofType:@"mp4"]];
    riverBed2.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    riverBed2.posterArt = [UIImage imageNamed:@"bubble5.png"];

    desertChase.name = @"desertChase";
    desertChase.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                   ofType:@"mp4"]];
    desertChase.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    desertChase.posterArt = [UIImage imageNamed:@"bubble5.png"];

    desertLynch.name = @"desertLynch";
    desertLynch.categoryId = OUTDOORS_catId;
    desertLynch.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                   ofType:@"mp4"]];
    desertLynch.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    desertLynch.posterArt = [UIImage imageNamed:@"bubble5.png"];

    campFire.name = @"campFire";
    campFire.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                ofType:@"mp4"]];
    campFire.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    campFire.posterArt = [UIImage imageNamed:@"bubble5.png"];

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
        NSString *urlString = [NSString stringWithFormat:@"https://tumbleweed.herokuapp.com/register"];
        NSURL *url = [NSURL URLWithString:urlString];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];   
        [request setPostValue:foursquare_id forKey:@"foursquare_id"];
        //[request setPostValue:device_token forKey:@"device_token"];
        request.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"registerUser", @"operation", nil];
        [request setDelegate:self];
        [request startAsynchronous];
    }
    else NSLog(@"registration failed %@", err);


}
- (void) postToServer
{
    NSString *urlString = [NSString stringWithFormat:@"https://tumbleweed.herokuapp.com/user"];
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
    NSLog(@"error! %@", error);
    // Must add graceful network error like a pop-up saying, get internet!
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Timeout" message:@"Are you sure you have internet right now...?" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] ;
    [alert show];
}


@end

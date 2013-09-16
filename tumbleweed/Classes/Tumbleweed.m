//
//  Tumbleweed.m
//  tumbleweed
//
//  Created by Ian Parker on 2/20/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Tumbleweed.h"
#import <SVProgressHUD.h>
#import <stdlib.h>

#define numoflevels 9

@interface Tumbleweed(SVProgressHUD)
- (void) dismissHUD: (BOOL) successful : (NSError*) err;
@end
@interface Tumbleweed(Private)
- (void) setLastKnownLocation : (NSString*) lat : (NSString*) lon;
@end

@implementation Tumbleweed

@synthesize tumbleweedId;
@synthesize tumbleweedLevel;
@synthesize lastLevelUpdate;
@synthesize lastKnownLocation;
@synthesize successfulVenues;


#pragma mark - Lifecycle Methods

+ (Tumbleweed *) sharedClient {
    static Tumbleweed *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Tumbleweed alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"tumbleweed"])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *myEncodedObject = [defaults objectForKey:@"tumbleweed"];
        self.tumbleweedLevel = [[myEncodedObject objectForKey:@"tumbleweedLevel"] intValue];
        self.tumbleweedId = [myEncodedObject objectForKey:@"tumbleweedId"];
        self.lastLevelUpdate = [myEncodedObject objectForKey:@"lastLevelUpdate"];
        [self setLastKnownLocation: [myEncodedObject objectForKey:@"lastKnownLocationLat"]
                                  : [myEncodedObject objectForKey:@"lastKnownLocationLon"]];
        NSLog(@"using stored tumbleweed %@", myEncodedObject);
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"successfulVenues"])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        successfulVenues = [NSMutableArray arrayWithArray:[defaults arrayForKey:@"successfulVenues"]];
        NSLog(@"using stored successfulVenues %@", successfulVenues);
    }
    else
    {
        successfulVenues = [NSMutableArray arrayWithCapacity:numoflevels];        
        NSLog(@"print successful venues %@", successfulVenues);
    }
        
    return self;
}

- (void) saveTumbleweed
{
    NSMutableDictionary *myEncodedObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:tumbleweedLevel], @"tumbleweedLevel",
                                            tumbleweedId, @"tumbleweedId",
                                            lastLevelUpdate, @"lastLevelUpdate",
                                            [NSString stringWithFormat:@"%f",lastKnownLocation.coordinate.latitude], @"lastKnownLocationLat",
                                            [NSString stringWithFormat:@"%f",lastKnownLocation.coordinate.longitude], @"lastKnownLocationLon",
                                            nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDictionary dictionaryWithDictionary:myEncodedObject] forKey:@"tumbleweed"];
    //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:successfulVenues]];
    [defaults setObject:[NSArray arrayWithArray:successfulVenues] forKey:@"successfulVenues"];
    [defaults synchronize];
    NSLog(@"saving tumbleweed %@ and successfulVenues %@", myEncodedObject, successfulVenues);
    //update game state
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gameSave" object:self];
    
}

#pragma mark -
#pragma mark - iVar Methods

- (void) resetLevel
{
    tumbleweedLevel = 0;
    [successfulVenues removeAllObjects];
    
    [self saveTumbleweed];
}
- (void) updateLevel : (int) toLevel withVenue :(NSString*) venue
{
    tumbleweedLevel = toLevel;
    
    if (!venue) venue = [NSString stringWithFormat:@""];
    [successfulVenues addObject:venue];
    
    [self saveTumbleweed];
    
    NSLog(@"successfulVenues %@", successfulVenues);
}

- (void) setLastKnownLocation : (NSString*) lat : (NSString*) lon
{
    if (lat && lon)
    {
        lastKnownLocation = [[CLLocation alloc] initWithLatitude:[lat floatValue]
                                                            longitude:[lon floatValue]];
    }
    else
        lastKnownLocation = nil;
}
#pragma mark -
#pragma mark - API Methods

- (void) registerUser
{
    NSLog(@"in register");
    if (tumbleweedId) return;
    [SVProgressHUD showWithStatus:@"Logging in..." maskType:SVProgressHUDMaskTypeGradient];
    [Foursquare getUserIdWithBlock:^(NSDictionary *userCred, NSError *error) {
        if (error) {
            NSLog(@"userCred error %@", error);
        }
        else{
            NSString *fsqId = [userCred objectForKey:@"id"];
            NSString *fsqFirstName = [userCred objectForKey:@"firstName"];
            NSString *fsqLastName = [userCred objectForKey:@"lastName"];
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
                                                       [self dismissHUD:YES :nil];
                                                       NSLog(@"tumbleweed id %@, register json %@", tumbleweedId, JSON);
                                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                       NSLog(@"tumbleweed id error %@", error);
                                                       tumbleweedId = [NSString stringWithFormat:@"%d",arc4random_uniform(9999)];
                                                       tumbleweedLevel = 0;
                                                       [self saveTumbleweed];
                                                       [self dismissHUD:0 :error];
                                                   }];
            
            [Foursquare addList:nil description:nil WithBlock:^(NSDictionary *listResponse, NSError *error) {
                if (error) {
                    NSLog(@"fsq addlist error %@", error);
                }
                else {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    //save listId in nsuserdefaults
                    NSString *fsqListId = [listResponse objectForKey:@"id"];
                    [defaults setObject:fsqListId forKey:@"fsqListId"];
                    //save listurl in nsuserdefaults
                    NSString *fsqListUrl = [listResponse objectForKey:@"canonicalUrl"];
                    [defaults setObject:fsqListUrl forKey:@"fsqListUrl"];
                    [defaults synchronize];
                    NSLog(@"list response fsqlistid %@ and fsqlistUrl %@", fsqListId, fsqListUrl);
                }
            }];
             
        }
    }];

}
- (void) resetUser
{
    [SVProgressHUD showWithStatus:@"Resetting..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 tumbleweedId, @"id",
                                 [NSNumber numberWithInt:0], @"level", nil];
    [[AFTumbleweedClient sharedClient] postPath:@"updater" parameters:queryParams
                                        success:^(AFHTTPRequestOperation *operation, id JSON) {
                                            NSLog(@"tumbleweed- updateUser json %@", JSON);
                                            //tumbleweedLevel = 0;
                                            [self resetLevel];
                                            [self saveTumbleweed];
                                            [self dismissHUD:YES :nil];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"tumbleweed- updateUser error %@", error);
                                            [self dismissHUD:0 :error];
                                        }];
}
- (BOOL) getUserUpdates
{
    if (!tumbleweedId) return NO;
    __block BOOL update = NO;
    //[SVProgressHUD showWithStatus:@"Checking Foursquare" maskType:SVProgressHUDMaskTypeNone];
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
                                           [self dismissHUD:NO :nil];
                                           NSLog(@"tumbleweed- getUser json %@", JSON);
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"tumbleweed- getUser error %@", error);
                                           [self dismissHUD:0 :error];
                                       }];
    return update;
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

#pragma mark -
#pragma mark - SVProgressHUD

- (void) dismissHUD: (BOOL) successful : (NSError*) err
{
    if (err)
        [SVProgressHUD showErrorWithStatus:@"Nope. Try Later :("];
    else if (successful)
        [SVProgressHUD showSuccessWithStatus:@"Boom!"];
    else
        [SVProgressHUD dismiss];
}

@end

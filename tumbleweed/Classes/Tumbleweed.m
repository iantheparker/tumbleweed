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

@synthesize fsqFirstName, fsqId, fsqLastName, tumbleweedId;
@synthesize sceneState;
@synthesize tumbleweedLevel;


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
        tumbleweedLevel = [[myEncodedObject objectForKey:@"tumbleweedLevel"] intValue];
        tumbleweedId = [myEncodedObject objectForKey:@"tumbleweedId"];
        NSLog(@"using stored tumbleweed %@", myEncodedObject);
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

+ (Tumbleweed *)sharedClient {
    static Tumbleweed *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Tumbleweed alloc] initWithDefaults];
    });
    
    return _sharedClient;
}

- (id)initWithDefaults
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
        NSLog(@"using stored tumbleweed %@", myEncodedObject);
    }
    return self;
}
/*
- (void) setTumbleweedLevel:( int)level
{
    tumbleweedLevel = level;
    NSLog(@"setting tumbleweedLevel");
    [self saveTumbleweed];
}
 */
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



@end

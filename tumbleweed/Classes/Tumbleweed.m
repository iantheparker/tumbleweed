//
//  Tumbleweed.m
//  tumbleweed
//
//  Created by Ian Parker on 2/20/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Tumbleweed.h"
#import <SVProgressHUD.h>

@interface Tumbleweed(SVProgressHUD)
- (void) dismissHUD: (BOOL) successful : (NSError*) err;
@end

@implementation Tumbleweed

@synthesize tumbleweedId;
@synthesize tumbleweedLevel;


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
        NSLog(@"using stored tumbleweed %@", myEncodedObject);
    }
    return self;
}
- (void) saveTumbleweed
{
    NSMutableDictionary *myEncodedObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:tumbleweedLevel], @"tumbleweedLevel",
                                            tumbleweedId, @"tumbleweedId", nil];
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
    [SVProgressHUD showWithStatus:@"Logging in!" maskType:SVProgressHUDMaskTypeGradient];
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
                                                       [self dismissHUD:0 :error];
                                                   }];
        }
    }];

}
- (BOOL) getUserUpdates
{
    if (!tumbleweedId) return NO;
    __block BOOL update = NO;
    [SVProgressHUD showWithStatus:@"Checking Foursquare" maskType:SVProgressHUDMaskTypeNone];
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

//
//  Environment.m
//  tumbleweed
//
//  Created by Ian Parker on 8/7/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Environment.h"

@implementation Environment

static Environment *sharedInstance = nil;

@synthesize server_url, foursquare_client_id, callback_url;

- (id)init
{
    self = [super init];
    
    if (self) {
        // Do Nada
    }
    
    return self;
}

- (void)initializeSharedInstance
{
    NSString* configuration = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuration"];
    NSLog(@"configuration state %@", configuration);
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* envsPListPath = [bundle pathForResource:@
                               "environments" ofType:@"plist"];
    NSDictionary* environments = [[NSDictionary alloc] initWithContentsOfFile:envsPListPath];
    NSDictionary* environment = [environments objectForKey:configuration];
    
    self.server_url = [environment valueForKey:@"server_url"];
    self.foursquare_client_id = [environment valueForKey:@"foursquare_client_id"];
    self.callback_url = [environment valueForKey:@"callback_url"];
}

#pragma mark - Lifecycle Methods

+ (Environment *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
            [sharedInstance initializeSharedInstance];
        }
        return sharedInstance;
    }
}

@end

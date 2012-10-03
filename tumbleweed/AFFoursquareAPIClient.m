//
//  AFFoursquareAPIClient.m
//  tumbleweed
//
//  Created by Ian Parker on 9/24/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "AFFoursquareAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAFFoursquareAPIBaseURLString = @"https://api.foursquare.com/v2/";

@implementation AFFoursquareAPIClient

+ (AFFoursquareAPIClient *)sharedClient {
    static AFFoursquareAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFFoursquareAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFFoursquareAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [self setAuthorizationHeaderWithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    //[self setParameterEncoding:AFFormURLParameterEncoding];
    return self;
}

@end

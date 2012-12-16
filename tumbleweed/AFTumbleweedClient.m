//
//  AFTumbleweedClient.m
//  tumbleweed
//
//  Created by Ian Parker on 10/2/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "AFTumbleweedClient.h"
#import "AFJSONRequestOperation.h"


@implementation AFTumbleweedClient

+ (AFTumbleweedClient *)sharedClient {
    static AFTumbleweedClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFTumbleweedClient alloc] initWithBaseURL:[NSURL URLWithString:[[Environment sharedInstance] server_url]]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    self.parameterEncoding = AFFormURLParameterEncoding;
    return self;
}


@end

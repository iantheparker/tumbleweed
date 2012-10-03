//
//  AFFoursquareAPIClient.h
//  tumbleweed
//
//  Created by Ian Parker on 9/24/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface AFFoursquareAPIClient : AFHTTPClient

+ (AFFoursquareAPIClient *)sharedClient;

@end

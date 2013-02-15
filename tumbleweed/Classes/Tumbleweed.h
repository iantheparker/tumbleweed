//
//  Tumbleweed.h
//  tumbleweed
//
//  Created by Ian Parker on 2/20/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFTumbleweedClient.h"
#import "Foursquare.h"


//this tracks the path and progress of the user
@interface Tumbleweed : NSObject {
    
    int tumbleweedLevel;
    NSString *tumbleweedId;

}

@property int tumbleweedLevel;
@property (nonatomic, retain) NSString *tumbleweedId;

+ (Tumbleweed *) sharedClient;
- (void) saveTumbleweed;

- (void) registerUser;
- (BOOL) getUserUpdates;
- (void) postUserUpdates;



@end

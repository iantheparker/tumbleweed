//
//  Scene.m
//  tumbleweed
//
//  Created by Ian Parker on 2/21/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Scene.h"

@implementation Scene

@synthesize name, categoryId, moviePath, movieThumbnail, posterArt, unlocked, watched, checkInResponse, recentSearchVenueResults, date;

- (id) init
{
    self = [super init];
    if (self) {
        unlocked = FALSE;
        watched = FALSE;
    }
    
    return self;
}

//need to make an initializer when reading from last save

//write accessors so that anytime unlocked, recentSearch, watched, and checkInResponse are set it also saves/archives to disk


@end

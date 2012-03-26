//
//  Scene.m
//  tumbleweed
//
//  Created by Ian Parker on 2/21/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Scene.h"

@implementation Scene

@synthesize name, categoryId, moviePath, movieThumbnail, posterArt, unlocked, accessible, checkInResponse, recentSearchVenueResults, date;

- (id) init
{
    self = [super init];
    if (self) {
        unlocked = FALSE;
        accessible = FALSE;
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setUnlocked:[aDecoder decodeBoolForKey:@"unlocked"]];
        [self setAccessible:[aDecoder decodeBoolForKey:@"accessible"]];
        [self setCheckInResponse:[aDecoder decodeObjectForKey:@"checkInResponse"]];
        [self setRecentSearchVenueResults:[aDecoder decodeObjectForKey:@"recentSearchVenueResults"]];
        date = [aDecoder decodeObjectForKey:@"dateCreated"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeBool:unlocked forKey:@"unlocked"];
    [encoder encodeBool:accessible forKey:@"watched"];
    [encoder encodeObject:checkInResponse forKey:@"checkInResponse"];
    [encoder encodeObject:recentSearchVenueResults forKey:@"recentSearchVenueResults"];
    [encoder encodeObject:date forKey:@"dateCreated"];

}


@end

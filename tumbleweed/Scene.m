//
//  Scene.m
//  tumbleweed
//
//  Created by Ian Parker on 2/21/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Scene.h"

@implementation Scene

@synthesize name, categoryId, movieName, movieThumbnail, posterArt, unlocked, accessible, checkInResponse, recentSearchVenueResults, date, hintCopy, checkInCopy, checkedVenue;
@synthesize button, sceneVC;


- (id) init
{
    self = [super init];
    if (self) {
        unlocked = FALSE;
        accessible = FALSE;
    }
    
    return self;
}

- (id) initWithDictionary:(NSMutableDictionary *) plistDict
{
    self = [self init];
    name = [plistDict objectForKey:@"name"];
    categoryId = [plistDict objectForKey:@"categoryId"];
    movieName = [plistDict objectForKey:@"movieName"];
    movieThumbnail = [plistDict objectForKey:@"movieThumbnail"];
    posterArt = [plistDict objectForKey:@"posterArt"];
    hintCopy = [plistDict objectForKey:@"hintCopy"];
    checkInCopy = [plistDict objectForKey:@"checkInCopy"];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(64, 40, 80, 80);
    NSString *imgName1 =[plistDict objectForKey:@"buttonAccessible"];
    UIImage *buttonImg = [UIImage imageNamed:imgName1];
    [button setImage:buttonImg forState:UIControlStateNormal];
    if ([plistDict objectForKey:@"buttonLocked"]) {
        NSString *imgName2 =[plistDict objectForKey:@"buttonLocked"];
        NSString *imgName3 =[plistDict objectForKey:@"buttonUnlocked"];
        UIImage *buttonImg2 = [UIImage imageNamed:imgName2];
        UIImage *buttonImg3 = [UIImage imageNamed:imgName3];
        [button setImage:buttonImg2 forState:UIControlStateDisabled];
        [button setImage:buttonImg3 forState:UIControlStateSelected];    
    }
    
    
    return self;
}




@end

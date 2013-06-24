//
//  Scene.m
//  tumbleweed
//
//  Created by Ian Parker on 2/21/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Scene.h"

@implementation Scene

@synthesize button, level, sceneVC, pListDetails, hintCopy;


- (id) init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (id) initWithDictionary:(NSMutableDictionary *) plistDict
{
    self = [self init];
    level = [[plistDict objectForKey:@"level"] integerValue];
    hintCopy = [plistDict objectForKey:@"hintCopy"];
    pListDetails = [NSMutableDictionary dictionaryWithDictionary:plistDict];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(64, 40, 80, 80);
    NSString *imgName1 =[plistDict objectForKey:@"buttonAccessible"];
    UIImage *buttonImg = [UIImage imageNamed:imgName1];
    [button setImage:buttonImg forState:UIControlStateNormal];
    if ([plistDict objectForKey:@"buttonLocked"]) {
        NSString *imgName2 =[plistDict objectForKey:@"buttonLocked"];
        UIImage *buttonImg2 = [UIImage imageNamed:imgName2];
        [button setImage:buttonImg2 forState:UIControlStateDisabled];
    }
    if ([plistDict objectForKey:@"buttonUnlocked"]) {
        NSString *imgName3 =[plistDict objectForKey:@"buttonUnlocked"];
        UIImage *buttonImg3 = [UIImage imageNamed:imgName3];
        [button setImage:buttonImg3 forState:UIControlStateSelected];
    }
    button.showsTouchWhenHighlighted = YES;
    button.adjustsImageWhenHighlighted = YES;
    
    return self;
}

- (SceneController*) sceneVC
{
    if (!sceneVC) {
        sceneVC = [[SceneController alloc] initWithScene:self];
    }
    return sceneVC;
}


@end

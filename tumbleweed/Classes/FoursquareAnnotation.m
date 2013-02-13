//
//  FoursquareAnnotation.m
//  Foursquare Test
//
//  Created by Angelo Villegas on 8/26/11.
//  Copyright 2011 Studio Villegas. All rights reserved.
//

#import "FoursquareAnnotation.h"

@implementation FoursquareAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize venueId;
@synthesize iconUrl;
@synthesize arrayPos;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


- (void)dealloc
{
	[title release];
	[subtitle release];
	
	[super dealloc];
}
 
 */

@end

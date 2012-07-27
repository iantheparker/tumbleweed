//
//  MapButtonView.m
//  tumbleweed
//
//  Created by Ian Parker on 7/23/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "MapButtonView.h"
#import <QuartzCore/QuartzCore.h>

@interface MapButtonView()




@end

@implementation MapButtonView

@synthesize layerName, layerView, janeLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    NSLog(@"hit %f", touchLocation.x);
    
    for (CALayer *layer in layerView.layer.sublayers) {
        if ([layer containsPoint:[layerView.layer convertPoint:touchLocation toLayer:layer]]) {
            if ([layer.name isEqualToString:layerName]) {
                NSLog(@"jane hit");
            }
            //NSLog(@"not jane hit %@ %@", layer.name, layerView.description);
        }
    }
    
}

- (void) layerListener: (NSString *) name : (UIView *) view
{
    layerName = name;
    layerView = view;
}


@end

//
//  MapButtonView.m
//  tumbleweed
//
//  Created by Ian Parker on 7/23/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "MapButtonView.h"

@interface MapButtonView()

@property (nonatomic, retain) NSString *layerName;
@property (nonatomic, retain) UIView *layerView;

//-(void) avatarTouched: (NSString*) layerName : (UIView*) layerView;

@end

@implementation MapButtonView

@synthesize layerName, layerView;

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
    /*
    for (CALayer *layer in layerView.layer.sublayers) {
        if ([layer containsPoint:[layerView.layer convertPoint:touchLocation toLayer:layer]]) {
            if ([layer.name isEqualToString:layerName]) {
                NSLog(@"jane hit");
            }
        }
    }
     */
}



@end

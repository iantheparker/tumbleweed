//
//  MapButtonView.h
//  tumbleweed
//
//  Created by Ian Parker on 7/23/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapButtonView : UIView{
    NSString *layerName;
    UIView *layerView;
    CALayer *janeLayer;
}
@property (nonatomic, retain) NSString *layerName;
@property (nonatomic, retain) UIView *layerView;
@property (nonatomic, retain) CALayer * janeLayer;

- (void) layerListener: (NSString *) name : (UIView *) view;

@end

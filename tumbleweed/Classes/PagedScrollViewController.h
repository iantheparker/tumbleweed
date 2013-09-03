//
//  PagedScrollViewController.h
//  ScrollViews
//
//  Created by Matt Galloway on 01/03/2012.
//  Copyright (c) 2012 Swipe Stack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagedScrollViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIImageView *text1;
@property (nonatomic, strong) IBOutlet UIImageView *text2;
@property (nonatomic, strong) IBOutlet UIImageView *text3;


-(int) getRandomNumberBetween:(int)from to:(int)to;
-(void) renderParallax;
-(void) updateScrollDisplay: (NSTimer*) timer;


@end

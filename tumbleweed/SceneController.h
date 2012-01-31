//
//  SceneController.h
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SceneController : UIViewController
{
    IBOutlet UIScrollView *venueScrollView;
    IBOutlet UIView *venueView;
    IBOutlet UIView *venueDetailNib;
}

@property (nonatomic, retain) UIScrollView *venueScrollView;
@property (nonatomic, retain) UIView *venueView;
@property (nonatomic, retain) UIView *venueDetailNib;

- (IBAction) dismissModal:(id)sender;
- (void) processVenues: (NSDictionary *) dict;

@end

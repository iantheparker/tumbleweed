//
//  FoursquareAuthViewController.h
//  CoreDataTalk
//
//  Created by Anoop Ranganath on 2/19/11.
//  Copyright 2011 foursquare. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FoursquareAuthViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *loadingLabel;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UIView *containerView;


- (IBAction) dismissModal:(id)sender;


@end

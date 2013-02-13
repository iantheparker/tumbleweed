//
//  BonusWebViewController.h
//  tumbleweed
//
//  Created by Ian Parker on 1/30/13.
//  Copyright (c) 2013 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BonusWebViewController : UIViewController<UIWebViewDelegate>{
    
    IBOutlet UIWebView *webView;
    NSString *urlSuffix;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *loadingLabel;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) NSString *urlSuffix;


- (id) initWithUrl: (NSString*) url;
- (IBAction) dismissModal:(id)sender;


@end

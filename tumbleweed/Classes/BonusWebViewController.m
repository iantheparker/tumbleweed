//
//  BonusWebViewController.m
//  tumbleweed
//
//  Created by Ian Parker on 1/30/13.
//  Copyright (c) 2013 AI Capital. All rights reserved.
//

#import "BonusWebViewController.h"

static NSString * const kBonusBaseURLString = @"http://western.goddamncobras.com/page/";

@implementation BonusWebViewController

@synthesize webView, loadingView, containerView, urlSuffix;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithUrl: (NSString*) url
{
    urlSuffix = url;
    return [self init];
}

- (void)dealloc
{
    // removed for ARC [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *authenticateURLString = [NSString stringWithFormat:@"%@%@", kBonusBaseURLString, urlSuffix ];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
    [webView loadRequest:request];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

#pragma mark - Web view delegate
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
    [loadingLabel removeFromSuperview];
    NSLog(@"in webview didstartload");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityIndicator stopAnimating];
    [loadingLabel removeFromSuperview];
}

- (IBAction) dismissModal:(id)sender
{
    NSLog(@"cancelling bonus web view");
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end

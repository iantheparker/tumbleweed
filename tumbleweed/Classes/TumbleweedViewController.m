//
//  ViewController.m
//  tumbleweed
//
//  Created by Ian Parker on 1/22/12.
//  Copyright (c) 2012 Tumbleweed. All rights reserved.
//

#import "TumbleweedViewController.h"
#import "SceneController.h"
//#import "FoursquareAuthViewController.h"
#import "MCSpriteLayer.h"
#import <SVProgressHUD.h>

#define canvas_w 5762
#define canvas_h 320

@interface TumbleweedViewController()

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) CALayer *map0CA;
@property (nonatomic, retain) CALayer *map1CA;
@property (nonatomic, retain) CALayer *map1BCA;
@property (nonatomic, retain) CALayer *map1CCA;
@property (nonatomic, retain) CALayer *map2CA;
@property (nonatomic, retain) CALayer *map4CA;
@property (nonatomic, retain) CALayer *map3CA;
@property (nonatomic, retain) CALayer *janeAvatar;
@property (nonatomic, retain) UIView *mapCAView;
@property (nonatomic, retain) UIButton *buttonContainer;
@property (nonatomic, retain) CALayer *blackPanel;
@property (nonatomic, getter = isLoggedIn) BOOL loggedIn;

-(void) gameSavetNotif: (NSNotification *) notif;
-(void) scenePressed:(UIButton*)sender;
-(void) launchHintPopUp:(BOOL) up : (NSString*) layerTip;
-(void) launchProgressPopUp:(BOOL) up;
-(void) renderScreen: (BOOL) direction : (BOOL) moving : (BOOL) tapped;
-(void) loadAvatarPosition;
-(CGRect) selectAvatarBounds:(float) position;
-(void) updateProgressBar: (int) level;
-(void) startCampfire;
-(void) popBeginSign;
-(void) updateSceneButtonStates;
-(CGPoint) coordinatePListReader: (NSString*) positionString;
-(NSMutableArray*) mapLayerPListPlacer: (NSDictionary*) plist : (CGSize) screenSize : (CALayer*) parentLayer : (NSMutableArray*) sceneArray;
-(CALayer*) layerInitializer: (id) plistObject :(CGSize) screenSize : (CALayer*) parentLayer : (NSString*) layerName;
-(int)getRandomNumberBetween:(int)from to:(int)to;

@end

@implementation TumbleweedViewController{
@private
    int lastContentOffset;
    BOOL walkingForward;
    CATextLayer *progressLabel;
    CALayer *progressBar;
    CALayer *progressBarEmpty;
    UIView *hintVC;

}

@synthesize scrollView, map0CA, map1CA, map1BCA, map1CCA, map2CA, map4CA, map3CA, mapCAView, janeAvatar;
@synthesize foursquareConnectButton, buttonContainer, blackPanel;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        map0CA = [CALayer layer];
        map1CA = [CALayer layer];
        map1BCA = [CALayer layer];
        map1CCA = [CALayer layer];
        map2CA = [CALayer layer];
        map4CA = [CALayer layer];
        map3CA = [CALayer layer];
        janeAvatar = [CALayer layer];
        mapCAView = [[UIView alloc] init];
    }
    return self;
}
#pragma mark -
#pragma mark screen renders



- (CGRect) selectAvatarBounds:(float) position
{
    static const CGRect sampleRects[8] = {
        
        {67, 0, 91, 181},
        {163, 0, 81, 183},
        {254, 0, 119, 181},
        {372, 0, 91, 183},
        {468, 0, 83, 183},
        {560, 0, 119, 181},
        {0, 0, 67, 181},       // still state, but first coords in sprite sheet
        {678, 0, 67, 181},    // crossed arms state, last in coords spreadsheet
    };
    
    //return still state
    if (position == -1)
        return sampleRects[6];
    if (position == -2)
        return sampleRects[7];
    

    int frameSize = 20;
    int imageCount = 6;
    int currentPosition = (int) position;
    unsigned int imageIndex = (currentPosition + (frameSize * imageCount)) % (frameSize * imageCount) / frameSize;
    return sampleRects[imageIndex];
}
- (void) saveAvatarPosition
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:scrollView.contentOffset.x forKey:@"scroll_view_position"];
    [defaults setBool:walkingForward forKey:@"walkingForward"];
    NSLog(@"saving Jane's position");
}
- (void) loadAvatarPosition
{
    CGPoint center = CGPointMake([[NSUserDefaults standardUserDefaults] floatForKey:@"scroll_view_position"], 0);
    NSLog(@"loading saved center %f", center.x);
    scrollView.contentOffset = center;
}
- (void) renderScreen: (BOOL) direction :(BOOL) moving :(BOOL) tapped
{
    double avatar_offset = 220;
    double janeLeftBound = 372;
    double janeRightBound = 5275;
    CGPoint center;
    CGRect bounds;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // if woken up and no avatar values, then set them
    //if (!janeAvatar.position.x) janeAvatar.position = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
    
    //set JANE position
    if ([scrollView contentOffset].x <janeLeftBound - avatar_offset || [scrollView contentOffset].x >janeRightBound - avatar_offset || !moving)
    {
        bounds = [self selectAvatarBounds:-1];        
        if (janeAvatar.position.x <= janeLeftBound) center = CGPointMake(janeLeftBound, avatar_offset);
        else if (janeAvatar.position.x >= janeRightBound) center = CGPointMake(janeRightBound, avatar_offset);
        else center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
    }        
    else {
        center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
        bounds = [self selectAvatarBounds:[scrollView contentOffset].x];
    }
    
    if (tapped) {
        bounds = [self selectAvatarBounds:-2];
    }

    
    //--> shouldn't be scaling here. must fix!
    float janeSpriteSheetW = 799.0;
    float jandeSpriteSheetH = 200.0;
    janeAvatar.bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    janeAvatar.contentsRect = CGRectMake(bounds.origin.x/janeSpriteSheetW, bounds.origin.y/jandeSpriteSheetH, bounds.size.width/janeSpriteSheetW, bounds.size.height/jandeSpriteSheetH);
    
    [janeAvatar setPosition:center];
    
    //set JANE direction
    if (!direction) {
        janeAvatar.transform = CATransform3DScale(CATransform3DMakeRotation(0, 0, 0, 1),
                                                  -1, 1, 1);
    }
    else {
        janeAvatar.transform = CATransform3DScale(CATransform3DMakeRotation(0, 0, 0, 1),
                                                  1, 1, 1);
    }
    
    //animate progress bar
    if (([scrollView contentOffset].x + [[UIScreen mainScreen] bounds].size.width) > (canvas_w - [[UIScreen mainScreen] bounds].size.width))
    {
        CGPoint currentpos = progressBar.position;
        float progbarCoefficient = .001;
        float edgeOffset = [scrollView contentOffset].x + [[UIScreen mainScreen] bounds].size.width - canvas_w;
        CGPoint progbarCenter = CGPointMake( currentpos.x , currentpos.y + (edgeOffset * progbarCoefficient) );
        [progressBar setPosition:progbarCenter];
        
    }
    
    
    //MAP LAYER PARALLAX SPEEDS
    
    CGPoint mapCenter = map1CA.position;
    float janeOffset = mapCenter.x - scrollView.contentOffset.x;
    
    //-sky position- CALayer - fix the hardcoded offset here
    float skyCoefficient = .9;
    CGPoint skyCenter = CGPointMake(floorf(avatar_offset+mapCenter.x - (janeOffset * skyCoefficient)), floorf([map0CA bounds].size.height/2.0));
    [map0CA setPosition:skyCenter];
    
    //--> layer1C position
    float layer1CCoefficient = .4;
    CGPoint layer1CPos = CGPointMake(floorf(mapCenter.x - (janeOffset * layer1CCoefficient)), map1CCA.position.y);
    [map1CCA setPosition:layer1CPos];
    
    //--> layer1B position
    float layer1BCoefficient = .04;
    CGPoint layer1BPos = CGPointMake(floorf(mapCenter.x + (janeOffset * layer1BCoefficient)), map1BCA.position.y);
    [map1BCA setPosition:layer1BPos];
    
    //--> layer2 position
    float layer2Coefficient = .03;
    CGPoint layer2Pos = CGPointMake(mapCenter.x + (janeOffset * layer2Coefficient), map2CA.position.y);
    [map2CA setPosition:layer2Pos];
    
    //--> top layer position
    float toplayerCoefficient = 1.5;
    CGPoint toplayerPos = CGPointMake(floorf(avatar_offset+mapCenter.x + (janeOffset * toplayerCoefficient)), map4CA.position.y);
    [map4CA setPosition:toplayerPos];
    
    //--> top layer buttons
    [buttonContainer setCenter:toplayerPos];
    
    [CATransaction commit];
    
    
}
#pragma mark -
#pragma mark scrollView handlers

- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    if (lastContentOffset > scrollView.contentOffset.x)
    {
        walkingForward = NO;

    }
    else if (lastContentOffset < scrollView.contentOffset.x) 
    {
        walkingForward = YES;    
    }
    lastContentOffset = scrollView.contentOffset.x;
    [self renderScreen:walkingForward:TRUE :FALSE];
    
    if( scrollView.contentOffset.x < -scrollView.contentInset.left )
    {
        //NSLog( @"bounce left" );
    }
    if( scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width + scrollView.contentInset.right )
    {
        //NSLog( @"bounce right" );
    }
    
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    [self renderScreen:walkingForward:FALSE :FALSE];
}
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self renderScreen:walkingForward:FALSE :FALSE];
}
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self launchHintPopUp:FALSE:nil];
}

#pragma mark -
#pragma mark animation controls
-(void) popBeginSign
{
    /*
    UIImage *beginSignimg = [UIImage imageNamed:@"top_lvl4_objs_0.png"];
    UIImageView *beginSign = [[UIImageView alloc] initWithImage:beginSignimg];
    beginSign.center = CGPointMake(120, 320 + beginSignimg.size.width );
    beginSign.transform = CGAffineTransformMakeRotation(-90 * M_PI / 180);

    [scrollView addSubview:beginSign];
    [UIView animateWithDuration:0.5 animations:^{
        beginSign.center = CGPointMake(120, 320 - beginSignimg.size.height/2 );
        CGAffineTransform transform1 = CGAffineTransformMakeRotation(1 * M_PI / 180);
        beginSign.transform = transform1;
    }];
     */
}
-(void) startCampfire
{
    [blackPanel removeFromSuperlayer];
    
    //should read from plist if i want to support non-retina
    CGSize fixedSize = CGSizeMake(256, 289);
    CGImageRef campfireImage = [[UIImage imageNamed:@"campfire"] CGImage];
    MCSpriteLayer* campfireSprite = [MCSpriteLayer layerWithImage:campfireImage sampleSize:fixedSize];
    campfireSprite.position = CGPointMake(scrollView.contentSize.width - (fixedSize.width - 14), scrollView.contentSize.height/2 + 26);
    
    CABasicAnimation *campfireAnimation = [CABasicAnimation animationWithKeyPath:@"sampleIndex"];
    campfireAnimation.fromValue = [NSNumber numberWithInt:1];
    campfireAnimation.toValue = [NSNumber numberWithInt:5];
    campfireAnimation.duration = .40f;
    campfireAnimation.repeatCount = HUGE_VALF;
    campfireAnimation.removedOnCompletion = NO;
    
    [campfireSprite addAnimation:campfireAnimation forKey:nil];
    [map1CA addSublayer:campfireSprite];
    //add button
    
    [[scenes.lastObject button] setCenter:CGPointMake(campfireSprite.position.x-3, campfireSprite.position.y + 40)];
    [scrollView addSubview:[scenes.lastObject button]];
}
#pragma mark - 
#pragma mark button handlers

- (IBAction) foursquareConnect:(UIButton *)sender
{
    if ([[Tumbleweed sharedClient] tumbleweedId]){
        //[[Tumbleweed sharedClient] resetUser];
    }else
        [Foursquare startAuthorization];
}
- (void) scenePressed:(UIButton *)sender
{
    //[self presentViewController:[[scenes objectAtIndex:sender.tag] sceneVC] animated:YES completion:^{}];
    [UIView animateWithDuration:0.50
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:[[scenes objectAtIndex:sender.tag] sceneVC] animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
                     }];
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}
- (void) handleSingleTap:(UIGestureRecognizer *)sender
{
    BOOL hit = NO;
    CGPoint loc = [sender locationInView:mapCAView];
    NSString *tipText;
    
    for (UIButton *button in mapCAView.layer.sublayers) {
        /*
        if ([button.layer containsPoint:[mapCAView.layer convertPoint:loc toLayer:button.layer]]){
            NSLog(@"button found");
        }*/
    }
    for (CALayer *layer in mapCAView.layer.sublayers) {
        if ([layer containsPoint:[mapCAView.layer convertPoint:loc toLayer:layer]]) {
            if ([layer.name isEqualToString:janeAvatar.name]) {
                hit = YES;
                [self renderScreen:walkingForward :FALSE :TRUE];
                break;
            }
            for (CALayer *sublayer in layer.sublayers) {
                if ([sublayer containsPoint:[mapCAView.layer convertPoint:loc toLayer:sublayer]] && sublayer.name) {
                    tipText = sublayer.name;
                    hit = YES;
                    NSLog(@"asset hit: %@ on %@", sublayer.name, layer.name);
                    [self renderScreen:walkingForward :FALSE :TRUE];
                    break;
                }
            }
        }
    }

    [self launchHintPopUp:hit:tipText];
}
- (void) launchHintPopUp :(BOOL) up : (NSString*) layerTip
{

    if (up == TRUE && (!CGAffineTransformEqualToTransform(hintVC.transform, CGAffineTransformIdentity))) {
        if (!hintVC) {
            hintVC = [[[NSBundle mainBundle] loadNibNamed:@"HintPopUp" owner:self options:nil] objectAtIndex:0];
            [hintVC viewWithTag:2].layer.cornerRadius = 5.0;
        }
        
        UILabel *hintLabel = (UILabel *)[hintVC viewWithTag:1];
        if (layerTip) hintLabel.text =  layerTip;
        else if ([[Tumbleweed sharedClient] tumbleweedId])hintLabel.text = [[scenes objectAtIndex:[Tumbleweed sharedClient].tumbleweedLevel+1] hintCopy];
        else hintLabel.text = [[scenes objectAtIndex:[Tumbleweed sharedClient].tumbleweedLevel] hintCopy];
        UIColor *brownC = [UIColor colorWithRed:62.0/255.0 green:43.0/255.0 blue:26.0/255.0 alpha:1.0];
        hintLabel.textColor = brownC;
        hintLabel.font = [UIFont fontWithName:@"rockwell" size:20];
        
        hintVC.center = CGPointMake(janeAvatar.position.x, janeAvatar.position.y - janeAvatar.bounds.size.height/3);
        //hintVC.layer.transform = CATransform3DIdentity;
        hintVC.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [self.view addSubview:hintVC];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            hintVC.transform = CGAffineTransformIdentity;
            hintVC.center = CGPointMake([[UIScreen mainScreen] applicationFrame].size.height/2 + scrollView.contentOffset.x, hintVC.bounds.size.height/2);
        } completion:^(BOOL finished) {}];
         
    }
    else{
        hintVC.transform = CGAffineTransformIdentity;
        //hintVC.layer.transform = CATransform3DIdentity;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            hintVC.transform = CGAffineTransformMakeTranslation(0, -100);
            
            //hintVC.layer.transform = CATransform3DMakeRotation(M_PI_2,1.0,0.0,0.0);
            //hintVC.center = janeAvatar.position;
        } completion:^(BOOL finished) {
            [hintVC removeFromSuperview];
        }];
    }
    
}

-(void) launchProgressPopUp:(BOOL) up
{
    CALayer *forgotImage = [CALayer layer];
    UIImage *forgotImg = [UIImage imageNamed:@"map_hint-at-end.jpg"];
    forgotImage.bounds = CGRectMake(0, 0, forgotImg.size.width, forgotImg.size.height);
    forgotImage.position = CGPointMake(blackPanel.bounds.size.width/2.5, blackPanel.bounds.size.height/4);
    [forgotImage setContents:(__bridge id)[forgotImg CGImage]];
    [blackPanel addSublayer:forgotImage];
}
#pragma mark -
#pragma mark game state updates
-(void) gameSavetNotif: (NSNotification *) notif
{
    NSLog(@"in gameSaveNotif with %@", [notif name]);
    
    if ([[notif name] isEqualToString:@"gameSave"])
    {
        [self gameState];
    }
    else if ([[notif name] isEqualToString:@"loggedIn"])
    {
        //[self gameState];
        //trigger begin sign animation
    }
}
- (void) gameState
{
    switch ([Tumbleweed sharedClient].tumbleweedLevel) {
        
        case 4:
            //wait for notification from server when timer is up
            //if seems like it's been a long wait, double-check on foursquare's push and post an update
            break;
            
        case 5:
            //turn on region monitoring - ( [newLocation distanceFromLocation:riverbed2.location] > 2000)
            //[self startSignificantChangeUpdates];
            //when finishes must unlock desertChase then launch a notification
            break;
            
        case 6:
            break;
            
        case 7:
            [self startCampfire];
            break;
        default:
            //not logged in
            break;
            
    }
    [self updateSceneButtonStates];
    [self updateProgressBar:[Tumbleweed sharedClient].tumbleweedLevel];

}
-(void) updateSceneButtonStates
{
    NSLog(@"update scene with level %d", [Tumbleweed sharedClient].tumbleweedLevel);
    if ([[Tumbleweed sharedClient] tumbleweedId]){
        NSLog(@"access token %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"]);
        foursquareConnectButton.enabled = NO;
        [foursquareConnectButton removeFromSuperview];
        [self setLoggedIn:YES];
    }
    
    //start this loop at 1 because scene 0 is the intro and that should always be accessible
    for (int i = 1; i < scenes.count; i++)
    {
        if (![[Tumbleweed sharedClient] tumbleweedId]) {
            [[scenes objectAtIndex:i] button].enabled = NO;
        }
        else if (([[scenes objectAtIndex:i] level] > [Tumbleweed sharedClient].tumbleweedLevel)) {
            [[scenes objectAtIndex:i] button].enabled = NO;
        }
        else if ([[scenes objectAtIndex:i] level] == [Tumbleweed sharedClient].tumbleweedLevel) {
            [[scenes objectAtIndex:i] button].enabled = YES;
        }
        else if ([[scenes objectAtIndex:i] level] < [Tumbleweed sharedClient].tumbleweedLevel){
            [[scenes objectAtIndex:i] button].selected = YES;
        }
    }
}
-(void) updateProgressBar: (int) level
{
    const float imageWidth = 282.7;
    const float imageHeight = 39.5;
    
    static const CGRect sampleRects[8] = {
        {0, 0, imageWidth, imageHeight},
        {40 * 1, 0, imageWidth-(40*1), imageHeight},
        {78, 0, imageWidth-78, imageHeight},
        {117, 0, imageWidth-117, imageHeight},
        {156.5, 0, imageWidth-156.5, imageHeight},
        {188.5, 0, imageWidth-188.5, imageHeight},
        {212, 0, imageWidth-212, imageHeight},
        {255, 0, imageWidth-255, imageHeight},
        
    };
    progressBarEmpty.bounds = sampleRects[level];
    progressBarEmpty.contentsRect = CGRectMake(progressBarEmpty.bounds.origin.x/imageWidth, progressBarEmpty.bounds.origin.y/imageHeight, progressBarEmpty.bounds.size.width/imageWidth, progressBarEmpty.bounds.size.height/imageHeight);
    [progressLabel setString:[NSString stringWithFormat:@"%d more until the jig is up", 8-level]];

}

#pragma mark -
#pragma mark pList tools
-(CGPoint) coordinatePListReader:(NSString *)positionString
{
    positionString = [positionString stringByReplacingOccurrencesOfString:@"{" withString:@""];
    positionString = [positionString stringByReplacingOccurrencesOfString:@" " withString:@""];
    positionString = [positionString stringByReplacingOccurrencesOfString:@"}" withString:@""];
    NSArray *strings = [positionString componentsSeparatedByString:@","];
    
    float originX = [[strings objectAtIndex:0] floatValue];
    float originY = [[strings objectAtIndex:1] floatValue];
    return CGPointMake(originX, originY);
}
-(CALayer*) layerInitializer: (id) plistObject : (CGSize) screenSize : (CALayer*) parentLayer : (NSString*) layerName
{
    // plistObject is a single element in a plist dict. 
    int zPos = 0;
    CGPoint boundsMultiplier = CGPointMake(1, 1);
    if ([plistObject isKindOfClass:[NSDictionary class]]) {
        if ([plistObject objectForKey:@"zPosition"]) zPos =  [[plistObject objectForKey:@"zPosition"] integerValue];
        if ([plistObject objectForKey:@"boundsMultiplier"]) boundsMultiplier = [self coordinatePListReader:[plistObject objectForKey:@"boundsMultiplier"]];
    }
    CGRect mapFrame = CGRectMake(0, 0, floorf(screenSize.width * boundsMultiplier.x), floorf(screenSize.height * boundsMultiplier.y));
    
    CALayer *mapLayer = [CALayer layer];
    if (layerName) mapLayer.name = layerName;
    [mapLayer setBounds:mapFrame];
    [mapLayer setPosition:CGPointMake(floorf(screenSize.width/2), floorf(screenSize.height/2))];
    [mapLayer setZPosition:zPos];
    [parentLayer addSublayer:mapLayer];
    return mapLayer;
}
-(NSMutableArray*) mapLayerPListPlacer: (NSDictionary*) plist : (CGSize) screenSize : (CALayer*) parentLayer : (NSMutableArray*) sceneArray
{
    NSMutableArray *layerArray = [NSMutableArray array];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (NSString *key in plist)
    {
        CALayer *mapCALayer = [self layerInitializer:[plist objectForKey:key]  :screenSize : parentLayer : key];
        // This is for the double-placing an array, currently only maplayer1
        if ([[plist objectForKey:key] isKindOfClass:[NSArray class]] )
        {
            NSArray *mapLayerArray = [plist objectForKey:key];
            //subLayerOriginX is now -1100 to compensate for superdrag image width
            float subLayerOriginX = -(float)[UIImage imageNamed:[mapLayerArray objectAtIndex:0]].size.width/2.0;
            for (int i=0; i<mapLayerArray.count; i+=2)
            {
                CALayer *subLayer1 = [CALayer layer];
                CALayer *subLayer2 = [CALayer layer];
                NSString *imageName1 = [mapLayerArray objectAtIndex:i];
                NSString *imageName2 = [mapLayerArray objectAtIndex:i+1];
                UIImage *image1 = [UIImage imageNamed:imageName1];
                UIImage *image2 = [UIImage imageNamed:imageName2];
                subLayer1.contents = (id)[UIImage
                                          imageWithCGImage:[image1 CGImage]
                                          scale:1.0
                                          orientation:UIImageOrientationRight].CGImage;
                subLayer2.contents = (id)[UIImage
                                          imageWithCGImage:[image2 CGImage]
                                          scale:1.0
                                          orientation:UIImageOrientationRight].CGImage;
                subLayer1.frame = CGRectMake(subLayerOriginX, 0,image1.size.width/2,image1.size.height/2);
                subLayer2.frame = CGRectMake(subLayerOriginX, image1.size.height/2,image2.size.width/2,image2.size.height/2);
                subLayerOriginX += image1.size.width/2;
                //NSLog(@"layer %d frame %@", i, NSStringFromCGRect(subLayer1.frame));
                //NSLog(@"layer %d frame %@", i+array.count/2, NSStringFromCGRect(subLayer2.frame));
                //subLayer1.opaque = YES;
                subLayer2.opaque = YES;
                
                [mapCALayer addSublayer:subLayer1];
                [mapCALayer addSublayer:subLayer2];
            }
        }
        // for all dictionary-based base layers
        else
        {
            NSDictionary *mapLayerDict = [plist objectForKey:key];
            BOOL bottomAlignment = NO;
            if ([mapLayerDict objectForKey:@"bottomAlignment"]) bottomAlignment = YES;
            for (NSString *dictkey in mapLayerDict)
            {
                if (![[mapLayerDict objectForKey:dictkey] isKindOfClass:[NSDictionary class]]) continue;
                NSDictionary *sceneDict = [mapLayerDict objectForKey:dictkey];
                CALayer *subLayer1 = [CALayer layer];
                NSString *imageName1 = [sceneDict objectForKey:@"img"];
                UIImage *image1 = [UIImage imageNamed:imageName1];
                subLayer1.contents = (id)[UIImage
                                          imageWithCGImage:[image1 CGImage]
                                          scale:1.0
                                          orientation:UIImageOrientationRight].CGImage;
                CGPoint pos = [self coordinatePListReader:[sceneDict objectForKey:@"position"]];
                subLayer1.bounds = CGRectMake(0, 0, image1.size.width/2, image1.size.height/2);
                if ([sceneDict objectForKey:@"name"]) {
                    subLayer1.name = [sceneDict objectForKey:@"name"];
                }
                
                //for top layers that should be positioned at the bottom of the screen
                if (bottomAlignment)
                {
                    subLayer1.position = CGPointMake(pos.x, mapCALayer.bounds.size.height-subLayer1.bounds.size.height/2);
                }
                else subLayer1.position = pos;
                
                // if it's an image that holds a sceneButton, then position that button
                if ([sceneDict objectForKey:@"sceneButtonNumber"])
                {
                    int scenePosition = [[sceneDict objectForKey:@"sceneButtonNumber"] integerValue];
                    [[[sceneArray objectAtIndex:scenePosition] button] setCenter:[self coordinatePListReader:[sceneDict objectForKey:@"buttonPosition"]]];
                }
                 
                [mapCALayer addSublayer:subLayer1];
            }
        }
        [layerArray addObject:mapCALayer];
    }
    [CATransaction commit];
    // order by plist key name
    [layerArray sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(CALayer*)a name];
        NSString *second = [(CALayer*)b name];
        return [first compare:second];
    }];

    return layerArray;
}


-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGSize screenSize = CGSizeMake(canvas_w, canvas_h);
    scrollView.contentSize = screenSize;    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [scrollView setDelegate:self];
    
    UITapGestureRecognizer *tapHandler = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
    [scrollView addGestureRecognizer:tapHandler];
    [tapHandler setDelegate:self];
    
    mapCAView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [scrollView addSubview:mapCAView];
    
    NSString *sceneplistPath = [[NSBundle mainBundle] pathForResource:@"scenes" ofType:@"plist"];
    NSDictionary *scenemainDict = [NSDictionary dictionaryWithContentsOfFile:sceneplistPath];
    NSMutableArray *scenePList = [NSMutableArray arrayWithArray:[scenemainDict objectForKey:@"Scenes"]];
    scenes = [NSMutableArray arrayWithCapacity:scenePList.count];
    
    for (int i=0; i < scenePList.count; i++) {
        [scenes addObject:[[Scene alloc] initWithDictionary:[scenePList objectAtIndex:i]]];
        [[[scenes objectAtIndex:i] button] addTarget:self action:@selector(scenePressed:) forControlEvents:UIControlEventTouchDown];
        [[scenes objectAtIndex:i] button].tag = i;
        
        //stopping at count-1  to not add the campfire button to the toplayer container - need a better way
        if (i < scenePList.count - 1) [buttonContainer addSubview:[[scenes objectAtIndex:i] button]];
    }
    
    NSString *mapLayerPListPath = [[NSBundle mainBundle] pathForResource:@"mapLayers" ofType:@"plist"];
    NSDictionary *mapLayerPListMainDict = [NSDictionary dictionaryWithContentsOfFile:mapLayerPListPath];
    parallaxLayers = [self mapLayerPListPlacer:mapLayerPListMainDict :screenSize :mapCAView.layer : scenes];
    
    map1CA = [parallaxLayers objectAtIndex:0];
    map1BCA = [parallaxLayers objectAtIndex:1];
    map1CCA = [parallaxLayers objectAtIndex:2];
    map2CA = [parallaxLayers objectAtIndex:3];
    map3CA = [parallaxLayers objectAtIndex:4];
    map4CA = [parallaxLayers objectAtIndex:5];
    
    buttonContainer.bounds = map4CA.bounds;   //set bounds to toplayer
    buttonContainer.center = CGPointMake([map4CA position].x, 0);
    [scrollView addSubview:buttonContainer];
    [scrollView addSubview:foursquareConnectButton];
    
    //-->jane avatar
    {
        CGImageRef avatarImage = [[UIImage imageNamed:@"janeFixed.png"] CGImage];
        [janeAvatar setContents:(__bridge id)avatarImage];
        [janeAvatar setZPosition:2];
        janeAvatar.name = @"janeAvatar";
        [mapCAView.layer addSublayer:janeAvatar];
    }

    //-->sky
    {
        UIImage *skyImage = [UIImage imageNamed:@"sky.jpg"];
        CGRect skyFrame = CGRectMake(0, 0, skyImage.size.width, skyImage.size.height);
        [map0CA setBounds:skyFrame];
        [map0CA setPosition:CGPointMake(screenSize.width/2, mapCAView.frame.size.height)];
        CGImageRef map0Image = [skyImage CGImage];
        [map0CA setContents:(__bridge id)map0Image];
        [map0CA setZPosition:-5];
        map0CA.opaque = YES;
        [mapCAView.layer addSublayer:map0CA];
    }
    //-->noose animation
    {
        CALayer *hangnoose2 = [CALayer layer];
        UIImage *hangnoose2img = [UIImage imageNamed:@"top_lvl4_objs_10B.png"];
        hangnoose2.bounds = CGRectMake(0, 0, hangnoose2img.size.width/2, hangnoose2img.size.height/2);
        hangnoose2.position = CGPointMake(11557, 27);
        hangnoose2.anchorPoint = CGPointMake(.5, 0);
        CGImageRef hangnoose2Image = [hangnoose2img CGImage];
        [hangnoose2 setContents:(__bridge id)hangnoose2Image];
        hangnoose2.name = @"Why do I get the feeling that this noose is meant for me...?";
        [map4CA addSublayer:hangnoose2];
        
        CABasicAnimation* nooseAnimation;
        nooseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        nooseAnimation.fromValue = [NSNumber numberWithFloat:2.0 * M_PI];
        nooseAnimation.toValue = [NSNumber numberWithFloat:2.02 * M_PI];
        nooseAnimation.duration = 1.5;
        //animation.cumulative = YES;
        nooseAnimation.autoreverses = YES;
        nooseAnimation.repeatCount = HUGE_VAL;
        nooseAnimation.removedOnCompletion = NO;
        nooseAnimation.fillMode = kCAFillModeForwards;
        nooseAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        [hangnoose2 addAnimation:nooseAnimation forKey:@"transform.rotation.z"];
    }
    //-->cloud animation
    {
        for (int i = 1; i<21; i++)
        {
            CALayer *cloud1 = [CALayer layer];
            UIImage *cloud1img = [UIImage imageNamed:[NSString stringWithFormat:@"cloud_%02d.png", i]];
            cloud1.bounds = CGRectMake(0, 0, cloud1img.size.width/2, cloud1img.size.height/2);
            cloud1.position = CGPointMake(0, [self getRandomNumberBetween:10 to:32 ]);
            CGImageRef cloud1imgref = [cloud1img CGImage];
            [cloud1 setContents:(__bridge id)cloud1imgref];
            //cloud1.name = @"cloud";
            [map1BCA addSublayer:cloud1];
            
            CABasicAnimation *cloud1anim;
            cloud1anim = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
            cloud1anim.fromValue = [NSNumber numberWithInt:[self getRandomNumberBetween:0 to:screenSize.width-300 ]];
            cloud1anim.toValue = [NSNumber numberWithInt:screenSize.width];
            cloud1anim.duration = [self getRandomNumberBetween:300 to:400]; //90 - 300?
            cloud1anim.autoreverses = YES;
            //cloud1anim.cumulative = YES;
            cloud1anim.repeatCount = HUGE_VAL;
            cloud1anim.removedOnCompletion = NO;
            //cloud1anim.fillMode = kCAFillModeForwards;
            //cloud1anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            cloud1anim.delegate = self;
            [cloud1anim setValue:@"cloud" forKey:@"tag"];
            [cloud1 addAnimation:cloud1anim forKey:[NSString stringWithFormat:@"cloud_%02d", i]];
            
        }
        
        //set this up so it pulls from a plist of images with variable speeds assigned and positions in the canvas
        //place them 
    }
    //-->cowboy animation
    {
        CALayer *cowboy = [CALayer layer];
        UIImage *cowboyimg = [UIImage imageNamed:@"Dude_head"];
        cowboy.frame = CGRectMake(0, 0, floorf(cowboyimg.size.width), floorf(cowboyimg.size.height));
        cowboy.anchorPoint = CGPointMake(0.5, 0.5);
        cowboy.position = CGPointMake(2590, ceilf(screenSize.height - cowboy.bounds.size.height/2));
        //CGImageRef cowboyimgref = [cowboyimg CGImage];
        [cowboy setContents:(__bridge id)[cowboyimg CGImage]];
        cowboy.name = @"That dude is a dick.";
        [map4CA addSublayer:cowboy];
        
        CALayer *cowboyHat = [CALayer layer];
        UIImage *cowboyHatimg = [UIImage imageNamed:@"Dude_hat.png"];
        cowboyHat.bounds = CGRectMake(0, 0, cowboyHatimg.size.width/2, cowboyHatimg.size.height/2);
        cowboyHat.anchorPoint = CGPointMake(0.5, 0.5);
        cowboyHat.position = CGPointMake(142, -10);
        CGImageRef cowboyHatimgRef = [cowboyHatimg CGImage];
        [cowboyHat setContents:(__bridge id) cowboyHatimgRef];
        [cowboy addSublayer:cowboyHat];
 
        
        CAKeyframeAnimation *cowboyHatTipAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        cowboyHatTipAnim.duration = 5.0f;
        cowboyHatTipAnim.repeatCount = HUGE_VALF;
        //cowboyHatTipAnim.calculationMode = kCAAnimationPaced;
        cowboyHatTipAnim.removedOnCompletion = NO;
        cowboyHatTipAnim.fillMode = kCAFillModeForwards;
        
        cowboyHatTipAnim.values = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0 * M_PI],
                                   [NSNumber numberWithFloat:0.04 * M_PI],
                                   [NSNumber numberWithFloat:0 * M_PI], nil] ;
        
        cowboyHatTipAnim.keyTimes = [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0.1],
                                     [NSNumber numberWithFloat:0.15],
                                     [NSNumber numberWithFloat:0.25], nil] ;
        
        [cowboyHat addAnimation:cowboyHatTipAnim forKey:@"transform.rotation.z"];
        
        //invisible calayer to animate y translation of arm. embedded on hat, and hand will be embedded on this
        CALayer *cowboyHandHold = [CALayer layer];
        cowboyHandHold.bounds = cowboyHat.bounds;
        cowboyHandHold.position = CGPointMake(110, 42);
        [cowboyHat addSublayer:cowboyHandHold];

        
        CAKeyframeAnimation *cowboyHandHoldAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
        cowboyHandHoldAnim.duration = 5.0f;
        cowboyHandHoldAnim.repeatCount = HUGE_VALF;
        //cowboyHatTipAnim.calculationMode = kCAAnimationPaced;
        cowboyHandHoldAnim.removedOnCompletion = NO;
        cowboyHandHoldAnim.fillMode = kCAFillModeForwards;
        
        cowboyHandHoldAnim.values = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:125],
                                   [NSNumber numberWithFloat:0],
                                   [NSNumber numberWithFloat:0],
                                    [NSNumber numberWithFloat:125],nil] ;
        
        cowboyHandHoldAnim.keyTimes = [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0.0],
                                     [NSNumber numberWithFloat:0.1],
                                     [NSNumber numberWithFloat:0.25],
                                       [NSNumber numberWithFloat:0.35],nil] ;
        
        [cowboyHandHold addAnimation:cowboyHandHoldAnim forKey:@"transform.translation.y"];

        
        CALayer *cowboyHand = [CALayer layer];
        UIImage *cowboyHandimg = [UIImage imageNamed:@"Dude_hand.png"];
        cowboyHand.bounds = CGRectMake(0, 0, cowboyHandimg.size.width/2, cowboyHandimg.size.height/2);
        cowboyHand.anchorPoint = CGPointMake(0.5, 1);
        cowboyHand.position = CGPointMake(210, 210);
        CGImageRef cowboyHandimgRef = [cowboyHandimg CGImage];
        [cowboyHand setContents:(__bridge id) cowboyHandimgRef];
        [cowboyHandHold addSublayer:cowboyHand];
        
        CAKeyframeAnimation *cowboyHandAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        cowboyHandAnim.duration = 5.0f;
        cowboyHandAnim.repeatCount = HUGE_VALF;
        //cowboyHatTipAnim.calculationMode = kCAAnimationPaced;
        cowboyHandAnim.removedOnCompletion = NO;
        cowboyHandAnim.fillMode = kCAFillModeForwards;
        
        cowboyHandAnim.values = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0.15 * M_PI],
                                   [NSNumber numberWithFloat: 0 * M_PI],
                                 [NSNumber numberWithFloat: 0 * M_PI],
                                   [NSNumber numberWithFloat:0.15 * M_PI], nil] ;
        
        cowboyHandAnim.keyTimes = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0.0],
                                   [NSNumber numberWithFloat:0.1],
                                   [NSNumber numberWithFloat:0.25],
                                   [NSNumber numberWithFloat:0.35],nil] ;
        
        [cowboyHand addAnimation:cowboyHandAnim forKey:@"transform.rotation.z"];
        
        
    }
    //-->cactus bird animation
    {
        CGSize fixedSize = CGSizeMake(264, 253);
        CGImageRef cactusbirdimg = [[UIImage imageNamed:@"cactusbird"] CGImage];
        MCSpriteLayer* cactusbird = [MCSpriteLayer layerWithImage:cactusbirdimg sampleSize:fixedSize];
        cactusbird.position = CGPointMake(10444, 86);
        cactusbird.name = @"That is a bird on a cactus. Henceforth I will call it Cactusbird.";
        
        CAKeyframeAnimation *cactusbirdAnimation = [CAKeyframeAnimation animationWithKeyPath:@"sampleIndex"];
        cactusbirdAnimation.duration = 5.0f;
        //cactusbirdAnimation.autoreverses = YES;
        cactusbirdAnimation.repeatCount = HUGE_VALF;
        cactusbirdAnimation.calculationMode = kCAAnimationDiscrete;
        cactusbirdAnimation.removedOnCompletion = NO;
        cactusbirdAnimation.fillMode = kCAFillModeForwards;
        
        cactusbirdAnimation.values = [NSArray arrayWithObjects:
                                [NSNumber numberWithInt:1],
                                [NSNumber numberWithInt:2],
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:2],
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:4],
                                [NSNumber numberWithInt:1],
                                [NSNumber numberWithInt:1],nil]; //not called
        
        cactusbirdAnimation.keyTimes = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.0],
                                  [NSNumber numberWithFloat:0.1],
                                  [NSNumber numberWithFloat:0.12],
                                  [NSNumber numberWithFloat:0.14],
                                  [NSNumber numberWithFloat:0.16],
                                  [NSNumber numberWithFloat:0.2],
                                  [NSNumber numberWithFloat:0.35],
                                  [NSNumber numberWithFloat:0], nil]; //not called
        
        [cactusbird addAnimation:cactusbirdAnimation forKey:@"cactusbird"];
        [map4CA addSublayer:cactusbird];
        
    }
    //-->progress bar animation
    {
        blackPanel = [CALayer layer];
        [blackPanel setBounds:CGRectMake(0, 0, 340, screenSize.height)];
        [blackPanel setPosition:CGPointMake(screenSize.width - 200, screenSize.height/2)];
        blackPanel.backgroundColor = [UIColor blackColor].CGColor;
        blackPanel.zPosition = 3;
        blackPanel.name = @"blackpanel";
        [mapCAView.layer addSublayer:blackPanel];
        
        CALayer *blackPanelExtension = [CALayer layer];
        [blackPanelExtension setFrame:CGRectMake(blackPanel.bounds.size.width, 0, 400, screenSize.height)];
        blackPanelExtension.backgroundColor  = [UIColor blackColor].CGColor;
        [blackPanel addSublayer:blackPanelExtension];
        
        //the colors for the gradient.  highColor is at the right, lowColor as at the left
        UIColor * highColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        UIColor * lowColor = [UIColor colorWithRed:.4 green:.1 blue:.1 alpha:0];
        
        CAGradientLayer * gradient = [CAGradientLayer layer];
        [gradient setFrame:CGRectMake(0, 0, 680, blackPanel.bounds.size.height)];
        [gradient setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil]];
        [gradient setStartPoint:CGPointMake(1, .5)];
        [gradient setEndPoint:CGPointMake(0, .5)];
        
        CALayer * roundRect = [CALayer layer];
        [roundRect setFrame:gradient.frame];
        [roundRect setPosition:CGPointMake(blackPanel.bounds.size.width - roundRect.frame.size.width, roundRect.frame.size.height/2)];
        [roundRect setMasksToBounds:YES];
        [roundRect addSublayer:gradient];
        [blackPanel addSublayer:roundRect];
        
        CGSize fixedSize = CGSizeMake(619, 152);
        CGImageRef eyesImage = [[UIImage imageNamed:@"eyeBlink"] CGImage];
        MCSpriteLayer *eyesSprite = [MCSpriteLayer layerWithImage:eyesImage sampleSize:fixedSize];
        eyesSprite.position = CGPointMake(blackPanel.bounds.size.width/2.5, blackPanel.bounds.size.height/2);
        eyesSprite.name = @"eyesSprite";
    
        CAKeyframeAnimation *eyesAnimation = [CAKeyframeAnimation animationWithKeyPath:@"sampleIndex"];
        eyesAnimation.duration = 3.0f;
        eyesAnimation.repeatCount = HUGE_VALF;
        eyesAnimation.calculationMode = kCAAnimationDiscrete;
        eyesAnimation.removedOnCompletion = NO;
        eyesAnimation.fillMode = kCAFillModeForwards;
        
        eyesAnimation.values = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:1],
                            [NSNumber numberWithInt:2],
                            [NSNumber numberWithInt:3],
                            [NSNumber numberWithInt:5], 
                            [NSNumber numberWithInt:4], 
                            [NSNumber numberWithInt:1], 
                            [NSNumber numberWithInt:1],nil]; //not called
        
        eyesAnimation.keyTimes = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.0], 
                              [NSNumber numberWithFloat:0.1], 
                              [NSNumber numberWithFloat:0.12], 
                              [NSNumber numberWithFloat:0.18], 
                              [NSNumber numberWithFloat:0.3], 
                              [NSNumber numberWithFloat:.4],
                              [NSNumber numberWithFloat:0], nil]; //not called 
        
        [eyesSprite addAnimation:eyesAnimation forKey:@"eyeBlink"];
        [blackPanel addSublayer:eyesSprite];
        
        float padding = 10.0;
        progressBar = [CALayer layer];
        UIImage *progBarimg = [UIImage imageNamed:@"map_progress_all_ON.jpg"];
        progressBar.bounds = CGRectMake(0, 0, progBarimg.size.width, progBarimg.size.height);
        [progressBar setPosition:CGPointMake(eyesSprite.position.x - padding/2, eyesSprite.position.y * 1.6)];
        CGImageRef progCGImage = [progBarimg CGImage];
        [progressBar setContents:(__bridge id)progCGImage];
        [blackPanel addSublayer:progressBar];
        
        progressBarEmpty = [CALayer layer];
        [progressBarEmpty setAnchorPoint:CGPointMake(1.0, 1.0)];
        progressBarEmpty.position = CGPointMake(progressBar.bounds.size.width, progressBar.bounds.size.height);
        [progressBarEmpty setContents:(__bridge id)[[UIImage imageNamed:@"map_progress_all_OFF.jpg"] CGImage]];
        [progressBar addSublayer:progressBarEmpty];
        
        progressLabel = [[CATextLayer alloc] init];
        [progressLabel setFont:@"rockwell"];
        [progressLabel setFontSize:17];
        [progressLabel setFrame:CGRectMake(0, 0, progressBar.bounds.size.width, progressBar.bounds.size.height/2)];
        [progressLabel setPosition:CGPointMake(progressBar.bounds.size.width/2, progressBar.bounds.size.height + padding)];
        [progressLabel setAlignmentMode:kCAAlignmentCenter];
        [progressLabel setForegroundColor:[[UIColor grayColor] CGColor]];
        [progressBarEmpty addSublayer:progressLabel];
        
        
        
        
    }
    //-->bird animation
    {
        CGSize fixedSize = CGSizeMake(116, 74);
        CGImageRef birdImage = [[UIImage imageNamed:@"bird"] CGImage];
        MCSpriteLayer* birdSprite = [MCSpriteLayer layerWithImage:birdImage sampleSize:fixedSize];
        birdSprite.position = CGPointMake(675*2, scrollView.contentSize.height/6);
        birdSprite.name = @"Vultures can smell death from 5 miles away. Or a day early.";
        
        CABasicAnimation *birdAnimation = [CABasicAnimation animationWithKeyPath:@"sampleIndex"];
        birdAnimation.fromValue = [NSNumber numberWithInt:1];
        birdAnimation.toValue = [NSNumber numberWithInt:15];
        birdAnimation.duration = 2.0f;
        birdAnimation.repeatCount = HUGE_VALF;
        birdAnimation.removedOnCompletion = NO;
        
        [birdSprite addAnimation:birdAnimation forKey:@"birdCircle"];
        [map1BCA addSublayer:birdSprite];
        //[(CALayer*)[parallaxLayers objectAtIndex:1] addSublayer:birdSprite];
    }
    //-->riverWaves animation
    {
        CGSize fixedSize = CGSizeMake(924, 240);
        CGImageRef riverImage = [[UIImage imageNamed:@"riverWaves"] CGImage];
        MCSpriteLayer* riverSprite = [MCSpriteLayer layerWithImage:riverImage sampleSize:fixedSize];
        riverSprite.position = CGPointMake(640*4 + 423, scrollView.contentSize.height/2 +3);
        riverSprite.name = @"What's with those skanks always prancing in the river?";
        
        CABasicAnimation *riverAnimation = [CABasicAnimation animationWithKeyPath:@"sampleIndex"];
        riverAnimation.fromValue = [NSNumber numberWithInt:1];
        riverAnimation.toValue = [NSNumber numberWithInt:3];
        riverAnimation.duration = 1.4f;
        riverAnimation.repeatCount = HUGE_VALF;
        riverAnimation.removedOnCompletion = NO;
        
        [riverSprite addAnimation:riverAnimation forKey:@"riverWaves"];
        [map1CA addSublayer:riverSprite];
    }
    //-->deer eyes animation
    {
        CALayer *deereyes = [CALayer layer];
        UIImage *deereyesimg = [UIImage imageNamed:@"deer_eyes.png"];
        deereyes.bounds = CGRectMake(0, 0, deereyesimg.size.width/2, deereyesimg.size.height/2);
        deereyes.position = CGPointMake(3535, 177);
        CGImageRef deereyesimgref = [deereyesimg CGImage];
        [deereyes setContents:(__bridge id)deereyesimgref];
        [map1CA addSublayer:deereyes];
        
        CAKeyframeAnimation *deereyesAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        deereyesAnimation.duration = 5.0f;
        deereyesAnimation.repeatCount = HUGE_VALF;
        deereyesAnimation.calculationMode = kCAAnimationDiscrete;
        deereyesAnimation.removedOnCompletion = NO;
        deereyesAnimation.fillMode = kCAFillModeForwards;
        
        deereyesAnimation.values = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:1.0],
                                [NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.0],nil]; //not called
        
        deereyesAnimation.keyTimes = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.0],
                                  [NSNumber numberWithFloat:0.2],
                                [NSNumber numberWithFloat:0.2], nil]; //not called
        
        [deereyes addAnimation:deereyesAnimation forKey:@"deereyeBlink"];
        
        //double hit area of eyes
        CALayer *deerEyesHitArea = [CALayer layer];
        deerEyesHitArea.frame = CGRectMake(deereyes.frame.origin.x, deereyes.frame.origin.y, deereyes.frame.size.width*3, deereyes.frame.size.height*3);
        deerEyesHitArea.name = @"I live in a world where bones have eyes. I'm hungry now.";
        [map1CA addSublayer:deerEyesHitArea];



    }
    //-->pumpjacks animations
    {
        CALayer *pumpjackFloor = [CALayer layer];
        pumpjackFloor.bounds = CGRectMake(0, 0, 30, 5);
        pumpjackFloor.position = CGPointMake(4100, 118);
        [map1CA addSublayer:pumpjackFloor];
        
        CALayer *pumpjackBase = [CALayer layer];
        UIImage *pumpjackBaseimg = [UIImage imageNamed:@"[L3]-base_A.png"];
        pumpjackBase.bounds = CGRectMake(0, 0, pumpjackBaseimg.size.width/2, pumpjackBaseimg.size.height/2);
        //pumpjackBase.position = CGPointMake(4100, 118);
        CGImageRef pumpjackBaseimgref = [pumpjackBaseimg CGImage];
        [pumpjackBase setContents:(__bridge id)pumpjackBaseimgref];
        [pumpjackFloor addSublayer:pumpjackBase];
        
        CALayer *pumpjackTapline = [CALayer layer];
        UIImage *pumpjackTaplineimg = [UIImage imageNamed:@"[L4]-tapline_A.png"];
        pumpjackTapline.bounds = CGRectMake(0, 0, pumpjackTaplineimg.size.width/2, pumpjackTaplineimg.size.height/2);
        pumpjackTapline.position = CGPointMake(209, 36);
        CGImageRef pumpjackTaplineimgref = [pumpjackTaplineimg CGImage];
        [pumpjackTapline setContents:(__bridge id)pumpjackTaplineimgref];
        [pumpjackBase addSublayer:pumpjackTapline];
        
        CAKeyframeAnimation *pumpjackTaplineAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
        pumpjackTaplineAnim.duration = 2.5f;
        pumpjackTaplineAnim.repeatCount = HUGE_VALF;
        pumpjackTaplineAnim.calculationMode = kCAAnimationPaced;
        pumpjackTaplineAnim.autoreverses = YES;
        pumpjackTaplineAnim.removedOnCompletion = NO;
        pumpjackTaplineAnim.fillMode = kCAFillModeForwards;
        
        pumpjackTaplineAnim.values = [NSArray arrayWithObjects:
                                      [NSNumber numberWithInt:10],
                                      [NSNumber numberWithInt:0],
                                       nil] ;
        
        pumpjackTaplineAnim.keyTimes = [NSArray arrayWithObjects:
                                        [NSNumber numberWithFloat:0.0],
                                        [NSNumber numberWithFloat:0.5],
                                        nil] ;
        
        pumpjackTaplineAnim.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        [pumpjackTapline addAnimation:pumpjackTaplineAnim forKey:@"transform.translation.y"];
        
        CALayer *pumpjackHandle = [CALayer layer];
        UIImage *pumpjackHandleimg = [UIImage imageNamed:@"[L2]-handle_knex_A.png"];
        pumpjackHandle.bounds = CGRectMake(0, 0, pumpjackHandleimg.size.width/2, pumpjackHandleimg.size.height/2);
        pumpjackHandle.position = CGPointMake(-27, -23);
        CGImageRef pumpjackHandleimgref = [pumpjackHandleimg CGImage];
        [pumpjackHandle setContents:(__bridge id)pumpjackHandleimgref];
        [pumpjackFloor insertSublayer:pumpjackHandle atIndex:0];
        
        CAKeyframeAnimation *pumpjackHandleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
        pumpjackHandleAnim.duration = 2.5f;
        pumpjackHandleAnim.repeatCount = HUGE_VALF;
        pumpjackHandleAnim.calculationMode = kCAAnimationPaced;
        pumpjackHandleAnim.autoreverses = YES;
        pumpjackHandleAnim.removedOnCompletion = NO;
        pumpjackHandleAnim.fillMode = kCAFillModeForwards;
        
        pumpjackHandleAnim.values = [NSArray arrayWithObjects:
                                     [NSNumber numberWithInt:0],
                                     [NSNumber numberWithInt:15],
                                     nil] ;
        
        pumpjackHandleAnim.keyTimes = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0],
                                       [NSNumber numberWithFloat:0.5],
                                       nil] ;
        
        pumpjackHandleAnim.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        [pumpjackHandle addAnimation:pumpjackHandleAnim forKey:nil];

        
        CALayer *pumpjackHammer = [CALayer layer];
        UIImage *pumpjackHammerimg = [UIImage imageNamed:@"[L7]-hammer_A.png"];
        pumpjackHammer.bounds = CGRectMake(0, 0, pumpjackHammerimg.size.width/2, pumpjackHammerimg.size.height/2);
        pumpjackHammer.anchorPoint = CGPointMake(0.5, 0.5);
        pumpjackHammer.position = CGPointMake(145, 6);
        CGImageRef pumpjackHammerimgref = [pumpjackHammerimg CGImage];
        [pumpjackHammer setContents:(__bridge id)pumpjackHammerimgref];
        [pumpjackBase addSublayer:pumpjackHammer];
        
        CAKeyframeAnimation *pumpjackHammerAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        pumpjackHammerAnim.duration = 2.5f;
        pumpjackHammerAnim.repeatCount = HUGE_VALF;
        pumpjackHammerAnim.calculationMode = kCAAnimationPaced;
        pumpjackHammerAnim.autoreverses = YES;
        pumpjackHammerAnim.removedOnCompletion = NO;
        pumpjackHammerAnim.fillMode = kCAFillModeForwards;
        
        pumpjackHammerAnim.values = [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0.0 * M_PI],
                                 [NSNumber numberWithFloat:-0.13 * M_PI],
                                  nil] ;
        
        pumpjackHammerAnim.keyTimes = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0],
                                   [NSNumber numberWithFloat:0.5],
                                   nil] ;
        
        pumpjackHammerAnim.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        [pumpjackHammer addAnimation:pumpjackHammerAnim forKey:@"transform.rotation.z"];
        
        CALayer *pumpjackProp2 = [CALayer layer];
        UIImage *pumpjackProp2img = [UIImage imageNamed:@"[L1]-propeller2_A.png"];
        pumpjackProp2.bounds = CGRectMake(0, 0, pumpjackProp2img.size.width/2, pumpjackProp2img.size.height/2);
        pumpjackProp2.position = CGPointMake(-32, 10);
        CGImageRef pumpjackProp2imgref = [pumpjackProp2img CGImage];
        [pumpjackProp2 setContents:(__bridge id)pumpjackProp2imgref];
        [pumpjackFloor insertSublayer:pumpjackProp2 atIndex:0];
        
        CAKeyframeAnimation *pumpjackProp2Anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        pumpjackProp2Anim.duration = 5.0f;
        pumpjackProp2Anim.repeatCount = HUGE_VALF;
        pumpjackProp2Anim.calculationMode = kCAAnimationPaced;
        pumpjackProp2Anim.removedOnCompletion = NO;
        pumpjackProp2Anim.fillMode = kCAFillModeForwards;
        
        pumpjackProp2Anim.values = [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0.0 * M_PI],
                                     [NSNumber numberWithFloat:-1 * M_PI],
                                    [NSNumber numberWithFloat:-2 * M_PI],
                                     nil] ;
        
        pumpjackProp2Anim.keyTimes = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0],
                                       [NSNumber numberWithFloat:0.5],
                                      [NSNumber numberWithFloat:1.0],
                                       nil] ;
        
        [pumpjackProp2 addAnimation:pumpjackProp2Anim forKey:@"transform.rotation.z"];
        
        CALayer *pumpjackProp1 = [CALayer layer];
        UIImage *pumpjackProp1img = [UIImage imageNamed:@"[L5]-propeller1_A.png"];
        pumpjackProp1.bounds = CGRectMake(0, 0, pumpjackProp1img.size.width/2, pumpjackProp1img.size.height/2);
        pumpjackProp1.position = CGPointMake(93, 65);
        CGImageRef pumpjackProp1imgref = [pumpjackProp1img CGImage];
        [pumpjackProp1 setContents:(__bridge id)pumpjackProp1imgref];
        [pumpjackBase addSublayer:pumpjackProp1];
        
        CAKeyframeAnimation *pumpjackProp1Anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        pumpjackProp1Anim.duration = 5.0f;
        pumpjackProp1Anim.repeatCount = HUGE_VALF;
        pumpjackProp1Anim.calculationMode = kCAAnimationPaced;
        pumpjackProp1Anim.removedOnCompletion = NO;
        pumpjackProp1Anim.fillMode = kCAFillModeForwards;
        
        pumpjackProp1Anim.values = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0 * M_PI],
                                    [NSNumber numberWithFloat:-1 * M_PI],
                                    [NSNumber numberWithFloat:-2 * M_PI],
                                    nil] ;
        
        pumpjackProp1Anim.keyTimes = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0.0],
                                      [NSNumber numberWithFloat:0.5],
                                      [NSNumber numberWithFloat:1.0],
                                      nil] ;
        
        [pumpjackProp1 addAnimation:pumpjackProp1Anim forKey:@"transform.rotation.z"];
        
        CALayer *pumpjackBox = [CALayer layer];
        UIImage *pumpjackBoximg = [UIImage imageNamed:@"[L6]-box_A.png"];
        pumpjackBox.bounds = CGRectMake(0, 0, pumpjackBoximg.size.width/2, pumpjackBoximg.size.height/2);
        pumpjackBox.position = CGPointMake(93, 65);
        CGImageRef pumpjackBoximgref = [pumpjackBoximg CGImage];
        [pumpjackBox setContents:(__bridge id)pumpjackBoximgref];
        [pumpjackBase addSublayer:pumpjackBox];
        
        //--> second one
        
        CALayer *pumpjackFloor2 = [CALayer layer];
        pumpjackFloor2.bounds = CGRectMake(0, 0, 30, 5);
        pumpjackFloor2.position = CGPointMake(3920, 92);
        [map1CA addSublayer:pumpjackFloor2];
        
        CALayer *pumpjackBase2 = [CALayer layer];
        UIImage *pumpjackBase2img = [UIImage imageNamed:@"[L3]-base_A.png"];
        pumpjackBase2.bounds = CGRectMake(0, 0, pumpjackBase2img.size.width/3, pumpjackBase2img.size.height/3);
        CGImageRef pumpjackBase2imgref = [pumpjackBase2img CGImage];
        [pumpjackBase2 setContents:(__bridge id)pumpjackBase2imgref];
        [pumpjackFloor2 addSublayer:pumpjackBase2];
        
        CALayer *pumpjackTapline2 = [CALayer layer];
        UIImage *pumpjackTapline2img = [UIImage imageNamed:@"[L4]-tapline_A.png"];
        pumpjackTapline2.bounds = CGRectMake(0, 0, pumpjackTapline2img.size.width/3, pumpjackTapline2img.size.height/3);
        pumpjackTapline2.position = CGPointMake(139, 25);
        CGImageRef pumpjackTapline2imgref = [pumpjackTapline2img CGImage];
        [pumpjackTapline2 setContents:(__bridge id)pumpjackTapline2imgref];
        [pumpjackBase2 addSublayer:pumpjackTapline2];
        
        CAKeyframeAnimation *pumpjackTapline2Anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
        pumpjackTapline2Anim.duration = 2.5f;
        pumpjackTapline2Anim.repeatCount = HUGE_VALF;
        pumpjackTapline2Anim.calculationMode = kCAAnimationPaced;
        pumpjackTapline2Anim.autoreverses = YES;
        pumpjackTapline2Anim.removedOnCompletion = NO;
        pumpjackTapline2Anim.fillMode = kCAFillModeForwards;
        
        pumpjackTapline2Anim.values = [NSArray arrayWithObjects:
                                      [NSNumber numberWithInt:7],
                                      [NSNumber numberWithInt:0],
                                      nil] ;
        
        pumpjackTapline2Anim.keyTimes = [NSArray arrayWithObjects:
                                        [NSNumber numberWithFloat:0.0],
                                        [NSNumber numberWithFloat:0.5],
                                        nil] ;
        
        pumpjackTapline2Anim.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        [pumpjackTapline2 addAnimation:pumpjackTapline2Anim forKey:@"transform.translation.y"];
        
        CALayer *pumpjackHandle2 = [CALayer layer];
        UIImage *pumpjackHandle2img = [UIImage imageNamed:@"[L2]-handle_knex_A.png"];
        pumpjackHandle2.bounds = CGRectMake(0, 0, pumpjackHandle2img.size.width/3, pumpjackHandle2img.size.height/3);
        pumpjackHandle2.position = CGPointMake(-18, -19);
        CGImageRef pumpjackHandle2imgref = [pumpjackHandle2img CGImage];
        [pumpjackHandle2 setContents:(__bridge id)pumpjackHandle2imgref];
        [pumpjackFloor2 insertSublayer:pumpjackHandle2 atIndex:0];
        
        CAKeyframeAnimation *pumpjackHandle2Anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
        pumpjackHandle2Anim.duration = 2.5f;
        pumpjackHandle2Anim.repeatCount = HUGE_VALF;
        pumpjackHandle2Anim.calculationMode = kCAAnimationPaced;
        pumpjackHandle2Anim.autoreverses = YES;
        pumpjackHandle2Anim.removedOnCompletion = NO;
        pumpjackHandle2Anim.fillMode = kCAFillModeForwards;
        
        pumpjackHandle2Anim.values = [NSArray arrayWithObjects:
                                     [NSNumber numberWithInt:0],
                                     [NSNumber numberWithInt:10],
                                     nil] ;
        
        pumpjackHandle2Anim.keyTimes = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0],
                                       [NSNumber numberWithFloat:0.5],
                                       nil] ;
        
        pumpjackHandle2Anim.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        [pumpjackHandle2 addAnimation:pumpjackHandle2Anim forKey:nil];
        
        
        CALayer *pumpjackHammer2 = [CALayer layer];
        UIImage *pumpjackHammer2img = [UIImage imageNamed:@"[L7]-hammer_A.png"];
        pumpjackHammer2.bounds = CGRectMake(0, 0, pumpjackHammer2img.size.width/3, pumpjackHammer2img.size.height/3);
        pumpjackHammer2.anchorPoint = CGPointMake(0.5, 0.5);
        pumpjackHammer2.position = CGPointMake(97, 4);
        CGImageRef pumpjackHammer2imgref = [pumpjackHammer2img CGImage];
        [pumpjackHammer2 setContents:(__bridge id)pumpjackHammer2imgref];
        [pumpjackBase2 addSublayer:pumpjackHammer2];
        
        CAKeyframeAnimation *pumpjackHammer2Anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        pumpjackHammer2Anim.duration = 2.5f;
        pumpjackHammer2Anim.repeatCount = HUGE_VALF;
        pumpjackHammer2Anim.calculationMode = kCAAnimationPaced;
        pumpjackHammer2Anim.autoreverses = YES;
        pumpjackHammer2Anim.removedOnCompletion = NO;
        pumpjackHammer2Anim.fillMode = kCAFillModeForwards;
        
        pumpjackHammer2Anim.values = [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0.0 * M_PI],
                                     [NSNumber numberWithFloat:-0.09 * M_PI],
                                     nil] ;
        
        pumpjackHammer2Anim.keyTimes = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0],
                                       [NSNumber numberWithFloat:0.5],
                                       nil] ;
        
        pumpjackHammer2Anim.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        [pumpjackHammer2 addAnimation:pumpjackHammer2Anim forKey:@"transform.rotation.z"];
        
        CALayer *pumpjack2Prop2 = [CALayer layer];
        UIImage *pumpjack2Prop2img = [UIImage imageNamed:@"[L1]-propeller2_A.png"];
        pumpjack2Prop2.bounds = CGRectMake(0, 0, pumpjack2Prop2img.size.width/3, pumpjack2Prop2img.size.height/3);
        pumpjack2Prop2.position = CGPointMake(-19, 7);
        CGImageRef pumpjack2Prop2imgref = [pumpjack2Prop2img CGImage];
        [pumpjack2Prop2 setContents:(__bridge id)pumpjack2Prop2imgref];
        [pumpjackFloor2 insertSublayer:pumpjack2Prop2 atIndex:0];
        
        CAKeyframeAnimation *pumpjack2Prop2Anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        pumpjack2Prop2Anim.duration = 5.0f;
        pumpjack2Prop2Anim.repeatCount = HUGE_VALF;
        pumpjack2Prop2Anim.calculationMode = kCAAnimationPaced;
        pumpjack2Prop2Anim.removedOnCompletion = NO;
        pumpjack2Prop2Anim.fillMode = kCAFillModeForwards;
        
        pumpjack2Prop2Anim.values = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0 * M_PI],
                                    [NSNumber numberWithFloat:-1 * M_PI],
                                    [NSNumber numberWithFloat:-2 * M_PI],
                                    nil] ;
        
        pumpjack2Prop2Anim.keyTimes = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0.0],
                                      [NSNumber numberWithFloat:0.5],
                                      [NSNumber numberWithFloat:1.0],
                                      nil] ;
        
        [pumpjack2Prop2 addAnimation:pumpjack2Prop2Anim forKey:@"transform.rotation.z"];
        
        CALayer *pumpjack2Prop1 = [CALayer layer];
        UIImage *pumpjack2Prop1img = [UIImage imageNamed:@"[L5]-propeller1_A.png"];
        pumpjack2Prop1.bounds = CGRectMake(0, 0, pumpjack2Prop1img.size.width/3, pumpjack2Prop1img.size.height/3);
        pumpjack2Prop1.position = CGPointMake(63, 42);
        CGImageRef pumpjack2Prop1imgref = [pumpjack2Prop1img CGImage];
        [pumpjack2Prop1 setContents:(__bridge id)pumpjack2Prop1imgref];
        [pumpjackBase2 addSublayer:pumpjack2Prop1];
        
        CAKeyframeAnimation *pumpjack2Prop1Anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        pumpjack2Prop1Anim.duration = 5.0f;
        pumpjack2Prop1Anim.repeatCount = HUGE_VALF;
        pumpjack2Prop1Anim.calculationMode = kCAAnimationPaced;
        pumpjack2Prop1Anim.removedOnCompletion = NO;
        pumpjack2Prop1Anim.fillMode = kCAFillModeForwards;
        
        pumpjack2Prop1Anim.values = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0 * M_PI],
                                    [NSNumber numberWithFloat:-1 * M_PI],
                                    [NSNumber numberWithFloat:-2 * M_PI],
                                    nil] ;
        
        pumpjack2Prop1Anim.keyTimes = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0.0],
                                      [NSNumber numberWithFloat:0.5],
                                      [NSNumber numberWithFloat:1.0],
                                      nil] ;
        
        [pumpjack2Prop1 addAnimation:pumpjack2Prop1Anim forKey:@"transform.rotation.z"];
        
        CALayer *pumpjackBox2 = [CALayer layer];
        UIImage *pumpjackBox2img = [UIImage imageNamed:@"[L6]-box_A.png"];
        pumpjackBox2.bounds = CGRectMake(0, 0, pumpjackBox2img.size.width/3, pumpjackBox2img.size.height/3);
        pumpjackBox2.position = CGPointMake(62, 43);
        CGImageRef pumpjackBox2imgref = [pumpjackBox2img CGImage];
        [pumpjackBox2 setContents:(__bridge id)pumpjackBox2imgref];
        [pumpjackBase2 addSublayer:pumpjackBox2];
        
    }
    //-->saloon animation
    {
        CALayer *saloonbase = [CALayer layer];
        UIImage *saloonimg = [UIImage imageNamed:@"saloon_base"];
        saloonbase.bounds = CGRectMake(0, 0, floorf(saloonimg.size.width/2), floorf(saloonimg.size.height/2));
        saloonbase.position = CGPointMake(2150, 125);
        saloonbase.name = @"The only place to quench your thirst in this town.";
        [map2CA addSublayer:saloonbase];
        
        CALayer *saloon = [CALayer layer];
        saloon.bounds = saloonbase.bounds;
        saloon.anchorPoint = CGPointMake(1, 0);
        saloon.position = CGPointMake(580, 0);
        [saloon setContents:(__bridge id)[saloonimg CGImage]];
        [saloonbase addSublayer:saloon];
        
        CALayer *saloonDrunkArm = [CALayer layer];
        UIImage *saloonDrunkArmimg = [UIImage imageNamed:@"saloon_drunkARM"];
        saloonDrunkArm.bounds = CGRectMake(0, 0, saloonDrunkArmimg.size.width/2, saloonDrunkArmimg.size.height/2);
        saloonDrunkArm.anchorPoint = CGPointMake(0.5, .5);
        saloonDrunkArm.position = CGPointMake(158, 205);
        CGImageRef saloonDrunkArmimgRef = [saloonDrunkArmimg CGImage];
        [saloonDrunkArm setContents:(__bridge id) saloonDrunkArmimgRef];
        [saloon addSublayer:saloonDrunkArm];
        
        CAKeyframeAnimation *saloonDrunkArmAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        saloonDrunkArmAnim.duration = 5.0f;
        saloonDrunkArmAnim.repeatCount = HUGE_VALF;
        //cowboyHatTipAnim.calculationMode = kCAAnimationPaced;
        saloonDrunkArmAnim.removedOnCompletion = NO;
        saloonDrunkArmAnim.fillMode = kCAFillModeForwards;
        
        saloonDrunkArmAnim.values = [NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat: 0 * M_PI],
                                 [NSNumber numberWithFloat: -0.30 * M_PI],
                                 [NSNumber numberWithFloat: -0.34 * M_PI],
                                 [NSNumber numberWithFloat: 0 * M_PI], nil] ;
        
        saloonDrunkArmAnim.keyTimes = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0.0],
                                   [NSNumber numberWithFloat:0.1],
                                   [NSNumber numberWithFloat:0.25],
                                   [NSNumber numberWithFloat:0.35],nil] ;
        
        [saloonDrunkArm addAnimation:saloonDrunkArmAnim forKey:@"transform.rotation.z"];
        
        CALayer *saloonSkullEyes = [CALayer layer];
        UIImage *saloonSkullEyesimg = [UIImage imageNamed:@"saloon_skull-eyes"];
        saloonSkullEyes.bounds = CGRectMake(0, 0, saloonSkullEyesimg.size.width/2, saloonSkullEyesimg.size.height/2);
        saloonSkullEyes.position = CGPointMake(248, 28);
        [saloonSkullEyes setContents:(__bridge id) [saloonSkullEyesimg CGImage]];
        [saloon addSublayer:saloonSkullEyes];
        
        CABasicAnimation *saloonSkullEyesAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        saloonSkullEyesAnim.fromValue = [NSNumber numberWithFloat:.3];
        saloonSkullEyesAnim.toValue = [NSNumber numberWithFloat: 1.0];
        saloonSkullEyesAnim.duration = 0.5f;
        saloonSkullEyesAnim.autoreverses = YES;
        saloonSkullEyesAnim.repeatCount = HUGE_VALF;
        saloonSkullEyesAnim.removedOnCompletion = NO;
        [saloonSkullEyes addAnimation:saloonSkullEyesAnim forKey:@"opacity"];

    }
    //-->CALayer name adds-ons
    {
        //welcome sign
        CALayer *welcomesign = [CALayer layer];
        [welcomesign setFrame:CGRectMake(135, 50, 210, 185)];
        //welcomesign.backgroundColor = [UIColor blackColor].CGColor;
        welcomesign.name = @"Welcome! Go play!";
        [map1CA addSublayer:welcomesign];
        
        //graveyard
        CALayer *graveyard = [CALayer layer];
        [graveyard setFrame:CGRectMake(4380, 50, 350, 185)];
        //graveyard.backgroundColor = [UIColor blackColor].CGColor;
        graveyard.name = @"That's a lotta tombstones. That's what you get for drinking the oil.";
        [map1CA addSublayer:graveyard];
    }
    
    [self renderScreen:[[NSUserDefaults standardUserDefaults] boolForKey:@"walkingForward"]:FALSE :TRUE];
    
    [CATransaction commit];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadAvatarPosition];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameSavetNotif:)
                                                 name:@"gameSave" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameSavetNotif:)
                                                 name:@"loggedIn" object:nil];
    [self gameState];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [self saveAvatarPosition];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end

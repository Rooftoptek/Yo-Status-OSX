//
//  YSLoginViewController.m
//  Yo Status
//
//  Created by Emmanuel Merali on 20/01/2016.
//  Copyright © 2016 rooftoptek.com. All rights reserved.
//

#import "YSLoginViewController.h"
#import <WebKit/WebKit.h>

@interface YSLoginViewController ()

@property (weak) IBOutlet WebView                           *webView;
@property (weak) IBOutlet NSLayoutConstraint                *webViewTopConstraint;
@property (weak) IBOutlet NSCollectionView                  *collectionView;
@property (nonatomic, strong) NSMutableArray                *emojis;
@property (nonatomic, strong) NSIndexSet                    *selectedIndexes;
@property (nonatomic, assign) NSUInteger                    selectedIndex;

@end

@interface YSLoginViewController (Private)

- (void)requestLoginIfNeeded;
- (void)changeYoStatusWithIndex:(NSUInteger)index;

@end


@implementation YSLoginViewController (Private)

- (void)requestLoginIfNeeded {
    BOOL isLoggedIn = [[YSOAuth2 sharedInstance] isLoggedIn];
    self.webViewTopConstraint.constant = isLoggedIn ? self.view.frame.size.height : 0;
    if (!isLoggedIn) {
        [[YSOAuth2 sharedInstance] requestAccessInWebView:self.webView];
    }
}

- (void)changeYoStatusWithIndex:(NSUInteger)index {
    NSString *emoji = [[self.emojis objectAtIndex:index] emoji];
    [[YSOAuth2 sharedInstance] changeYoStatusWithEmoji:emoji];
}

@end

@implementation YSLoginViewController

- (void)setSelectedIndexes:(NSIndexSet *)selectedIndexes {
    NSUInteger selectedIndex = [selectedIndexes firstIndex];
    if (self.selectedIndex != selectedIndex) {
        self.selectedIndex = selectedIndex;
        [self changeYoStatusWithIndex:selectedIndex];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.emojis = [NSMutableArray arrayWithArray:[YSEmoji allEmojis]];
    self.selectedIndex = -1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]
     addObserverForName:YSOAuth2ObtainedAccessNotification
     object:[YSOAuth2 sharedInstance]
     queue:nil
     usingBlock:^(NSNotification *aNotification){
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.view layoutSubtreeIfNeeded];
             [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
                 context.duration = 0.25; // you can leave this out if the default is acceptable
                 context.allowsImplicitAnimation = YES;
                 self.webViewTopConstraint.constant = self.view.frame.size.height;
                 [self.view layoutSubtreeIfNeeded];
             } completionHandler:nil];
         });
     }];
    [[NSNotificationCenter defaultCenter]
     addObserverForName:YSOAuth2DidFailToObtainAccessNotification
     object:[YSOAuth2 sharedInstance]
     queue:nil
     usingBlock:^(NSNotification *aNotification){
     }];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self requestLoginIfNeeded];
    self.collectionView.backgroundColors = @[[NSColor colorWithCalibratedRed:157.0/255.0 green:86.0/255.0 blue:179.0/255.0 alpha:1.0]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

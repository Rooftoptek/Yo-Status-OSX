//
//  AppDelegate.m
//  Yo Status
//
//  Created by Emmanuel Merali on 20/01/2016.
//  Copyright © 2016 rooftoptek.com. All rights reserved.
//

#import "AppDelegate.h"
#import "YSLoginViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem                  *statusItem;
@property (strong, nonatomic) NSPopover                     *popover;
@property (weak) IBOutlet NSWindow                          *window;

@end

@interface AppDelegate (Private)

- (void)setupYOAppOAuth;
- (void)setupMenuItem;
- (void)showPopover:(id)sender;
- (void)closePopover:(id)sender;
- (void)togglePopover:(id)sender;

@end


@implementation AppDelegate (Private)

- (void)setupYOAppOAuth {
    NSDictionary *configuration = @{YSOAuth2ConfigurationClientID: YSOAuth2ClientID,
                                    YSOAuth2ConfigurationAuthorizeURL: YSOAuth2AuthorizeURL,
                                    YSOAuth2ConfigurationRedirectURL: YSOAuth2RedirectURL,
                                    YSOAuth2ConfigurationScope: YSOAuth2Scope
                                    };
    [YSOAuth2 sharedInstance].configuration = configuration;
}

- (void)setupMenuItem {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.image = [NSImage imageNamed:@"StatusBarButtonImage"];
    [self.statusItem.button setAction:@selector(togglePopover:)];
    
    self.popover = [NSPopover new];
    self.popover.contentViewController = [[YSLoginViewController alloc] initWithNibName:@"YSLoginViewController" bundle:nil];
}

- (void)showPopover:(id)sender {
    NSStatusBarButton *button = sender;
    [self.popover showRelativeToRect:button.bounds ofView:button preferredEdge:NSMinYEdge];
}

- (void)closePopover:(id)sender {
    [self.popover performClose:sender];
}

- (void)togglePopover:(id)sender {
    if (self.popover.shown) {
        [self closePopover:sender];
    } else {
        [self showPopover:sender];
    }
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupMenuItem];
    [self setupYOAppOAuth];
}

@end

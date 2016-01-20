//
//  YSOAuth2.h
//  Yo Status
//
//  Created by Emmanuel Merali on 20/01/2016.
//  Copyright © 2016 rooftoptek.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Notifications

extern NSString * const YSOAuth2ObtainedAccessNotification;
extern NSString * const YSOAuth2DidFailToObtainAccessNotification;

#pragma mark Configuration

extern NSString * const YSOAuth2ConfigurationClientID;
extern NSString * const YSOAuth2ConfigurationAuthorizeURL;
extern NSString * const YSOAuth2ConfigurationRedirectURL;
extern NSString * const YSOAuth2ConfigurationScope;

#pragma mark Access Token

extern NSString * const YSOAuth2AccessToken;

typedef void (^YSAuthorizationURLHandler)(NSURL *preparedURL);


@interface YSOAuth2 : NSObject

@property (nonatomic, strong) NSDictionary                  *configuration;

+ (YSOAuth2 *)sharedInstance;

- (BOOL)isLoggedIn;
- (void)requestAccessInWebView:(WebView *)webView;
- (void)requestAccessInWebView:(WebView *)webView withPreparedAuthorizationURLHandler:(YSAuthorizationURLHandler)handler;
- (void)changeYoStatusWithEmoji:(NSString *)emoji;

@end

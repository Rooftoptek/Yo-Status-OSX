//
//  YSOAuth2.m
//  Yo Status
//
//  Created by Emmanuel Merali on 20/01/2016.
//  Copyright © 2016 rooftoptek.com. All rights reserved.
//

#import "YSOAuth2.h"

NSString * const YSOAuth2ObtainedAccessNotification = @"YSOAuth2ObtainedAccessNotification";
NSString * const YSOAuth2DidFailToObtainAccessNotification = @"YSOAuth2DidFailToObtainAccessNotification";

#pragma mark Configuration

NSString * const YSOAuth2ConfigurationClientID = @"YSXOAuth2ConfigurationClientID";
NSString * const YSOAuth2ConfigurationAuthorizeURL = @"YSXOAuth2ConfigurationAuthorizeURL";
NSString * const YSOAuth2ConfigurationRedirectURL = @"YSXOAuth2ConfigurationRedirectURL";
NSString * const YSOAuth2ConfigurationScope = @"YSXOAuth2ConfigurationScope";

#pragma mark Access Token

NSString * const YSOAuth2AccessToken = @"YSXOAuth2AccessToken";
NSString * const YSOAuth2AccessTokenToken = @"access_token";
NSString * const YSOAuth2AccessTokenType = @"token_type";
NSString * const YSOAuth2AccessTokenExpiresIn = @"expires_in";
NSString * const YSOAuth2AccessTokenExpiryDate = @"expiry_date";

@interface YSOAuth2 ()

@property (nonatomic, strong) NSDictionary                  *accessToken;

@end

@interface YSOAuth2 (Private)

- (NSURL *)prepareAuthorizationURL;
- (BOOL)handleRedirectURL:(NSURL *)redirectURL;
- (void)notifyObtainedAccessToken;
- (void)notifyFailedToObtainAccessToken;

@end

@interface YSOAuth2 (Keychain)

- (NSString *)keychainServiceName;
- (NSDictionary *)restoreAccessTokenFromKeychain;
- (void)storeAccessTokenInKeychain;
- (void)removeAccessTokenFromKeychain;

@end

@interface YSOAuth2 (WebFrameLoadDelegate) <WebFrameLoadDelegate>

@end


@implementation YSOAuth2 (Private)

- (void)notifyObtainedAccessToken {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:YSOAuth2ObtainedAccessNotification
     object:self];
}

- (void)notifyFailedToObtainAccessToken {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:YSOAuth2DidFailToObtainAccessNotification
     object:self];
}

- (NSURL *)prepareAuthorizationURL {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                        @"response_type": @"token",
                                        @"client_id": self.configuration[YSOAuth2ConfigurationClientID],
                                        @"redirect_uri": [self.configuration[YSOAuth2ConfigurationRedirectURL] absoluteString]}];
    NSArray *scope = self.configuration[YSOAuth2ConfigurationScope];
    NSURL *authorizeURL = self.configuration[YSOAuth2ConfigurationAuthorizeURL];
    if (scope.count > 0) {
        [parameters setObject:[scope componentsJoinedByString:@" "] forKey:@"scope"];
    }
    
    return [authorizeURL URLByAddingParameters:parameters];
}

- (BOOL)handleRedirectURL:(NSURL *)redirectURL {
    NSString *fragment = redirectURL.fragment;
    NSDictionary *accessToken = [fragment parametersFromEncodedQueryString];
    if (accessToken) {
        self.accessToken = accessToken;
        return YES;
    }
    return NO;
}

@end

@implementation YSOAuth2 (Keychain)

- (NSString *)keychainServiceName {
    NSString *appName = [[NSBundle mainBundle] bundleIdentifier];
    return [NSString stringWithFormat:@"%@::%@", appName, YSOAuth2AccessToken];
}

- (NSDictionary *)restoreAccessTokenFromKeychain {
    NSString *serviceName = [self keychainServiceName];
    
    SecKeychainItemRef item = nil;
    OSStatus err = SecKeychainFindGenericPassword(NULL,
                                                  (UInt32)strlen([serviceName UTF8String]),
                                                  [serviceName UTF8String],
                                                  0,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  &item);
    if (err != noErr) {
        NSAssert1(err == errSecItemNotFound, @"Unexpected error while fetching accounts from keychain: %d", err);
        return nil;
    }
    
    // from Advanced Mac OS X Programming, ch. 16
    UInt32 length;
    char *password;
    NSData *result = nil;
    SecKeychainAttribute attributes[8];
    SecKeychainAttributeList list;
    
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
    
    list.count = 4;
    list.attr = attributes;
    
    err = SecKeychainItemCopyContent(item, NULL, &list, &length, (void **)&password);
    if (err == noErr) {
        if (password != NULL) {
            result = [NSData dataWithBytes:password length:length];
        }
        SecKeychainItemFreeContent(&list, password);
    }
    else {
        NSLog(@"Error from SecKeychainItemCopyContent: %d", err);
        return nil;
    }
    CFRelease(item);
    return [NSKeyedUnarchiver unarchiveObjectWithData:result];
}

- (void)storeAccessTokenInKeychain {
    [self removeAccessTokenFromKeychain];
    
    NSString *serviceName = [self keychainServiceName];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.accessToken];
    
    OSStatus __attribute__((unused))err = SecKeychainAddGenericPassword(NULL,
                                                                        (UInt32)strlen([serviceName UTF8String]),
                                                                        [serviceName UTF8String],
                                                                        0,
                                                                        NULL,
                                                                        (UInt32)[data length],
                                                                        [data bytes],
                                                                        NULL);
    
    NSAssert1(err == noErr, @"Error while storing access token in keychain: %d", err);
}

- (void)removeAccessTokenFromKeychain {
    NSString *serviceName = [self keychainServiceName];
    
    SecKeychainItemRef item = nil;
    OSStatus err = SecKeychainFindGenericPassword(NULL,
                                                  (UInt32)strlen([serviceName UTF8String]),
                                                  [serviceName UTF8String],
                                                  0,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  &item);
    NSAssert1((err == noErr || err == errSecItemNotFound), @"Error while deleting accounts from keychain: %d", err);
    if (err == noErr) {
        err = SecKeychainItemDelete(item);
    }
    if (item) {
        CFRelease(item);
    }
    NSAssert1((err == noErr || err == errSecItemNotFound), @"Error while deleting accounts from keychain: %d", err);
}

@end

@implementation YSOAuth2 (WebFrameLoadDelegate)

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
    NSString *redirectURL = [(NSURL *)self.configuration[YSOAuth2ConfigurationRedirectURL] absoluteString];
    NSString *requestURL = frame.dataSource.request.URL.absoluteString;
    if ([requestURL rangeOfString:redirectURL options:NSCaseInsensitiveSearch].location != NSNotFound) {
        if ([self handleRedirectURL:[NSURL URLWithString:requestURL]]) {
            [frame stopLoading];
            [self notifyObtainedAccessToken];
        }
    }
}

@end

@implementation YSOAuth2

+ (YSOAuth2 *)sharedInstance {
    static YSOAuth2 *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [YSOAuth2 new];
    });
    return store;
}

- (id)init {
    self = [super init];
    if (self) {
        self.accessToken = [self restoreAccessTokenFromKeychain];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setConfiguration:(NSDictionary *)configuration {
    NSAssert([configuration objectForKey:YSOAuth2ConfigurationClientID], @"Missing OAuth2 client ID");
    NSAssert([configuration objectForKey:YSOAuth2ConfigurationAuthorizeURL], @"Missing OAuth2 authorize URL");
    NSAssert([configuration objectForKey:YSOAuth2ConfigurationRedirectURL], @"Missing OAuth2 redirect URL");
    _configuration = configuration;
}

- (void)setAccessToken:(NSDictionary *)accessToken {
    if (_accessToken != accessToken) {
        NSInteger expiresIn = [accessToken[YSOAuth2AccessTokenExpiresIn] integerValue];
        NSDate *expiryDate = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
        NSMutableDictionary *adjustedToken = [NSMutableDictionary dictionaryWithDictionary:accessToken];
        adjustedToken[YSOAuth2AccessTokenExpiryDate] = expiryDate;
        accessToken = [NSDictionary dictionaryWithDictionary:adjustedToken];
        [self willChangeValueForKey:@"accessToken"];
        _accessToken = accessToken;
        [self didChangeValueForKey:@"accessToken"];
        [self storeAccessTokenInKeychain];
    }
}

- (BOOL)isLoggedIn {
    if (self.accessToken) {
        NSDate *expiryDate = self.accessToken[YSOAuth2AccessTokenExpiryDate];
        if (expiryDate && [[NSDate date] compare:expiryDate] == NSOrderedAscending) {
            return YES;
        }
    }
    return NO;
}

- (void)requestAccessInWebView:(WebView *)webView {
    [self requestAccessInWebView:webView withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        [webView.mainFrame loadRequest:[NSURLRequest requestWithURL:preparedURL]];
    }];
}

- (void)requestAccessInWebView:(WebView *)webView withPreparedAuthorizationURLHandler:(YSAuthorizationURLHandler)handler {
    webView.frameLoadDelegate = self;
    NSURL *preparedURL = [self prepareAuthorizationURL];
    handler(preparedURL);
}

- (void)changeYoStatusWithEmoji:(NSString *)emoji {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      @"access_token": self.accessToken[YSOAuth2AccessTokenToken],
                                                                                      @"status": emoji}];
    NSString *postData = [NSString stringWithEncodedQueryParameters:parameters];
    NSData *data = [postData dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *requestURL = [NSURL URLWithString:@"https://api.justyo.co/status/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [[session
     uploadTaskWithRequest:request
     fromData:data
     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         // Need to give feedback to the UI, we'll use a block
         NSLog(@"data: %@, response: %@, error: %@", data, response, error);
     }] resume];
}

@end
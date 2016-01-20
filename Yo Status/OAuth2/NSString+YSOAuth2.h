//
//  NSString+YSOAuth2.h
//  Yo Status
//
//  Created by Emmanuel Merali on 20/01/2016.
//  Copyright © 2016 rooftoptek.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (YSOAuth2)

+ (NSString *)stringWithEncodedQueryParameters:(NSDictionary *)parameters;
- (NSDictionary *)parametersFromEncodedQueryString;
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

@end

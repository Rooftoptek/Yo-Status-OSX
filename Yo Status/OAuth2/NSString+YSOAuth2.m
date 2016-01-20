//
//  NSString+YSOAuth2.m
//  Yo Status
//
//  Created by Emmanuel Merali on 20/01/2016.
//  Copyright © 2016 rooftoptek.com. All rights reserved.
//

#import "NSString+YSOAuth2.h"

@implementation NSString (YSOAuth2)

+ (NSString *)stringWithEncodedQueryParameters:(NSDictionary *)parameters {
    NSMutableArray *parameterPairs = [NSMutableArray array];
    for (NSString *key in [parameters allKeys]) {
        NSString *pair = [NSString stringWithFormat:@"%@=%@", [key URLEncodedString], [[parameters objectForKey:key] URLEncodedString]];
        [parameterPairs addObject:pair];
    }
    return [parameterPairs componentsJoinedByString:@"&"];
}

- (NSDictionary *)parametersFromEncodedQueryString {
    NSArray *encodedParameterPairs = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
    
    for (NSString *encodedPair in encodedParameterPairs) {
        NSArray *encodedPairElements = [encodedPair componentsSeparatedByString:@"="];
        if (encodedPairElements.count == 2) {
            [requestParameters setValue:[[encodedPairElements objectAtIndex:1] URLDecodedString]
                                 forKey:[[encodedPairElements objectAtIndex:0] URLDecodedString]];
        }
    }
    return requestParameters;
}

#pragma mark URLEncoding

- (NSString *)URLEncodedString {
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, //Allocator
                                                                                  (__bridge CFStringRef)self, //Original String
                                                                                  NULL, //Characters to leave unescaped
                                                                                  CFSTR("!*'();:@&=+$,/?%#[]"), //Legal Characters to be escaped
                                                                                  kCFStringEncodingUTF8); //Encoding
}

- (NSString *)URLDecodedString {
    return (__bridge_transfer NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                  (__bridge CFStringRef)self,
                                                                                                  CFSTR(""),
                                                                                                  kCFStringEncodingUTF8);
}

@end

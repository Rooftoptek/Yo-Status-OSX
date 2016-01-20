//
//  NSURL+YSOAuth2.m
//  Yo Status
//
//  Created by Emmanuel Merali on 20/01/2016.
//  Copyright © 2016 rooftoptek.com. All rights reserved.
//

#import "NSURL+YSOAuth2.h"

@implementation NSURL (YSOAuth2)

- (NSURL *)URLByAddingParameters:(NSDictionary *)parameterDictionary {
    if (!parameterDictionary || [parameterDictionary count] == 0) {
        return self;
    }
    
    NSString *newParameterString = [NSString stringWithEncodedQueryParameters:parameterDictionary];
    
    NSString *absoluteString = [self absoluteString];
    if ([absoluteString rangeOfString:@"?"].location == NSNotFound) {    // append parameters?
        absoluteString = [NSString stringWithFormat:@"%@?%@", absoluteString, newParameterString];
    }
    else {
        absoluteString = [NSString stringWithFormat:@"%@&%@", absoluteString, newParameterString];
    }
    
    return [NSURL URLWithString:absoluteString];
}

@end

//
//  YSEmoji.h
//  Yo Status
//
//  Created by Emmanuel Merali on 20/01/2016.
//  Copyright © 2016 rooftoptek.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSEmoji : NSObject

@property (nonatomic, copy) NSString                        *emoji;

+ (NSArray *)allEmojis;

@end

//
//  YSEmoji.m
//  Yo Status
//
//  Created by Emmanuel Merali on 20/01/2016.
//  Copyright © 2016 rooftoptek.com. All rights reserved.
//

#import "YSEmoji.h"

@implementation YSEmoji

static NSArray *allEmojis;

+ (void)load {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"EmojisList" ofType:@"plist"];
    NSDictionary *groups = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSMutableArray *emojis = [NSMutableArray array];
    for (NSString *name in groups) {
        for (NSString *emojiString in groups[name]) {
            YSEmoji *emoji = [YSEmoji new];
            emoji.emoji = emojiString;
            [emojis addObject:emoji];
        }
    }
    allEmojis = emojis;
}

+ (NSArray *)allEmojis {
    return [NSArray arrayWithArray:allEmojis];
}

@end

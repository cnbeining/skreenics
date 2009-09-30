//
//  SKGenerateThumbnailOperation.h
//  Skreenics
//
//  Created by naixn on 13/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SKVideoItem.h"


@interface SKGenerateThumbnailOperation : NSOperation
{
    NSUserDefaults*         userDefaults;
    SKVideoItem*            videoItem;
    NSUInteger              rows;
    NSUInteger              cols;
}

- (id)initWithVideoItem:(SKVideoItem *)aVideoItem;

@end

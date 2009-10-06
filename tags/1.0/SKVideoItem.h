//
//  SKVideoItem.h
//  Skreenics
//
//  Created by naixn on 24/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SKProgressIndicator.h"


@interface SKVideoItem : NSObject
{
    NSMutableDictionary*    videoItem;
    NSOperation*            associatedOperation;
}

@property (retain) NSOperation* associatedOperation;

- (id)copyWithZone:(NSZone *)zone;

// Misc
- (void)cleanup;

// Interesting getters
- (BOOL)isFinished;
- (BOOL)isErroneous;

// Setters
- (void)setNumberOfSteps:(NSNumber *)steps;
- (void)setProgressString:(NSString *)progressString;
- (void)setProgressValue:(NSNumber *)progress;
- (void)setProgressString:(NSString *)progressString incrementProgressValue:(BOOL)increment;
- (void)setError:(NSString *)errorString;

// Observing
- (void)addObserverForInterestingKeyPaths:(NSObject *)observer;
- (void)removeObserverForInterestingKeyPaths:(NSObject *)observer;

// Simple getters
- (NSString *)filepath;
- (NSString *)filename;
- (NSImage *)icon;
- (SKProgressIndicator *)progressIndicator;
- (NSNumber *)progressValue;
- (NSString *)progressString;
- (NSNumber *)numberOfSteps;

@end

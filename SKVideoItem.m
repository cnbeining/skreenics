//
//  SKVideoItem.m
//  Skreenics
//
//  Created by naixn on 24/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import "SKVideoItem.h"

#import "SKDefines.h"


@implementation SKVideoItem

@synthesize associatedOperation;

- (id)init
{
    return [super init];
}

- (id)initWithPath:(NSString *)path
{
    if (self = [super init])
    {
        SKProgressIndicator* progressIndicator = [[SKProgressIndicator alloc] init];    
        NSString* fullPath = [path stringByExpandingTildeInPath];
        
        videoItem = [[NSMutableDictionary alloc] init];
        [videoItem setValue:fullPath forKey:kSKFilePathKey];
        [videoItem setValue:[fullPath lastPathComponent] forKey:kSKFileNameKey];
        [videoItem setValue:[[NSWorkspace sharedWorkspace] iconForFile:fullPath] forKey:kSKIconKey];
        [videoItem setValue:progressIndicator forKey:kSKProgressIndicatorKey];
        [videoItem setValue:[NSNumber numberWithInt:0] forKey:kSKProgressValueKey];
        [videoItem setValue:@"Waiting..." forKey:kSKProgressStringKey];
        [videoItem setValue:[NSNumber numberWithInt:100] forKey:kSKNumberOfStepsKey];

        [progressIndicator release];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return nil;
}

- (void)dealloc
{
    [self setAssociatedOperation:nil];
    [[self progressIndicator] removeFromSuperview];
    [videoItem release];
    [super dealloc];
}

#pragma mark -

#pragma mark Misc

- (void)cleanup
{
    [[self progressIndicator] removeFromSuperview];
}

#pragma mark Interesting getters

- (BOOL)isFinished
{
    return [[self progressValue] isEqualToNumber:[self numberOfSteps]];
}

- (BOOL)isErroneous
{
    return ([[self progressValue] doubleValue] == kSKProgressIndicatorError);
}

#pragma mark Setters

- (void)setNumberOfSteps:(NSNumber *)steps
{
    // We want to perform the change on the main thread for UI changes
    if ([NSThread isMainThread] == NO)
    {
        [self performSelectorOnMainThread:@selector(setNumberOfSteps:) withObject:steps waitUntilDone:YES];
    }
    else
    {
        [videoItem setValue:steps forKey:kSKNumberOfStepsKey];
        [[self progressIndicator] setMaxProgressValue:[steps doubleValue]];
    }
}

- (void)setProgressString:(NSString *)progressString
{
    // We want to perform the change on the main thread for UI changes
    if ([NSThread isMainThread] == NO)
    {
        [self performSelectorOnMainThread:@selector(setProgressString:) withObject:progressString waitUntilDone:YES];
    }
    else
    {
        [videoItem setValue:progressString forKey:kSKProgressStringKey];
    }
}

- (void)setProgressValue:(NSNumber *)progress
{
    // We want to perform the change on the main thread for UI changes
    if ([NSThread isMainThread] == NO)
    {
        [self performSelectorOnMainThread:@selector(setProgressValue:) withObject:progress waitUntilDone:YES];
    }
    else
    {
        [videoItem setValue:progress forKey:kSKProgressValueKey];
        [[self progressIndicator] setAnimatedProgressValue:[progress doubleValue]];
    }
}

- (void)setProgressString:(NSString *)progressString incrementProgressValue:(BOOL)increment
{
    double  currentValue;

    [self setProgressString:progressString];
    if (increment)
    {
        currentValue = [[self progressValue] doubleValue];
        [self setProgressValue:[NSNumber numberWithDouble:(currentValue + 1.0)]];
    }
}

- (void)setError:(NSString *)errorString
{
    [self setProgressString:errorString];
    [self setProgressValue:[NSNumber numberWithDouble:kSKProgressIndicatorError]];
}

#pragma mark Observing

- (void)addObserverForInterestingKeyPaths:(NSObject *)observer
{
    [self addObserver:observer forKeyPath:kSKVideoItemProgressValuePath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverForInterestingKeyPaths:(NSObject *)observer
{
    [self removeObserver:observer forKeyPath:kSKVideoItemProgressValuePath];
}

#pragma mark Simple getters

- (NSString *)filepath
{
    return [videoItem objectForKey:kSKFilePathKey];
}

- (NSString *)filename
{
    return [videoItem objectForKey:kSKFileNameKey];
}

- (NSImage *)icon
{
    return [videoItem objectForKey:kSKIconKey];
}

- (SKProgressIndicator *)progressIndicator
{
    return [videoItem objectForKey:kSKProgressIndicatorKey];
}

- (NSNumber *)progressValue
{
    return [videoItem objectForKey:kSKProgressValueKey];
}

- (NSString *)progressString
{
    return [videoItem objectForKey:kSKProgressStringKey];
}

- (NSNumber *)numberOfSteps
{
    return [videoItem objectForKey:kSKNumberOfStepsKey];
}

@end

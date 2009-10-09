//
//  SKProgressIndicator.m
//  Skreenics
//
//  Created by naixn on 19/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import "SKProgressIndicator.h"


#define GRADIANT_HEIGHT 13.0
#define PADDING 20.0

#pragma mark -

@implementation SKProgressAnimator

- (id)initWithDelegate:(id <SKProgressAnimatorDelegate>)delegate from:(double)from to:(double)to
{
    if (self = [super initWithDuration:0.20 animationCurve:NSAnimationEaseInOut])
    {
        [self setDelegate:delegate];
        [self setFrameRate:60.0];
        [self setAnimationBlockingMode:NSAnimationNonblocking];
        originalProgress = from;
        finalProgress = to;
    }
    return self;
}

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
    [super setCurrentProgress:progress];
    
    double currentValue = [self currentValue];
    if ([self animationCurve] == NSAnimationEaseOut)
    {
        currentValue = 1.0 - currentValue;
    }
    [(id <SKProgressAnimatorDelegate>)[self delegate] setProgressValue:(originalProgress + (finalProgress - originalProgress) * currentValue)];
}

@end

#pragma mark -

@implementation SKProgressIndicator

@synthesize maxProgressValue;

- (id)init
{
    if (self = [super init])
    {
        progressValue = 0.0;
        maxProgressValue = 100.0;
        progressAnimation = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
    {
        progressValue = 0.0;
        maxProgressValue = 100.0;
        progressAnimation = nil;
    }
    return self;
}

- (void)dealloc
{
    if (progressAnimation)
    {
        [progressAnimation setDelegate:nil];
        [progressAnimation release];
    }
    [super dealloc];
}

#pragma mark Progress value

- (double)progressValue
{
    return progressValue;
}

- (void)setProgressValue:(double)value
{
    if (value > maxProgressValue)
    {
        value = maxProgressValue;
    }
    else if (value < 0.0 & value != kSKProgressIndicatorError)
    {
        value = 0.0;
    }
    progressValue = value;
    [self setNeedsDisplay:YES];
}

- (void)setAnimatedProgressValue:(double)value
{
    if (value != progressValue)
    {
        if (progressValue != kSKProgressIndicatorError)
        {
            if (progressAnimation)
            {
                [progressAnimation stopAnimation];
                [progressAnimation release];
            }
            progressAnimation = [[SKProgressAnimator alloc] initWithDelegate:self from:progressValue to:value];
            [progressAnimation startAnimation];
        }
        else
        {
            [self setProgressValue:value];
        }
    }
}

#pragma mark Progress Indicator delegate

- (void)animationDidEnd:(NSAnimation *)animation
{
    [progressAnimation release];
    progressAnimation = nil;
}

#pragma mark Draw related

- (NXGradiantComponents)gradiantHolderComponents
{
    NXGradiantComponents    gradiantHolder;
    
    gradiantHolder.red = 0.85;
    gradiantHolder.green = 0.85;
    gradiantHolder.blue = 0.85;
    gradiantHolder.alpha = 1.0;
    
    return gradiantHolder;
}

- (NXGradiantComponents)redGradiantComponents
{
    NXGradiantComponents    redGradiant;
    
    redGradiant.red = 0.8;
    redGradiant.green = 0.4;
    redGradiant.blue = 0.4;
    redGradiant.alpha = 1.0;
    
    return redGradiant;
}

- (NXGradiantComponents)greenGradiantComponents
{
    NXGradiantComponents    greenGradiant;
    
    greenGradiant.red = 0.4;
    greenGradiant.green = 0.8;
    greenGradiant.blue = 0.4;
    greenGradiant.alpha = 1.0;
    
    return greenGradiant;
}

- (NXGradiantComponents)blueGradiantComponents
{
    NXGradiantComponents    blueGradiant;
    
    blueGradiant.red = 0.43;
    blueGradiant.green = 0.64;
    blueGradiant.blue = 0.93;
    blueGradiant.alpha = 1.0;
    
    return blueGradiant;
}

- (NSGradient *)gradiantWithColors:(NXGradiantComponents)c
{
    NSColor*    baseColor;
    NSColor*    fadedColor1;
    NSColor*    fadedColor2;

    baseColor = [NSColor colorWithCalibratedRed:c.red green:c.green blue:c.blue alpha:c.alpha];
    fadedColor1 = [NSColor colorWithCalibratedRed:(c.red * 0.90) green:(c.green * 0.90) blue:(c.blue * 0.90) alpha:c.alpha];
    fadedColor2 = [NSColor colorWithCalibratedRed:(c.red * 0.80) green:(c.green * 0.80) blue:(c.blue * 0.80) alpha:c.alpha];
    return [[[NSGradient alloc] initWithColorsAndLocations:baseColor, 0.0, baseColor, 0.5, fadedColor1, 0.8, fadedColor2, 0.9, baseColor, 1.0, nil] autorelease];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect                  progressRect;
    NXGradiantComponents    gc;

    [[self gradiantWithColors:[self gradiantHolderComponents]] drawInRect:dirtyRect angle:90.0];

    if (progressValue)
    {
        progressRect = dirtyRect;
        if (progressValue != kSKProgressIndicatorError)
        {
            progressRect.size.width = (int)((progressValue * NSWidth(dirtyRect)) / maxProgressValue);
            if (progressValue >= maxProgressValue)
            {
                gc = [self greenGradiantComponents];
            }
            else
            {
                gc = [self blueGradiantComponents];
            }
        }
        else
        {
            gc = [self redGradiantComponents];
        }
        [[self gradiantWithColors:gc] drawInRect:progressRect angle:-90.0];
    }
    
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.0 alpha:0.2] set];
    [NSBezierPath setDefaultLineWidth:1.0];
    [NSBezierPath strokeRect:NSInsetRect(dirtyRect, 0.5, 0.5)];
    [NSBezierPath strokeRect:NSInsetRect(progressRect, 0.5, 0.5)];
    [NSGraphicsContext restoreGraphicsState];
}

@end

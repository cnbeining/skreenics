//
//  SKRgbToNSColorTransformer.m
//  Skreenics
//
//  Created by naixn on 27/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import "SKRgbToNSColorTransformer.h"


@implementation SKRgbToNSColorTransformer

+ (Class)transformedValueClass
{
    return [NSColor class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    if (!value || [value isKindOfClass:[NSDictionary class]] == NO)
    {
        return nil;
    }

    return [NSColor colorWithCalibratedRed:[[value valueForKey:@"Red"]   doubleValue]
                                     green:[[value valueForKey:@"Green"] doubleValue]
                                      blue:[[value valueForKey:@"Blue"]  doubleValue]
                                     alpha:[[value valueForKey:@"Alpha"] doubleValue]
            ];
}

- (id)reverseTransformedValue:(id)value
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;

    if (!value || [value isKindOfClass:[NSColor class]] == NO)
    {
        return nil;
    }

    [[(NSColor *)value colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&red green:&green blue:&blue alpha:&alpha];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:red],   @"Red",
            [NSNumber numberWithDouble:green], @"Green",
            [NSNumber numberWithDouble:blue],  @"Blue",
            [NSNumber numberWithDouble:alpha], @"Alpha",
            nil];
}

@end

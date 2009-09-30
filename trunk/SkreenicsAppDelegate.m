//
//  SkreenicsAppDelegate.m
//  Skreenics
//
//  Created by naixn on 21/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import "SkreenicsAppDelegate.h"
#import "SKVideoItem.h"
#import "SKGenerateThumbnailOperation.h"
#import "SKProgressCell.h"
#import "SKRgbToNSColorTransformer.h"
#import "ExpandedPathToPathTransformer.h"
#import "ExpandedPathToIconTransformer.h"
#import "SKDefines.h"

@implementation SkreenicsAppDelegate

@synthesize window;

+ (void)initialize
{
    // We want to be able to provide alpha colors
    [NSColor setIgnoresAlpha:NO];
    // Set transformers for the prefs
    [NSValueTransformer setValueTransformer:[[[ExpandedPathToIconTransformer alloc] init] autorelease] forName:@"ExpandedPathToIconTransformer"];
    [NSValueTransformer setValueTransformer:[[[ExpandedPathToPathTransformer alloc] init] autorelease] forName:@"ExpandedPathToPathTransformer"];
    // Set the default RGB to NSColor transformer
    [NSValueTransformer setValueTransformer:[[[SKRgbToNSColorTransformer alloc] init] autorelease] forName:@"SKRgbToNSColorTransformer"];
    // And now we can register our user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"]]];
}

- (id)init
{
    if (self = [super init])
    {
        userDefaults = [NSUserDefaults standardUserDefaults];
        videoCollection = [[NSMutableArray alloc] init];
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:[[userDefaults valueForKey:kSKMaxConcurrentOperationsPrefKey] integerValue]];
        acceptableMovieTypes = [[QTMovie movieTypesWithOptions:QTIncludeCommonTypes] retain];
    }
    return self;
}

- (void)dealloc
{
    [videoCollection release];
    [operationQueue release];
    [acceptableMovieTypes release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [userDefaults addObserver:self forKeyPath:kSKMaxConcurrentOperationsPrefKey options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark Video collection management

- (void)addVideoFromPath:(NSString *)path
{
    NSOperation*    op;
    SKVideoItem*    videoItem;
    NSString*       fullPath;

    if ([acceptableMovieTypes containsObject:[[NSWorkspace sharedWorkspace] typeOfFile:path error:nil]] == NO)
    {
        return ;
    }

    fullPath = [path stringByExpandingTildeInPath];
    videoItem = [[SKVideoItem alloc] initWithPath:fullPath];
    [videoItem addObserverForInterestingKeyPaths:self];

    [videoCollection addObject:videoItem];
    [videoTableView reloadData];

    op = [[SKGenerateThumbnailOperation alloc] initWithVideoItem:videoItem];
    [videoItem setAssociatedOperation:op];
    [operationQueue addOperation:op];

    [op release];
    [videoItem release];
}

- (void)addVideosFromFolder:(NSString *)folderPath recursive:(BOOL)recursive
{
    NSArray*        files;
    
    if (recursive)
    {
        files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    }
    else
    {
        files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    }
    for (NSString* file in files)
    {
        // The returned list does not contain the original folder that was passed as a parameter
        [self addVideoFromPath:[folderPath stringByAppendingPathComponent:file]];
    }
}

- (void)addPathElement:(NSString *)path
{
    BOOL    pathIsDirectory = NO;
    
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&pathIsDirectory];
    if (pathIsDirectory)
    {
        [self addVideosFromFolder:path recursive:[userDefaults boolForKey:kSKAddSubfoldersOnDropPrefKey]];
    }
    else
    {
        [self addVideoFromPath:path];
    }
}

#pragma mark User interface interactions

- (IBAction)toggleSuspendedStatus:(id)sender
{
    if ([operationQueue isSuspended] == NO)
    {
        [operationQueue setSuspended:YES];
        [suspendToolbarItem setLabel:@"Resume"];
        [suspendButton setImage:[NSImage imageNamed:@"NSRightFacingTriangleTemplate"]];
    }
    else
    {
        [operationQueue setSuspended:NO];
        [suspendToolbarItem setLabel:@"Suspend"];
        [suspendButton setImage:[NSImage imageNamed:@"NSRemoveTemplate"]];
    }
}

- (IBAction)removeSelectedItem:(id)sender
{
    SKVideoItem*    videoItem;
    NSIndexSet*     selectedSet;

    selectedSet = [videoTableView selectedRowIndexes];
    if ([selectedSet count])
    {
        for (NSUInteger index = [selectedSet firstIndex]; index <= [selectedSet lastIndex]; index = [selectedSet indexGreaterThanIndex:index])
        {
            videoItem = [videoCollection objectAtIndex:index];
            [videoItem cleanup];
            [videoItem removeObserverForInterestingKeyPaths:self];
            [[videoItem associatedOperation] cancel];
        }
        [videoCollection removeObjectsAtIndexes:selectedSet];
        [videoTableView deselectAll:self];
        [videoTableView reloadData];
    }
}

- (IBAction)clearVideoList:(id)sender
{
    NSMutableIndexSet*  removeSet = [NSMutableIndexSet indexSet];

    for (SKVideoItem* videoItem in videoCollection)
    {
        if ([videoItem isFinished] == YES || [videoItem isErroneous] == YES)
        {
            [videoItem cleanup];
            [videoItem removeObserverForInterestingKeyPaths:self];
            [removeSet addIndex:[videoCollection indexOfObject:videoItem]];
        }
    }
    [videoCollection removeObjectsAtIndexes:removeSet];
    [videoTableView reloadData];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        for (NSURL* url in [panel URLs])
        {
            [self addPathElement:[url path]];
        }
    }
    [panel release];
}

- (IBAction)displayOpenPanel:(id)sender
{
    NSOpenPanel*    openPanel;

    openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:@"Open Video Files"];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel beginForDirectory:nil
                            file:nil
                           types:[QTMovie movieFileTypes:QTIncludeCommonTypes]
                modelessDelegate:self
                  didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
                     contextInfo:nil];
    [openPanel retain];
}

#pragma mark Video Collection Observer methods

- (void)mainThreadObserveValueWithAttributes:(NSDictionary *)attributes
{
    NSString*   keyPath;

    keyPath = [attributes valueForKey:kSKObserverKeyPathKey];
    if ([keyPath isEqualToString:kSKVideoItemProgressValuePath])
    {
        [videoTableView reloadData];
    }
    else if ([keyPath isEqualToString:kSKMaxConcurrentOperationsPrefKey])
    {
        [operationQueue setMaxConcurrentOperationCount:[[userDefaults valueForKey:kSKMaxConcurrentOperationsPrefKey] integerValue]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSDictionary*   observedAttributes;
    NSValue*        contextValue;

    contextValue = [NSValue valueWithPointer:context];
    observedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                            keyPath,        kSKObserverKeyPathKey,
                            object,         kSKObserverObjectKey,
                            change,         kSKObserverChangeKey,
                            contextValue,   kSKObserverContextKey,
                          nil];
    [self performSelectorOnMainThread:@selector(mainThreadObserveValueWithAttributes:)
                           withObject:observedAttributes
                        waitUntilDone:NO];
}

#pragma mark Drag Delegate Protocol

- (void)addDragPathElement:(NSString *)path
{
    [self addPathElement:path];
}

#pragma mark Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tblView
{
    return [videoCollection count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return [videoCollection objectAtIndex:rowIndex];
}

#pragma mark Table View Delegate

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    SKProgressCell* cell;

    cell = (SKProgressCell *)aCell;
    [cell setRepresentedObject:[videoCollection objectAtIndex:rowIndex]];
}

#pragma mark Quit

- (BOOL)windowShouldClose:(id)sender
{
    [NSApp terminate:self];
    return NO;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        [NSApp replyToApplicationShouldTerminate:NO];
    }
    else
    {
        [NSApp replyToApplicationShouldTerminate:YES];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    NSAlert*    alert;

    if ([[operationQueue operations] count] > 0 && [operationQueue isSuspended] == NO)
    {
        alert = [NSAlert alertWithMessageText:@"Skreenics is still running"
                                defaultButton:@"Cancel & Continue"
                              alternateButton:@"Abort & Quit"
                                  otherButton:nil
                    informativeTextWithFormat:@"There are pending and/or running jobs. Are you sure you want to quit?."];
        
        [alert beginSheetModalForWindow:[self window]
                          modalDelegate:self
                         didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                            contextInfo:NULL];
        return NSTerminateLater;
    }
    return NSTerminateNow;
}

@end

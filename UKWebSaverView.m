//
//  UKWebSaverView.m
//  WebSaver
//
//  Created by Thomas Robinson on 10/13/09.
//  Copyright (c) 2009, 280 North. All rights reserved.
//

#import "UKWebSaverView.h"
#import <WebKit/WebKit.h>
#import <AppKit/NSNibLoading.h>


NSString*	UKWebSaverURL = @"UKWebSaverURL";
NSString*	UKWebSaverScaleFactor = @"UKWebSaverScaleFactor";
NSString*	UKWebSaver = @"UKWebSaver";


@implementation UKWebSaverView

-(id)	initWithFrame: (NSRect)frame isPreview: (BOOL)isPreview
{
    self = [super initWithFrame: frame isPreview: isPreview];
    if( self )
	{
		webView = [[WebView alloc] initWithFrame:[self bounds] frameName: nil groupName: nil];
		[(NSScrollView*)webView setBackgroundColor: [NSColor blackColor]];	// Looks a little nicer on loading.
		[self addSubview: webView];
		
		[self reloadSettings];
    }
    return self;
}


-(void)	dealloc
{
	[configureSheet release];
	configureSheet = nil;
	
	[super dealloc];
}


-(void)	reloadSettings
{
	if( !webView )
		return;
	
	// Set up any scaling:
	NSNumber*	scaleFactorObj = [[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] objectForKey: UKWebSaverScaleFactor];
	float		scaleFactor = scaleFactorObj ? [scaleFactorObj floatValue] : 1.0;
	[webView setTextSizeMultiplier: scaleFactor];
	
	// Load URL:
	NSString*	urlString = [[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] objectForKey: UKWebSaverURL];
	if( !urlString )	// No URL? Use default.
		urlString = [NSString stringWithFormat: @"file://%@/index.html", [[NSBundle bundleForClass:[self class]] resourcePath]];
	
	[webView setMainFrameURL: urlString];
}


- (BOOL)hasConfigureSheet
{
    return YES;
}


-(NSWindow*)	configureSheet
{
	// Create a sheet from the NIB, unless we already loaded it earlier:
	if( !configureSheet )
 	{
		NSBundle*	myBundle = [NSBundle bundleForClass: [self class]];
		[myBundle loadNibFile: [myBundle pathForResource: @"TANWebSaverConfigureSheet" ofType: @"nib"]
					externalNameTable: [NSDictionary dictionaryWithObject: self forKey: @"NSOwner"] withZone: [self zone]];
	}
	
	// urlString == nil means default URL, so check the "default" radio, otherwise
	//	put the URL string in the edit field and check the other one:
	NSString*	urlString = [[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] objectForKey: UKWebSaverURL];
	[radioChoices selectCellAtRow: urlString ? 1 : 0 column: 0];
	if( urlString )
		[urlField setStringValue: urlString];
	
	// Scale factor:
	NSNumber*	scaleFactorObj = [[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] objectForKey: UKWebSaverScaleFactor];
	float		scaleFactor = scaleFactorObj ? [scaleFactorObj floatValue] : 1.0;
	[scaleFactorSlider setDoubleValue: scaleFactor];
	
	return configureSheet;
}


-(IBAction)	doOKButton: (id)sender
{
	[configureSheet orderOut: self];
	
	// Use the user's radio choice to decide which URL to save:
	if( [radioChoices selectedRow] == 0 )
		[[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] removeObjectForKey: UKWebSaverURL];	// No URL? Default.
	else
		[[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] setObject: [urlField stringValue] forKey: UKWebSaverURL];
	
	[[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] setFloat: [scaleFactorSlider doubleValue] forKey: UKWebSaverScaleFactor];
	
	[self reloadSettings];
	
	[NSApp endSheet: configureSheet];
}


-(IBAction)	doCancelButton: (id)sender
{
	[configureSheet orderOut: self];
	[NSApp endSheet: configureSheet];
}


-(void)	setConfigureSheet: (NSWindow*)wd
{
	if( configureSheet != wd )
	{
		[configureSheet release];
		configureSheet = [wd retain];
	}
}


@end

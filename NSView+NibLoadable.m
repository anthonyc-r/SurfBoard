#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@implementation NSView(NibLoadable)

+(id)loadFromNibNamed: (NSString*)nibName owner: (id)owner {
	NSNib *nib = [[NSNib alloc] initWithNibNamed: nibName bundle: [NSBundle mainBundle]];
	if (!nib) {
		NSLog(@"Error loading nib named %@", nibName);
		return nil;
	}
	NSArray *topLevelObjects;
	[nib instantiateNibWithOwner: owner topLevelObjects: &topLevelObjects];
	if ([topLevelObjects count] < 1) {
		NSLog(@"No objects in nib.");
		return nil;
	}
	NSView *view = [topLevelObjects objectAtIndex: 0];
	if (!view) {
		NSLog(@"Object at index 0 was not a NSView or subclass of this.");
	} else {
		NSLog(@"Loaded nib named %@", nibName);
	}
	[view autorelease];
	//[topLevelObjects release];
	//[nib release];
	return view;
}

@end

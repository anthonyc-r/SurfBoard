#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface NSView(NibLoadable)

+(id)loadFromNibNamed: (NSString*)nibName owner: (id)owner;

@end

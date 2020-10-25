/*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <Foundation/Foundation.h>
#import "CaptchaChallenge.h"
#import "Net/NSURL+Utils.h"

static NSString *const HINT_REGEXP = @"<div class=\"rc-imageselect-desc-no-canonical\">(.*?)</div>";
static NSString *const KEY_REGEXP = @".*<input.+name=\"c\".+value=\"([^\"]+)\"/><div class=\"fbc-payload-imageselect";
static NSString *const IMG_REGEXP = @"<img.+class=\"fbc-imageselect-payload\".+src=\"([^\"]*)\"";

static NSString *extractWithExp(NSString *src, NSString *const pattern) {
	NSError *error = nil;
	NSRegularExpression *exp = [[NSRegularExpression alloc]
		initWithPattern: pattern
		options: 0
		error: &error
	];
	if (error != nil) {
		NSLog(@"error creating key regexp: %@", error);
		return nil;	
	}
	NSTextCheckingResult *result = [exp firstMatchInString: src options: 0 range:
		NSMakeRange(0, [src length])];
	NSRange range = [result rangeAtIndex: 1];
	if (range.location == NSNotFound) {
		NSLog(@"Couldnt find range of match");
		return nil;
	}
	NSString *match = [src substringWithRange: range];
	[exp release];
	return match;
}

@implementation CaptchaChallenge

-(id)initFromHTML: (NSString*)HTML {
	if (self = [super init]) {
		key = extractWithExp(HTML, KEY_REGEXP);
		[key retain];
		NSString *imagePath = extractWithExp(HTML, IMG_REGEXP);
		imageGridURL = [NSURL urlForCaptchaImage: imagePath];
		[imageGridURL retain];
		instructions = extractWithExp(HTML, HINT_REGEXP);
		[instructions retain];
	}
	return self;
}

- (void) dealloc {
	[key release];
	[imageGridURL release];
	[super dealloc];
}

-(NSString*)key {
	return key;
}

-(BOOL)isValid {
	return key != nil && imageGridURL != nil && instructions != nil;
}

-(NSURL*)imageGridURL {
	return imageGridURL;
}

-(NSString*)instructions {
	return instructions;
}

-(int)imageCount {
	return 9;
}

-(void)setImageSelected: (BOOL)selected atIndex: (int)index {
	selection[index] = selected;
}


-(BOOL)isImageSelectedAtIndex: (int)index {
	return selection[index];
}

@end

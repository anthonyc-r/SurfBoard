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
#import "Post.h"

@implementation Post

-(id)initWithDictionary: (NSDictionary*)dict board: (NSString*)aBoard {
	self = [super init];
	if (self) {
		number = [dict objectForKey: @"no"];
		[number retain];
		body = [dict objectForKey: @"com"];
		[body retain];
		userName = [dict objectForKey: @"name"];
		[userName retain];
		imageExt = [dict objectForKey: @"ext"];
		[imageExt retain];
		imageName = [dict objectForKey: @"filename"];
		[imageName retain];
		subject = [dict objectForKey: @"sub"];
		[subject retain];
		imageResName = [dict objectForKey: @"tim"];
		[imageResName retain];
		board = aBoard;
		[board retain];
	}
	return self;
}

-(void)deinit {
	// TODO: - Release everything.
}

-(NSString*)getBody {
	return body;
}

-(void)setBody: (NSString*)bodyContent {
	[body release];
	body = bodyContent;
	[body retain];
}

-(NSString*)getImageResName {
	return imageResName;
}

-(NSString*)getImageExt {
	return imageExt;
}

-(NSString*)getBoard {
	return board;
}

-(void)performWithImages: (SEL)selector target: (id)target {
	if (image) {
		[target performSelector: selector withObject: self 
			withObject: image];
		return;
	}
}

-(void)performWithThumbnail: (SEL)selector target: (id)target {
	if (thumbnail) {
		[target performSelector: selector withObject: self 
			withObject: nil];
		return;
	}
}


@end

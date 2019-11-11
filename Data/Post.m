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
#import "Text/NSAttributedString+HTML.h"

@implementation Post

-(id)initWithDictionary: (NSDictionary*)dict board: (NSString*)aBoard {
	self = [super init];
	if (self) {
		number = [dict objectForKey: @"no"];
		[number retain];
		if ((body = [dict objectForKey: @"com"])) {
			attributedBody = [NSAttributedString attributedStringFromHTMLString: body];
			[body retain];
			[attributedBody retain];
		} else {
			attributedBody = nil;
		}
		NSNumber *time = [dict objectForKey: @"time"];
		if (time) {
			postDate = [NSDate dateWithTimeIntervalSince1970: 
				[time doubleValue]];
		}
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

-(NSNumber*)getNumber {
	return number;
}

-(NSAttributedString*)getAttributedBody {
	return attributedBody;
}

-(NSString*)getSubject {
	return subject;
}

-(NSString*)getUserName {
	return userName;
}

-(NSDate*)getPostDate {
	return postDate;
}

-(NSString*)getFormattedPostDate {
	// TODO: - Convert expensive formatter to singleton util class
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat: @"dd/MM/yy(EEE)HH:mm:ss"];
	return [formatter stringFromDate: [self getPostDate]];
}

-(NSString*)getHeadline {
	if ([self getSubject]) {
		return [NSString stringWithFormat: @"%@ %@ %@ No.%@",
			[self getSubject], [self getUserName],
			[self getFormattedPostDate], [self getNumber]];
	} else {
		return [NSString stringWithFormat: @"%@ %@ No.%@",
			[self getUserName], [self getFormattedPostDate],
			[self getNumber]];
	}
}

-(NSAttributedString*)getAttributedHeadline {
	return nil; // TODO: - Implement.
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

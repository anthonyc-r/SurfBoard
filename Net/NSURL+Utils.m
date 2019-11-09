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
#import "Data/Post.h"
#import "Data/Thread.h"

//BASE+Board+GeneratedImgName+ex/+s.jpg
static NSString *const IMAGE_URL = @"https://i.4cdn.org/%@/%@%@";
static NSString *const THUMB_URL = @"https://i.4cdn.org/%@/%@s.jpg";
static NSString *const INDEX_URL = @"https://a.4cdn.org/%@/%@.json";
static NSString *const THREAD_DETAILS = @"https://a.4cdn.org/%@/thread/%@.json";

@implementation NSURL (Utils)

+(NSURL*)urlForPostImage: (Post*)post {
	NSString *urlString = [NSString stringWithFormat: IMAGE_URL, 
		[post getBoard], [post getImageResName], [post getImageExt]];
	return [NSURL URLWithString: urlString];
}

+(NSURL*)urlForThumbnail: (Post*)post {
	if ([post getImageResName] == nil) {
		return nil;
	}
	NSString *urlString = [NSString stringWithFormat: THUMB_URL,
		[post getBoard], [post getImageResName]];
	return [NSURL URLWithString: urlString];
}

+(NSURL*)urlForIndex: (NSNumber*)index ofBoard: (NSString*)board {
	NSString *urlString = [NSString stringWithFormat: INDEX_URL,
		board, index];
	return [NSURL URLWithString: urlString];
}

+(NSURL*)urlForThreadDetails: (Thread*)thread {
	Post *op = [thread getOP];
	NSString *urlString = [NSString stringWithFormat: THREAD_DETAILS,
		[op getBoard], [op getNumber]];
	return [NSURL URLWithString: urlString];
}

+(NSURL*)urlForFullPostImage: (Post*)post {
	NSString *urlString = [NSString stringWithFormat: IMAGE_URL,
		[post getBoard], [post getImageResName], [post getImageExt]];
	return [NSURL URLWithString: urlString];
}

@end

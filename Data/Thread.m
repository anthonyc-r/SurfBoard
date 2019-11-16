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
#import "Thread.h"
#import "Post.h"

@implementation Thread

-(id)initWithDictionary: (NSDictionary*)dict {
	self = [super init];
	if (self) {
		NSMutableArray *somePosts = [[NSMutableArray alloc] init];
		NSArray *postsJson = [dict objectForKey: @"posts"];
		for (int i = 0; i < [postsJson count]; i++) {
			NSDictionary *json = [postsJson objectAtIndex: i];
			Post *aPost = [[Post alloc] initWithDictionary: json board: @"g"];
			[somePosts addObject: aPost];
			[aPost release];
		}
		posts = somePosts;
	}
	return self;
}

-(void)dealloc {
	[super dealloc];
	[posts dealloc];
}

-(NSArray*)getPosts {
	return posts;
}

-(void)setPosts: (NSArray*)somePosts{
	posts = somePosts;
}

-(Post*)getOP {
	return [posts firstObject];
}

-(NSArray*)getLatestPosts {
	int count = [posts count];
	if (count < 2) {
		NSArray *ret = [[NSArray alloc] init];
		[ret autorelease];
		return ret;
	} else {
		NSArray *ret = [[NSArray alloc] init];
		[ret autorelease];
		return ret;
	}
}

-(Post*)getPostWithNumber: (NSNumber*)postNumber {
	// TODO: - Implement.	
	return [self getOP];
}

@end

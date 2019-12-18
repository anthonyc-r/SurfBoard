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
#import <AppKit/AppKit.h>

@interface Post: NSObject {
@private
	NSNumber *number;
	NSString *body;
	NSAttributedString *attributedBody;
	NSString *userName;
	NSString *imageName;
	NSString *imageResName;
	NSString *imageExt;
	NSString *subject;
	NSImage *image;
	NSImage *thumbnail;
	NSDate *postDate;
	NSString *board;
}

-(id)initWithDictionary: (NSDictionary*)dict board: (NSString*)aBoard;
-(id)initStubWithPostNumber: (NSNumber*)aNumber board: (NSString*)aBoard;
-(void)setBody: (NSString*)bodyContent;
-(NSString*)getBody;
-(NSAttributedString*)getAttributedBody;
-(NSString*)getHeadline;
-(NSAttributedString*)getAttributedHeadline;
-(NSString*)getImageResName;
-(NSString*)getImageExt;
-(NSString*)getBoard;
-(NSString*)getSubject;
-(NSString*)getClippedSubject;
-(NSString*)getUserName;
-(NSString*)getFormattedPostDate;
-(NSNumber*)getNumber;
-(NSDate*)getPostDate;
-(BOOL)hasImage;
-(void)performWithImages: (SEL)selector target: (id)target;
-(void)performWithThumbnail: (SEL)selector target: (id)target;
@end

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


#import "NetworkSource.h"
#import "NSURL+Utils.h"
#import "PassNetworkSource.h"
#import "NSError+AppErrors.h"
#import "GNUstepBase/GSMime.h"

// Rando user agent string so we don't get bot rejection response
static NSString *const USER_AGENT = @"Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0";
static NSString *const PASS_KEY = @"pass_id";
static NSString *const BODY_FORMAT = @"act=do_login&id=%@&pin=%@&long_login=1";

static const unsigned char whitespace[32] = {
  '\x00',
  '\x3f',
  '\x00',
  '\x00',
  '\x01',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
  '\x00',
};

#define IS_BIT_SET(a,i) ((((a) & (1<<(i)))) > 0)

#define GS_IS_WHITESPACE(X) IS_BIT_SET(whitespace[(X)/8], (X) % 8)

typedef	struct	{
  const unsigned char	*ptr;
  unsigned	end;
  unsigned	pos;
  unsigned	lin;
  NSString	*err;
  int           opt;
  BOOL		key;
  BOOL		old;
} pldata;

static BOOL skipSpace(pldata *pld)
{
  unsigned char	c;

  while (pld->pos < pld->end)
    {
      c = pld->ptr[pld->pos];

      if (GS_IS_WHITESPACE(c) == NO)
	{
	  return YES;
	}
      if (c == '\n')
	{
	  pld->lin++;
	}
      pld->pos++;
    }
  pld->err = @"reached end of string";
  return NO;
}

static NSRange 
GSRangeOfCookie(NSString *string)
{
  pldata		_pld;
  pldata		*pld = &_pld;
  NSData		*d;
  NSRange               range;

  /*
   * An empty string is a nil property list.
   */
  range = NSMakeRange(NSNotFound, NSNotFound);
  if ([string length] == 0)
    {
      return range;
    }

  d = [string dataUsingEncoding: NSUTF8StringEncoding];
  NSCAssert(d, @"Couldn't get utf8 data from string.");
  _pld.ptr = (unsigned char*)[d bytes];
  _pld.pos = 0;
  _pld.end = [d length];
  _pld.err = nil;
  _pld.lin = 0;
  _pld.opt = 0;
  _pld.key = NO;
  _pld.old = YES;	// OpenStep style

  while (skipSpace(pld) == YES)
    {
      if (pld->ptr[pld->pos] == ',')
	{
	  /* Look ahead for something that will tell us if this is a
	     separate cookie or not */
          unsigned saved_pos = pld->pos;
	  while (pld->ptr[pld->pos] != '=' && pld->ptr[pld->pos] != ';'
		&& pld->ptr[pld->pos] != ',' && pld->pos < pld->end )
	    pld->pos++;
	  if (pld->ptr[pld->pos] == '=')
	    {
	      /* Separate comment */
	      range = NSMakeRange(0, saved_pos-1);
	      break;
	    }
	  pld->pos = saved_pos;
	}
      pld->pos++;
    }
  if (range.location == NSNotFound)
    range = NSMakeRange(0, [string length]);

  return range;
}



@interface NSURLResponse (Additions)
@end

// Implementation which folds multiple Set-Cookie headers using the , character.

@implementation NSURLResponse (Additions)
-(void)_setHeaders: (id)headers {
	NSLog(@"Set headers!!");
	NSEnumerator *e;
	NSString *v;

	if ([headers isKindOfClass: [NSDictionary class]] == YES) {
		NSString *k;
		e = [(NSDictionary*)headers keyEnumerator];
		while ((k = [e nextObject]) != nil) {
			v = [(NSDictionary*)headers objectForKey: k];
			[self _setValue: v forHTTPHeaderField: k];
		}
	} else if ([headers isKindOfClass: [NSArray class]] == YES) {
		GSMimeHeader *h;
		e = [(NSArray*)headers objectEnumerator];
		NSMutableArray *cookies = [[NSMutableArray alloc] init];
		while ((h = [e nextObject]) != nil) {
			NSString *n = [h namePreservingCase: YES];
			NSString *v = [h fullValue];
			if ([n isEqualTo: @"Set-Cookie"]) {
				[cookies addObject: v];
			}
			[self _setValue: v forHTTPHeaderField: n];
		}
		if ([cookies count] > 1) {
			NSString *foldedCookies = [cookies componentsJoinedByString: @", "];
			NSLog(@"Folded cookies: %@", foldedCookies);
			[self _setValue: foldedCookies forHTTPHeaderField: @"Set-Cookie"];
		}
    	}
	[self _checkHeaders];
}

@end

@implementation PassNetworkSource


-(id)initWithToken: (NSString*)aToken pin: (NSString*)aPin {
	if ((self = [super init])) {
		token = aToken;
		pin = aPin;
	}
	return self;
}


-(void)makeSynchronousRequest {
	NSLog(@"Deleting cookies");
	
	NSArray *existingCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	for (int i = 0; i < [existingCookies count]; i++) {
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie: 
			[existingCookies objectAtIndex: i]];
	}
	
	NSLog(@"Fetching pass");
	NSString *body = [NSString stringWithFormat: BODY_FORMAT, token, pin];
	NSURL *url = [NSURL urlForPassAuth];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
	[request setHTTPMethod: @"POST"];
	[request setHTTPShouldHandleCookies: YES];
	[request setHTTPBody: 
		[body dataUsingEncoding: NSASCIIStringEncoding]];
	[request setValue: USER_AGENT forHTTPHeaderField: @"User-Agent"];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest: request
		returningResponse: &response
		error: &error];
	if (error) {
		NSLog(@"Failure, err: %@", error);
		[self failure: error];
		return;
	}
	if (![response isKindOfClass: [NSHTTPURLResponse class]]) {
		NSLog(@"failure resp not httpurl resp %@", response);
		[self failure: [NSError unexpectedResponseError]];
		return;
	}
	NSString *result = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSLog(@"reuslt: %@", result);
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
	NSDictionary *headers = [httpResponse allHeaderFields];
	NSString *cookies = @"domain=test.com; expires=Thu, 12-Sep-2109 14:58:04 GMT; session=foo,bar=baz"; 
    	//[headers objectForKey: @"Set-Cookie"];
	//NSLog(@"cookers %@", cookies);
	
	while (1) {
		NSRange range = GSRangeOfCookie(cookies);
		NSLog(@"range: %d, %d", range.location, range.length);
		if (range.location == NSNotFound) {
			break;
		}
		NSLog(@"Substring: %@", [cookies substringWithRange: range]);
		if ([cookies length] <= NSMaxRange(range)) {
			break;
		}
		cookies = [cookies substringFromIndex: NSMaxRange(range) + 1];
	}
}

@end

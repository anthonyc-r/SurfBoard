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
#import "NSFont+AppFont.h"

@implementation NSMutableAttributedString (HTML)

-(void)replaceHTMLTag: (NSString*)tag withAttributes: (NSDictionary*)attributes {
	NSString *openTag = [NSString stringWithFormat: @"<%@>", tag];
	NSString *closeTag = [NSString stringWithFormat: @"</%@>", tag];
	NSMutableString *plainString = [self mutableString];
	NSRange openTagRange = [plainString rangeOfString: openTag];
	if (openTagRange.length == 0) {
		return;
	}
	[self deleteCharactersInRange: openTagRange];
	
	NSRange closeTagRange = [plainString rangeOfString: closeTag options: NSBackwardsSearch];
	if (closeTagRange.length == 0) {
		return;
	}
	[self deleteCharactersInRange: closeTagRange];
	
	NSRange attributeRange = NSMakeRange(openTagRange.location, closeTagRange.location - openTagRange.location);
	[self addAttributes: attributes range: attributeRange];
}

-(void)replaceHTMLBreakWithNewline {
	while (true) {
		NSRange range = [[self string] rangeOfString: @"<br>"];
		if (range.length == 0) {
			break;
		}
		[self replaceCharactersInRange: range withString: @"\n"];
	}
}

-(void)replaceHTMLLinksWithText {
	NSError *error = [NSError alloc];
	NSRegularExpression *regexp = [[NSRegularExpression alloc] 
		initWithPattern: @"(<a href=\".+\">).*(<\\/a>)"
		options: 0
		error: &error
	];

	while (true) {
		NSTextCheckingResult *result = [regexp firstMatchInString: 
			[self string]
			options: 0
			range: NSMakeRange(0, [[self string] length])];
		if (result == nil) {
			break;
		}
		NSRange first = [result rangeAtIndex: 1];
		NSRange last = [result rangeAtIndex: 2];
		[self deleteCharactersInRange: first];
		last.location -= first.length;
		[self deleteCharactersInRange: last];
		 
	}
	[regexp release];
	[error release];
}

-(void)replaceURLEncodingsOf: (NSString*)encoding withSymbol: (NSString*)symbol {
	while (true) {
		NSString *string = [self string];
		NSRange range = [string rangeOfString: encoding];
		if (range.length <= 0) {
			break;
		}
		[self replaceCharactersInRange: range withString: symbol];
	}
}

-(void)replaceHTMLSpanOfClass: (NSString*)class withAttributes: (NSDictionary*)attributes {
	NSError *error = [NSError alloc];
	NSString *pattern = [NSString stringWithFormat: @"(<span class=\"%@\">).*(</span>)", class];
	NSRegularExpression *regexp = [[NSRegularExpression alloc] 
		initWithPattern: pattern
		options: 0
		error: &error
	];

	while (true) {
		NSTextCheckingResult *result = [regexp firstMatchInString: 
			[self string]
			options: 0
			range: NSMakeRange(0, [[self string] length])];
		if (result == nil) {
			break;
		}
		NSRange first = [result rangeAtIndex: 1];
		NSRange last = [result rangeAtIndex: 2];
		[self deleteCharactersInRange: first];
		last.location -= first.length;
		[self deleteCharactersInRange: last];
		[self setAttributes: attributes range: NSMakeRange(first.location, last.location - first.location)];
		 
	}
	[regexp release];
	[error release];
}

@end


@implementation NSAttributedString (HTML)

+(NSAttributedString*)attributedStringFromHTMLString: (NSString*)htmlString {
	if (htmlString == nil) {
		return nil;
	}
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString: htmlString attributes: [NSAttributedString normalAttributes]];
	[string replaceURLEncodingsOf: @"&gt;" withSymbol: @">"];
	[string replaceURLEncodingsOf: @"&#039;" withSymbol: @"'"];
	[string replaceURLEncodingsOf: @"&quot;" withSymbol: @"\""];
	[string replaceURLEncodingsOf: @"&amp;" withSymbol: @"&"];
	[string replaceHTMLBreakWithNewline];
	[string replaceHTMLLinksWithText];
	[string replaceHTMLTag: @"b" withAttributes: [NSAttributedString htmlBoldAttributes]];
	[string replaceHTMLTag: @"u" withAttributes: [NSAttributedString htmlUnderlineAttributes]];
	[string replaceHTMLSpanOfClass: @"quote" withAttributes: [NSAttributedString htmlQuoteAttributes]];
	[string autorelease];
	return string;
}

+(NSDictionary*)normalAttributes {
	return [NSDictionary dictionaryWithObjectsAndKeys: 
		[NSFont appBodyFont], NSFontAttributeName, nil
	];
}

+(NSDictionary*)htmlBoldAttributes {
	return [NSDictionary dictionaryWithObjectsAndKeys: 
		[NSFont appBoldBodyFont], NSFontAttributeName, nil
	];
}

+(NSDictionary*)htmlUnderlineAttributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt: NSUnderlineStyleSingle], NSUnderlineStyleAttributeName, nil
	];
}

+(NSDictionary*)htmlQuoteAttributes {
	NSColor *color = [NSColor colorWithDeviceRed: 0.3 green: 0.65 blue: 0.07 alpha: 1.0];
	return [NSDictionary dictionaryWithObjectsAndKeys: color, 
		NSForegroundColorAttributeName, nil
	];
}

@end

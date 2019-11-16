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
#import "NSFont+AppFont.h"
#import "NSAttributedString+AppAttributes.h"

@implementation NSAttributedString (AppAttributes)


+(NSDictionary*)normalAttributes {
	return [NSDictionary dictionaryWithObjectsAndKeys: 
		[NSFont appBodyFont], NSFontAttributeName, nil
	];
}

+(NSDictionary*)postBoldAttributes {
	return [NSDictionary dictionaryWithObjectsAndKeys: 
		[NSFont appBoldBodyFont], NSFontAttributeName, nil
	];
}

+(NSDictionary*)postUnderlineAttributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt: NSUnderlineStyleSingle], NSUnderlineStyleAttributeName, nil
	];
}

+(NSDictionary*)postQuoteAttributes {
	NSColor *color = [NSColor colorWithDeviceRed: 0.3 green: 0.65 blue: 0.07 alpha: 1.0];
	return [NSDictionary dictionaryWithObjectsAndKeys: color, 
		NSForegroundColorAttributeName, nil
	];
}

+(NSDictionary*)postSubjectAttributes {
	NSColor *color = [NSColor colorWithDeviceRed: 0.05 green: 0.05 
		blue: 0.4 alpha: 1.0];
	return [NSDictionary dictionaryWithObjectsAndKeys: color,
		NSForegroundColorAttributeName, nil];
}

+(NSDictionary*)postNameAttributes {
	NSColor *color = [NSColor colorWithDeviceRed: 0.05 green: 0.5 
		blue: 0.2 alpha: 1.0];
	return [NSDictionary dictionaryWithObjectsAndKeys: color,
		NSForegroundColorAttributeName, nil];
}

+(NSDictionary*)postDateAttributes {
	return [NSAttributedString normalAttributes];
}

+(NSDictionary*)postNumberAttributes {
	return [NSAttributedString normalAttributes];
}

+(NSDictionary*)linkAttributesForLink: (NSString*)link {
	return [NSDictionary dictionaryWithObjectsAndKeys: 
		link, NSLinkAttributeName, nil
	];
}

@end

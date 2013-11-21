//
//  RKSyntaxView.m
//
//
//  Created by Vojto Rinik on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RKSyntaxView.h"
#import "NSColor+HexRGB.h"

@implementation RKSyntaxView

#pragma mark - Lifecycle

- (id)init {
    if ((self = [super init])) {
        [self _setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self _setup];
}

- (void)_setup {
    [self setTextContainerInset:NSMakeSize(10.0, 10.0)];
    [self highlight];
    
    [self addObserver:self forKeyPath:@"string" options:0 context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textDidChange:) name:NSTextDidChangeNotification object:self];
}

- (void) dealloc {
    [super dealloc];
}

#pragma mark - Handling text changes

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self highlight];
}

- (void)_textDidChange:(NSNotification *)notif {
    [self highlightChangedRange];
}

#pragma mark - Scheme

- (void)loadScheme:(NSString *)schemeFilename {
    NSString *schemePath = [[NSBundle mainBundle] pathForResource:schemeFilename ofType:@"plist" inDirectory:nil];
    self.scheme = [NSDictionary dictionaryWithContentsOfFile:schemePath];
}

- (NSColor *) _colorFor:(NSString *)key {
    NSString *colorCode = [[self.scheme objectForKey:@"colors"] objectForKey:key];
    if (!colorCode) return nil;
    NSColor *color = [NSColor colorFromHexRGB:colorCode];
    return color;
}

- (NSFont *) _font {
    return [self _fontOfSize:12 bold:NO italic:NO];
}

- (NSFont *) _fontOfSize:(NSInteger)size bold:(BOOL)wantsBold italic:(BOOL)wantsItalic {
    NSString *fontName = [self.scheme objectForKey:@"font"];
    NSFont *font = [NSFont fontWithName:fontName size:size];
    if (!font) font = [NSFont systemFontOfSize:size];
    
    if (wantsBold) {
        NSFontTraitMask traits = NSBoldFontMask;
        NSFontManager *manager = [NSFontManager sharedFontManager];
        font = [manager fontWithFamily:fontName traits:traits weight:5.0 size:size];
    }
    
    if (wantsItalic) {
        NSFontTraitMask traits = NSItalicFontMask;
        NSFontManager *manager = [NSFontManager sharedFontManager];
        font = [manager fontWithFamily:fontName traits:traits weight:5.0 size:size];
    }
    
    return font;
}

- (NSInteger) _defaultSize {
    NSInteger defaultSize = [(NSNumber *)[self.scheme objectForKey:@"size"] integerValue];
    if (!defaultSize) defaultSize = 12;
    return defaultSize;
}

#pragma mark - Syntax

- (void)loadSyntax:(NSString *)syntaxFilename {
    NSString *schemePath = [[NSBundle mainBundle] pathForResource:syntaxFilename ofType:@"plist" inDirectory:nil];
    self.syntax = [NSDictionary dictionaryWithContentsOfFile:schemePath];
}

#pragma mark - Highlighting

- (void) highlight {
    //    self.content = [[NSMutableAttributedString alloc] initWithString:[self string]];
    //    [self.content release];
    
    NSColor *background = [self _colorFor:@"background"];
    NSInteger defaultSize = [self _defaultSize];
    NSFont *defaultFont = [self _fontOfSize:defaultSize bold:NO italic:NO];
    [self setBackgroundColor:background];
    [(NSScrollView *)self.superview setBackgroundColor:background];
    [self setTextColor:[self _colorFor:@"default"]];
    [self setFont:defaultFont];
    
    NSMutableAttributedString *textStorage = [self textStorage];
    NSRange range = NSMakeRange(0, [textStorage length]);
    [self highlightRange:range content:textStorage];
}

- (void)highlightChangedRange {
    NSRange range = [self rangeForUserTextChange];
    NSRange lineRange = [[self string] lineRangeForRange:range];
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSinceReferenceDate];
    if (!_lastDocumentHighlight || (timestamp - _lastDocumentHighlight) > 999) { // This doesn't really work as expected.
        [self highlight];
        _lastDocumentHighlight = timestamp;
    } else {
        [self highlightRange:lineRange content:[self textStorage]];
    }
}

- (void)highlightRange:(NSRange)range {
    [self highlightRange:range content:self.textStorage];
}

- (void) highlightRange:(NSRange)range content:(NSMutableAttributedString *)content {
    NSColor *defaultColor = [self _colorFor:@"default"];
    NSInteger defaultSize = [self _defaultSize];
    NSFont *defaultFont = [self _fontOfSize:defaultSize bold:NO italic:NO];
    [self _setFont:defaultFont range:range content:content];
    [self _setTextColor:defaultColor range:range content:content];
    [self _setBackgroundColor:[NSColor clearColor] range:range content:content];
    
    NSString *string = [content string];
    
    for (NSString *type in [self.syntax allKeys]) {
        NSDictionary *params = [self.syntax objectForKey:type];
        NSString *pattern = [params objectForKey:@"pattern"];
        NSString *colorName = [params objectForKey:@"color"];
        NSColor *color = [self _colorFor:colorName];
        NSString *backgroundColorName = [params objectForKey:@"backgroundColor"];
        NSColor *backgroundColor = [self _colorFor:backgroundColorName];
        NSInteger size = [(NSNumber *)[params objectForKey:@"size"] integerValue];
        BOOL isBold = [(NSNumber *)[params objectForKey:@"isBold"] boolValue];
        BOOL isItalic = [[params objectForKey:@"isItalic"] boolValue];
        NSFont *font = [self _fontOfSize:(size ? size : defaultSize) bold:isBold italic:isItalic];
        NSInteger patternGroup = [(NSNumber *)[params objectForKey:@"patternGroup"] integerValue];
        
        NSError *error = nil;
        NSRegularExpression *expr = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines) error:&error]; // FIXME: We need to cache the compiled NSRegularExpression objects
        NSArray *matches = [expr matchesInString:string options:0 range:range];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = patternGroup ? [match rangeAtIndex:patternGroup] : [match range];
            [self _setTextColor:color range:range content:content];
            if (backgroundColor) {
				[self _setBackgroundColor:backgroundColor
									range:range
								  content:content];
			}
            [self _setFont:font range:range content:content];
        }
    }
}

#pragma mark - Changing text attributes

- (void) _setTextColor:(NSColor *)color range:(NSRange)range content:(NSMutableAttributedString *)content {
    if (!color) return;
    [content addAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void) _setBackgroundColor:(NSColor *)color range:(NSRange)range content:(NSMutableAttributedString *)content {
    [content addAttribute:NSBackgroundColorAttributeName value:color range:range];
}

- (void) _setFont:(NSFont *)font range:(NSRange)range content:(NSMutableAttributedString *)content {
    [content addAttribute:NSFontAttributeName value:font range:range];
}

#pragma mark - Pasting

- (void)paste:(id)sender {
    [super paste:sender];
    [self highlight];
}

@end

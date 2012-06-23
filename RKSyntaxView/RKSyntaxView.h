//
//  RKSyntaxView.h
//  
//
//  Created by Vojto Rinik on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


// TODO:
// this view uses observing of `string` (content) to run whole-document
// highlight. If your text view is configured to update with each keystroke,
// that could be a problem. 

@interface RKSyntaxView : NSTextView {
    NSDictionary *_scheme;
    NSDictionary *_syntax;
    
    NSTimeInterval _lastDocumentHighlight;
}

@property (retain) NSDictionary *scheme;
@property (retain) NSDictionary *syntax;

@property (nonatomic, retain) NSString* defaultSchemePath;
@property (nonatomic, retain) NSString* defaultSyntaxPath;


- (id) initWithDefaultSchemePath:(NSString *)schemePath andSyntaxPath:(NSString *)syntaxPath; // do not use with Nibs

- (void) _setup;

#pragma mark - Handling text change
- (void) _textDidChange:(NSNotification *)notif;

#pragma mark - Highlighting
- (void) highlight;
- (void) highlightChangedRange;
- (void) highlightRange:(NSRange)range content:(NSMutableAttributedString *)content;

#pragma mark - Scheme
- (void) loadScheme:(NSString *)schemeFilename;
- (NSColor *) _colorFor:(NSString *)key;
- (NSFont *) _font;
- (NSFont *) _fontOfSize:(NSInteger)size bold:(BOOL)wantsBold;
- (NSInteger) _defaultSize;

#pragma mark - Syntax
- (void) loadSyntax:(NSString *)syntaxFilename;

#pragma mark - Changing text attributes
- (void) _setTextColor:(NSColor *)color range:(NSRange)range content:(NSMutableAttributedString *)content;
- (void) _setBackgroundColor:(NSColor *)color range:(NSRange)range content:(NSMutableAttributedString *)content;
- (void) _setFont:(NSFont *)font range:(NSRange)range content:(NSMutableAttributedString *)content;




@end

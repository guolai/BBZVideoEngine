//
//  NSDictionary+BBZVE.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/11/16.
//  Copyright © 2020 HaiboZhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (BBZVE)
#pragma mark - Dictionary Convertor
///=============================================================================
/// @name Dictionary Convertor
///=============================================================================

/**
 Creates and returns a dictionary from a specified property list data.
 
 @param plist   A property list data whose root object is a dictionary.
 @return A new dictionary created from the binary plist data, or nil if an error occurs.
 */
+ (nullable NSDictionary *)BBZVEdictionaryWithPlistData:(NSData *)plist;

/**
 Creates and returns a dictionary from a specified property list xml string.
 
 @param plist   A property list xml string whose root object is a dictionary.
 @return A new dictionary created from the plist string, or nil if an error occurs.
 
 @discussion Apple has implemented this method, but did not make it public.
 */
+ (nullable NSDictionary *)BBZVEdictionaryWithPlistString:(NSString *)plist;

/**
 Serialize the dictionary to a binary property list data.
 
 @return A binary plist data, or nil if an error occurs.
 
 @discussion Apple has implemented this method, but did not make it public.
 */
- (nullable NSData *)BBZVEplistData;

/**
 Serialize the dictionary to a xml property list string.
 
 @return A plist xml string, or nil if an error occurs.
 */
- (nullable NSString *)BBZVEplistString;

/**
 Returns a new array containing the dictionary's keys sorted.
 The keys should be NSString, and they will be sorted ascending.
 
 @return A new array containing the dictionary's keys,
 or an empty array if the dictionary has no entries.
 */
- (NSArray *)BBZVEallKeysSorted;

/**
 Returns a new array containing the dictionary's values sorted by keys.
 
 The order of the values in the array is defined by keys.
 The keys should be NSString, and they will be sorted ascending.
 
 @return A new array containing the dictionary's values sorted by keys,
 or an empty array if the dictionary has no entries.
 */
- (NSArray *)BBZVEallValuesSortedByKeys;

/**
 Returns a BOOL value tells if the dictionary has an object for key.
 
 @param key The key.
 */
- (BOOL)BBZVEcontainsObjectForKey:(id)key;

/**
 Returns a new dictionary containing the entries for keys.
 If the keys is empty or nil, it just returns an empty dictionary.
 
 @param keys The keys.
 @return The entries for the keys.
 */
- (NSDictionary *)BBZVEentriesForKeys:(NSArray *)keys;

/**
 Convert dictionary to json string. return nil if an error occurs.
 */
- (nullable NSString *)BBZVEjsonStringEncoded;

/**
 Convert dictionary to json string formatted. return nil if an error occurs.
 */
- (nullable NSString *)BBZVEjsonPrettyStringEncoded;

/**
 Try to parse an XML and wrap it into a dictionary.
 If you just want to get some value from a small xml, try this.
 
 example XML: "<config><a href="test.com">link</a></config>"
 example Return: @{@"_name":@"config", @"a":{@"_text":@"link",@"href":@"test.com"}}
 
 @param xmlDataOrString XML in NSData or NSString format.
 @return Return a new dictionary, or nil if an error occurs.
 */
+ (nullable NSDictionary *)BBZVEdictionaryWithXML:(id)xmlDataOrString;

#pragma mark - Dictionary Value Getter
///=============================================================================
/// @name Dictionary Value Getter
///=============================================================================

- (BOOL)BBZVEboolValueForKey:(NSString *)key default:(BOOL)def;

- (char)BBZVEcharValueForKey:(NSString *)key default:(char)def;
- (unsigned char)BBZVEunsignedCharValueForKey:(NSString *)key default:(unsigned char)def;

- (short)BBZVEshortValueForKey:(NSString *)key default:(short)def;
- (unsigned short)BBZVEunsignedShortValueForKey:(NSString *)key default:(unsigned short)def;

- (int)BBZVEintValueForKey:(NSString *)key default:(int)def;
- (unsigned int)BBZVEunsignedIntValueForKey:(NSString *)key default:(unsigned int)def;

- (long)BBZVElongValueForKey:(NSString *)key default:(long)def;
- (unsigned long)BBZVEunsignedLongValueForKey:(NSString *)key default:(unsigned long)def;

- (long long)BBZVElongLongValueForKey:(NSString *)key default:(long long)def;
- (unsigned long long)BBZVEunsignedLongLongValueForKey:(NSString *)key default:(unsigned long long)def;

- (float)BBZVEfloatValueForKey:(NSString *)key default:(float)def;
- (float)BBZVEfloatValueForKey2:(NSString *)key default:(float)def;
- (double)BBZVEdoubleValueForKey:(NSString *)key default:(double)def;
- (double)BBZVEdoubleValueForKey2:(NSString *)key default:(double)def;

- (NSInteger)BBZVEintegerValueForKey:(NSString *)key default:(NSInteger)def;
- (NSUInteger)BBZVEunsignedIntegerValueForKey:(NSString *)key default:(NSUInteger)def;

- (nullable NSNumber *)BBZVEnumberValueForKey:(NSString *)key default:(nullable NSNumber *)def;
- (nullable NSString *)BBZVEstringValueForKey:(NSString *)key default:(nullable NSString *)def;

@end



/**
 Provide some some common method for `NSMutableDictionary`.
 */
@interface NSMutableDictionary (BBZVE)

/**
 Creates and returns a dictionary from a specified property list data.
 
 @param plist   A property list data whose root object is a dictionary.
 @return A new dictionary created from the binary plist data, or nil if an error occurs.
 
 @discussion Apple has implemented this method, but did not make it public.
 */
+ (nullable NSMutableDictionary *)BBZVEdictionaryWithPlistData:(NSData *)plist;

/**
 Creates and returns a dictionary from a specified property list xml string.
 
 @param plist   A property list xml string whose root object is a dictionary.
 @return A new dictionary created from the plist string, or nil if an error occurs.
 */
+ (nullable NSMutableDictionary *)BBZVEdictionaryWithPlistString:(NSString *)plist;


/**
 Removes and returns the value associated with a given key.
 
 @param aKey The key for which to return and remove the corresponding value.
 @return The value associated with aKey, or nil if no value is associated with aKey.
 */
- (nullable id)BBZVEpopObjectForKey:(id)aKey;

/**
 Returns a new dictionary containing the entries for keys, and remove these
 entries from receiver. If the keys is empty or nil, it just returns an
 empty dictionary.
 
 @param keys The keys.
 @return The entries for the keys.
 */
- (NSDictionary *)BBZVEpopEntriesForKeys:(NSArray *)keys;

@end

NS_ASSUME_NONNULL_END


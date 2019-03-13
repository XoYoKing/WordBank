//
//  JSONModel.m
//  JSONModel
//

#if !__has_feature(objc_arc)
#error The JSONMOdel framework is ARC only, you can enable ARC on per file basis.
#endif


#import <objc/runtime.h>
#import <objc/message.h>


#import "JSONModel.h"
#import "JSONModelClassProperty.h"

#pragma mark - associated objects names
static const char * kMapperObjectKey;
static const char * kClassPropertiesKey;
static const char * kClassRequiredPropertyNamesKey;
static const char * kIndexPropertyNameKey;

#pragma mark - class static variables
static NSArray* allowedJSONTypes = nil;
static NSArray* allowedPrimitiveTypes = nil;
static JSONValueTransformer* valueTransformer = nil;
static Class JSONModelClass = NULL;

#pragma mark - model cache
static JSONKeyMapper* globalKeyMapper = nil;

#pragma mark - JSONModel implementation
@implementation JSONModel
{
    NSString* _description;
}

#pragma mark - initialization methods

+(void)load
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // initialize all class static objects,
        // which are common for ALL JSONModel subclasses

        @autoreleasepool {
            // 定义兼容的对象类型
            allowedJSONTypes = @[
                [NSString class], [NSNumber class], [NSDecimalNumber class], [NSArray class], [NSDictionary class], [NSNull class], //immutable JSON classes
                [NSMutableString class], [NSMutableArray class], [NSMutableDictionary class] //mutable JSON classes
            ];

            // 定义兼容的基本数据类型
            allowedPrimitiveTypes = @[
                @"BOOL", @"float", @"int", @"long", @"double", @"short",
                @"unsigned int", @"usigned long", @"long long", @"unsigned long long", @"unsigned short", @"char", @"unsigned char",
                //and some famous aliases
                @"NSInteger", @"NSUInteger",
                @"Block"
            ];

            // 初始化值类型转换器，用来调用一个内置的值类型转换
            valueTransformer = [[JSONValueTransformer alloc] init];

            // This is quite strange, but I found the test isSubclassOfClass: (line ~291) to fail if using [JSONModel class].
            // somewhat related: https://stackoverflow.com/questions/6524165/nsclassfromstring-vs-classnamednsstring
            // //; seems to break the unit tests

            // Using NSClassFromString instead of [JSONModel class], as this was breaking unit tests, see below
            //http://stackoverflow.com/questions/21394919/xcode-5-unit-test-seeing-wrong-class
            JSONModelClass = NSClassFromString(NSStringFromClass(self));
        }
    });
}

-(void)__setup__
{
    //if first instance of this model, generate the property list
    // 第一次实例化的时候，类对象上没有kClassPropertiesKey这个关联对象，调用[self __inspectPropertids]去添加
    if (!objc_getAssociatedObject(self.class, &kClassPropertiesKey)) {
        [self __inspectProperties];
    }

    //if there's a custom key mapper, store it in the associated object
    /*
     * 如果存在自定的的key mapper
     * 就是定义model是去覆写+ keyMapper返回自定义的key mapper
     * 把自定义的key mapper存储到类对象的关联对象
     */
    id mapper = [[self class] keyMapper];
    if ( mapper && !objc_getAssociatedObject(self.class, &kMapperObjectKey) ) {
        objc_setAssociatedObject(
                                 self.class,
                                 &kMapperObjectKey,
                                 mapper,
                                 OBJC_ASSOCIATION_RETAIN // This is atomic
                                 );
    }
}

-(id)init
{
    self = [super init];
    if (self) {
        //do initial class setup
        [self __setup__];
    }
    return self;
}

-(instancetype)initWithData:(NSData *)data error:(NSError *__autoreleasing *)err
{
    //check for nil input
    if (!data) {
        if (err) *err = [JSONModelError errorInputIsNil];
        return nil;
    }
    //read the json
    JSONModelError* initError = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data
                                             options:kNilOptions
                                               error:&initError];

    if (initError) {
        if (err) *err = [JSONModelError errorBadJSON];
        return nil;
    }

    //init with dictionary
    id objModel = [self initWithDictionary:obj error:&initError];
    if (initError && err) *err = initError;
    return objModel;
}

-(id)initWithString:(NSString*)string error:(JSONModelError**)err
{
    JSONModelError* initError = nil;
    id objModel = [self initWithString:string usingEncoding:NSUTF8StringEncoding error:&initError];
    if (initError && err) *err = initError;
    return objModel;
}

-(id)initWithString:(NSString *)string usingEncoding:(NSStringEncoding)encoding error:(JSONModelError**)err
{
    //check for nil input
    if (!string) {
        if (err) *err = [JSONModelError errorInputIsNil];
        return nil;
    }

    JSONModelError* initError = nil;
    id objModel = [self initWithData:[string dataUsingEncoding:encoding] error:&initError];
    if (initError && err) *err = initError;
    return objModel;

}

/*
 * json -> model 最终调用方法
 * 1. 检查传入字典是否为空
 * 2. 检查传入数据类型是否为NSDictionary
 * 3. 处理model
 * 4. 检查字典与定义的model的key是否匹配
 */
-(id)initWithDictionary:(NSDictionary*)dict error:(NSError**)err
{
    //check for nil input
    /*
     * 检查传入的字典是否为空
     */
    if (!dict) {
        if (err) *err = [JSONModelError errorInputIsNil];
        return nil;
    }
    
    /*
     * 检查传入的数据是否为NSDictionary
     */
    //invalid input, just create empty instance
    if (![dict isKindOfClass:[NSDictionary class]]) {
        if (err) *err = [JSONModelError errorInvalidDataWithMessage:@"Attempt to initialize JSONModel object using initWithDictionary:error: but the dictionary parameter was not an 'NSDictionary'."];
        return nil;
    }

    //create a class instance
    /*
     * 初始化JSONModel的调用栈
     * 1. [JSONModel __setup__]
     * 2. [JSONModel _inspectProperties]
     */
    self = [self init];
    if (!self) {

        //super init didn't succeed
        if (err) *err = [JSONModelError errorModelIsInvalid];
        return nil;
    }

    //check incoming data structure
    /*
     * 检查json数据结构与定义的Model是否匹配
     */
    if (![self __doesDictionary:dict matchModelWithKeyMapper:self.__keyMapper error:err]) {
        return nil;
    }

    //import the data from a dictionary
    /*
     * 从json导数据到model
     */
    if (![self __importDictionary:dict withKeyMapper:self.__keyMapper validation:YES error:err]) {
        return nil;
    }

    //run any custom model validation
    if (![self validate:err]) {
        return nil;
    }

    //model is valid! yay!
    return self;
}

-(JSONKeyMapper*)__keyMapper
{
    //get the model key mapper
    return objc_getAssociatedObject(self.class, &kMapperObjectKey);
}

-(BOOL)__doesDictionary:(NSDictionary*)dict matchModelWithKeyMapper:(JSONKeyMapper*)keyMapper error:(NSError**)err
{
    //check if all required properties are present
    //取出传入字典的所有key和model的必需字段的名称集合
    NSArray* incomingKeysArray = [dict allKeys];
    NSMutableSet* requiredProperties = [self __requiredPropertyNames].mutableCopy;
    NSSet* incomingKeys = [NSSet setWithArray: incomingKeysArray];

    //transform the key names, if necessary
    // 如果定义了keyMapper，遍历所有属性做映射
    if (keyMapper || globalKeyMapper) {

        NSMutableSet* transformedIncomingKeys = [NSMutableSet setWithCapacity: requiredProperties.count];
        NSString* transformedName = nil;

        //loop over the required properties list
        for (JSONModelClassProperty* property in [self __properties__]) {

            // 映射的属性名
            transformedName = (keyMapper||globalKeyMapper) ? [self __mapString:property.name withKeyMapper:keyMapper] : property.name;

            //check if exists and if so, add to incoming keys
            //去传入的字典里查找有没有该keyPath
            id value;
            @try {
                value = [dict valueForKeyPath:transformedName];
            }
            @catch (NSException *exception) {
                value = dict[transformedName];
            }

            if (value) {
                [transformedIncomingKeys addObject: property.name];
            }
        }

        //overwrite the raw incoming list with the mapped key names
        incomingKeys = transformedIncomingKeys;
    }

    //check for missing input keys
    //确认model的属性名集合是传入字典key集合的子集
    if (![requiredProperties isSubsetOfSet:incomingKeys]) {

        //get a list of the missing properties
        [requiredProperties minusSet:incomingKeys];

        //not all required properties are in - invalid input
        JMLog(@"Incoming data was invalid [%@ initWithDictionary:]. Keys missing: %@", self.class, requiredProperties);

        if (err) *err = [JSONModelError errorInvalidDataWithMissingKeys:requiredProperties];
        return NO;
    }

    //not needed anymore
    incomingKeys= nil;
    requiredProperties= nil;

    return YES;
}

-(NSString*)__mapString:(NSString*)string withKeyMapper:(JSONKeyMapper*)keyMapper
{
    if (keyMapper) {
        //custom mapper
        NSString* mappedName = [keyMapper convertValue:string];
        if (globalKeyMapper && [mappedName isEqualToString: string]) {
            mappedName = [globalKeyMapper convertValue:string];
        }
        string = mappedName;
    } else if (globalKeyMapper) {
        //global keymapper
        string = [globalKeyMapper convertValue:string];
    }

    return string;
}

-(BOOL)__importDictionary:(NSDictionary*)dict withKeyMapper:(JSONKeyMapper*)keyMapper validation:(BOOL)validation error:(NSError**)err
{
    //loop over the incoming keys and set self's properties
    // 遍历model的属性列表
    for (JSONModelClassProperty* property in [self __properties__]) {

        //convert key name to model keys, if a mapper is provided
        // 如果提供了keymapper，取出该属性名映射的keyPath
        NSString* jsonKeyPath = (keyMapper||globalKeyMapper) ? [self __mapString:property.name withKeyMapper:keyMapper] : property.name;
        //JMLog(@"keyPath: %@", jsonKeyPath);

        //general check for data type compliance
        //从dict中取出keyPath对应的value
        id jsonValue;
        @try {
            jsonValue = [dict valueForKeyPath: jsonKeyPath];
        }
        @catch (NSException *exception) {
            jsonValue = dict[jsonKeyPath];
        }

        //check for Optional properties
        if (isNull(jsonValue)) {
            //skip this property, continue with next property
            //如果属性是可选的，则跳过该属性
            if (property.isOptional || !validation) continue;

            if (err) {
                //null value for required property
                //传入的字典给model中必须的属性提供了空值，抛出错误
                NSString* msg = [NSString stringWithFormat:@"Value of required model key %@ is null", property.name];
                JSONModelError* dataErr = [JSONModelError errorInvalidDataWithMessage:msg];
                *err = [dataErr errorByPrependingKeyPathComponent:property.name];
            }
            return NO;
        }

        // 判断值的类型是不是可兼容的对象类型
        Class jsonValueClass = [jsonValue class];
        BOOL isValueOfAllowedType = NO;

        for (Class allowedType in allowedJSONTypes) {
            if ( [jsonValueClass isSubclassOfClass: allowedType] ) {
                isValueOfAllowedType = YES;
                break;
            }
        }

        // 不是兼容的对象类型，抛出错误
        if (isValueOfAllowedType==NO) {
            //type not allowed
            JMLog(@"Type %@ is not allowed in JSON.", NSStringFromClass(jsonValueClass));

            if (err) {
                NSString* msg = [NSString stringWithFormat:@"Type %@ is not allowed in JSON.", NSStringFromClass(jsonValueClass)];
                JSONModelError* dataErr = [JSONModelError errorInvalidDataWithMessage:msg];
                *err = [dataErr errorByPrependingKeyPathComponent:property.name];
            }
            return NO;
        }

        //check if there's matching property in the model
        if (property) {

            // check for custom setter, than the model doesn't need to do any guessing
            // how to read the property's value from JSON
            // 存在自定义setter方法，使用自定义setter方法赋值
            if ([self __customSetValue:jsonValue forProperty:property]) {
                //skip to next JSON key
                continue;
            };

            // 0) handle primitives
            // 处理基本数据类型
            if (property.type == nil && property.structName==nil) {

                //generic setter
                // kvc赋值
                if (jsonValue != [self valueForKey:property.name]) {
                    [self setValue:jsonValue forKey: property.name];
                }

                //skip directly to the next key
                continue;
            }

            // 0.5) handle nils
            // 处理空值
            if (isNull(jsonValue)) {
                if ([self valueForKey:property.name] != nil) {
                    [self setValue:nil forKey: property.name];
                }
                continue;
            }


            // 1) check if property is itself a JSONModel
            // 属性是一个JSONModel
            if ([self __isJSONModelSubClass:property.type]) {

                //initialize the property's model, store it
                JSONModelError* initErr = nil;
                id value = [[property.type alloc] initWithDictionary:jsonValue error:&initErr];

                if (!value) {
                    //skip this property, continue with next property
                    if (property.isOptional || !validation) continue;

                    // Propagate the error, including the property name as the key-path component
                    if((err != nil) && (initErr != nil))
                    {
                        *err = [initErr errorByPrependingKeyPathComponent:property.name];
                    }
                    return NO;
                }
                if (![value isEqual:[self valueForKey:property.name]]) {
                    [self setValue:value forKey: property.name];
                }

                //for clarity, does the same without continue
                continue;

            } else {

                // 2) check if there's a protocol to the property
                //  ) might or not be the case there's a built in transform for it
                if (property.protocol) {

                    //JMLog(@"proto: %@", p.protocol);
                    jsonValue = [self __transform:jsonValue forProperty:property error:err];
                    if (!jsonValue) {
                        if ((err != nil) && (*err == nil)) {
                            NSString* msg = [NSString stringWithFormat:@"Failed to transform value, but no error was set during transformation. (%@)", property];
                            JSONModelError* dataErr = [JSONModelError errorInvalidDataWithMessage:msg];
                            *err = [dataErr errorByPrependingKeyPathComponent:property.name];
                        }
                        return NO;
                    }
                }

                // 3.1) handle matching standard JSON types
                if (property.isStandardJSONType && [jsonValue isKindOfClass: property.type]) {

                    //mutable properties
                    if (property.isMutable) {
                        jsonValue = [jsonValue mutableCopy];
                    }

                    //set the property value
                    if (![jsonValue isEqual:[self valueForKey:property.name]]) {
                        [self setValue:jsonValue forKey: property.name];
                    }
                    continue;
                }

                // 3.3) handle values to transform
                if (
                    (![jsonValue isKindOfClass:property.type] && !isNull(jsonValue))
                    ||
                    //the property is mutable
                    property.isMutable
                    ||
                    //custom struct property
                    property.structName
                    ) {

                    // searched around the web how to do this better
                    // but did not find any solution, maybe that's the best idea? (hardly)
                    Class sourceClass = [JSONValueTransformer classByResolvingClusterClasses:[jsonValue class]];

                    //JMLog(@"to type: [%@] from type: [%@] transformer: [%@]", p.type, sourceClass, selectorName);

                    // 类型转换的SEL拼装
                    //build a method selector for the property and json object classes
                    NSString* selectorName = [NSString stringWithFormat:@"%@From%@:",
                                              (property.structName? property.structName : property.type), //target name
                                              sourceClass]; //source name
                    SEL selector = NSSelectorFromString(selectorName);

                    //check for custom transformer
                    BOOL foundCustomTransformer = NO;
                    if ([valueTransformer respondsToSelector:selector]) {
                        foundCustomTransformer = YES;
                    } else {
                        //try for hidden custom transformer
                        selectorName = [NSString stringWithFormat:@"__%@",selectorName];
                        selector = NSSelectorFromString(selectorName);
                        if ([valueTransformer respondsToSelector:selector]) {
                            foundCustomTransformer = YES;
                        }
                    }

                    //check if there's a transformer with that name
                    if (foundCustomTransformer) {
                        IMP imp = [valueTransformer methodForSelector:selector];
                        id (*func)(id, SEL, id) = (void *)imp;
                        jsonValue = func(valueTransformer, selector, jsonValue);

                        if (![jsonValue isEqual:[self valueForKey:property.name]])
                            [self setValue:jsonValue forKey:property.name];
                    } else {
                        if (err) {
                            NSString* msg = [NSString stringWithFormat:@"%@ type not supported for %@.%@", property.type, [self class], property.name];
                            JSONModelError* dataErr = [JSONModelError errorInvalidDataWithTypeMismatch:msg];
                            *err = [dataErr errorByPrependingKeyPathComponent:property.name];
                        }
                        return NO;
                    }
                } else {
                    // 3.4) handle "all other" cases (if any)
                    if (![jsonValue isEqual:[self valueForKey:property.name]])
                        [self setValue:jsonValue forKey:property.name];
                }
            }
        }
    }

    return YES;
}

#pragma mark - property inspection methods

-(BOOL)__isJSONModelSubClass:(Class)class
{
// http://stackoverflow.com/questions/19883472/objc-nsobject-issubclassofclass-gives-incorrect-failure
#ifdef UNIT_TESTING
    return [@"JSONModel" isEqualToString: NSStringFromClass([class superclass])];
#else
    return [class isSubclassOfClass:JSONModelClass];
#endif
}

//returns a set of the required keys for the model
-(NSMutableSet*)__requiredPropertyNames
{
    //fetch the associated property names
    NSMutableSet* classRequiredPropertyNames = objc_getAssociatedObject(self.class, &kClassRequiredPropertyNamesKey);

    if (!classRequiredPropertyNames) {
        classRequiredPropertyNames = [NSMutableSet set];
        [[self __properties__] enumerateObjectsUsingBlock:^(JSONModelClassProperty* p, NSUInteger idx, BOOL *stop) {
            if (!p.isOptional) [classRequiredPropertyNames addObject:p.name];
        }];

        //persist the list
        objc_setAssociatedObject(
                                 self.class,
                                 &kClassRequiredPropertyNamesKey,
                                 classRequiredPropertyNames,
                                 OBJC_ASSOCIATION_RETAIN // This is atomic
                                 );
    }
    return classRequiredPropertyNames;
}

//returns a list of the model's properties
-(NSArray*)__properties__
{
    //fetch the associated object
    NSDictionary* classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
    if (classProperties) return [classProperties allValues];

    //if here, the class needs to inspect itself
    [self __setup__];

    //return the property list
    classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
    return [classProperties allValues];
}

//inspects the class, get's a list of the class properties
/*
 * 核心方法
 * 主要作用是：
 * 遍历自定义model的所有属性，每个属性生成一个JSONModelClassProperty对象(保存该属性的所有信息)
 * 生成一个property: JSONModelClassProperty这样的键值对的字典存储为自定义model类对象的关联对象
 * 用于之后传入的字典做映射
 */
-(void)__inspectProperties
{
    //JMLog(@"Inspect class: %@", [self class]);
    
    /*
     * 一个存储Model类的所有属性的字典
     * key: 属性名
     * value: JSONModelClassProperty - 包装了属性的所有信息
     */
    NSMutableDictionary* propertyIndex = [NSMutableDictionary dictionary];

    //temp variables for the loops
    Class class = [self class];
    NSScanner* scanner = nil;
    NSString* propertyType = nil;

    // inspect inherited properties up to the JSONModel class
    // 往继承链上循环查找，直到查到JSONModel为止
    while (class != [JSONModel class]) {
        //JMLog(@"inspecting: %@", NSStringFromClass(class));

        unsigned int propertyCount;
        // 属性列表
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);

        //loop over the class properties
        // 遍历属性列表
        for (unsigned int i = 0; i < propertyCount; i++) {
            
            // 初始化一个JSONModelClassProperty对象用来存储属性的信息
            JSONModelClassProperty* p = [[JSONModelClassProperty alloc] init];

            // 属性名
            //get property name
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            p.name = @(propertyName);

            //JMLog(@"property: %@", p.name);

            //get property attributes
            /*
             * 属性类型     name值：T                        value：变化 Tq(NSInteger) Tc(BOOL)
             * 内存管理语义  name值：C(copy)
             *                    &(strong)
             *                    W(weak)
             *                    空(assign, readwrite)
             *                    R(readonly)              value：无
             * 非/原子性    name值：空(atomic) N(Nonatomic)  value：无
             * 变量名称     name值：V                        value：变化
             *        https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
             */
            const char *attrs = property_getAttributes(property);
            NSString* propertyAttributes = @(attrs);
            NSArray* attributeItems = [propertyAttributes componentsSeparatedByString:@","];

            //ignore read-only properties
            // 忽略只读属性
            if ([attributeItems containsObject:@"R"]) {
                continue; //to next property
            }

            // 初始化一个scanner来扫描属性的attributes
            scanner = [NSScanner scannerWithString: propertyAttributes];

            //JMLog(@"attr: %@", [NSString stringWithCString:attrs encoding:NSUTF8StringEncoding]);
            /*
             * scanner 的扫描下标从0开始
             * scarnUpToString:intoString:第一个参数是停止词，从当前扫描下标扫到停止词为止(不包含停止词)，第二个参数是用来接收扫描匹配到的字符串，传nil忽略之，扫描到就会返回YES，同时修改scanLocation；否则返回NO，不修改scanLocation
             * scanString:intoString:第一个参数是要扫描匹配的子串,从当前scanLocation开始扫描，第二个参数是用来接收扫描匹配到的字符串，传nil忽略之，扫描到就会返回YES，同时修改scanLocation；否则返回NO，不修改scanLocation
             */
            // 我认为的理论上propertyAttributes应该都是以T开头的，所以这是这一步做scanLocation校准我也没看懂？
            [scanner scanUpToString:@"T" intoString: nil];
            // 经过上一行代码的处理，不管是不是以T开头，下面这行代码都能匹配到T，同时把scanLocation设置为T的后一位
            [scanner scanString:@"T" intoString:nil];

            //check if the property is an instance of a class
            // 以@\" 开头的是对象类型
            if ([scanner scanString:@"@\"" intoString: &propertyType]) {

                // 扫描到指定字符集组成的字符串停止
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];

                //JMLog(@"type: %@", propertyClassName);
                p.type = NSClassFromString(propertyType);
                p.isMutable = ([propertyType rangeOfString:@"Mutable"].location != NSNotFound);
                p.isStandardJSONType = [allowedJSONTypes containsObject:p.type];

                //read through the property protocols
                // 嵌套模型使用protocol实现的
                // 遵循多个协议类型编码会用多个尖角括号<Optional><Ignore>
                while ([scanner scanString:@"<" intoString:NULL]) {

                    NSString* protocolName = nil;

                    // 截取两个尖角括号中间的字符串为protocolName
                    [scanner scanUpToString:@">" intoString: &protocolName];

                    if ([protocolName isEqualToString:@"Optional"]) {
                        p.isOptional = YES;
                    } else if([protocolName isEqualToString:@"Index"]) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                        p.isIndex = YES;
#pragma GCC diagnostic pop

                        objc_setAssociatedObject(
                                                 self.class,
                                                 &kIndexPropertyNameKey,
                                                 p.name,
                                                 OBJC_ASSOCIATION_RETAIN // This is atomic
                                                 );
                    } else if([protocolName isEqualToString:@"Ignore"]) {
                        p = nil;
                    } else {
                        p.protocol = protocolName;
                    }

                    // 略过右尖角括号，scanLocation+1，进入下一个循环
                    [scanner scanString:@">" intoString:NULL];
                }

            }
            //check if the property is a structure
            // 检查是否为结构体
            else if ([scanner scanString:@"{" intoString: &propertyType]) {
                [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                                    intoString:&propertyType];

                p.isStandardJSONType = NO;
                p.structName = propertyType;

            }
            //the property must be a primitive
            // 既不是对象属性又不是结构体，那只能是基本数据类型
            else {

                //the property contains a primitive data type
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                        intoString:&propertyType];

                //get the full name of the primitive type
                //这里获取到的propertyType是类型编码的简写，需要映射到实际的基本数据类型名称
                // f: float, B: BOOL, i: int, d: double ...
                //valueTransformer的primitivesNames是一个内置的基本数据类型简写与实际基本类型的映射字典，是在valueTransformer初始化时定义的
                propertyType = valueTransformer.primitivesNames[propertyType];

                // 检查是否是兼容的基本数据类型
                if (![allowedPrimitiveTypes containsObject:propertyType]) {

                    //type not allowed - programmer mistaken -> exception
                    @throw [NSException exceptionWithName:@"JSONModelProperty type not allowed"
                                                   reason:[NSString stringWithFormat:@"Property type of %@.%@ is not supported by JSONModel.", self.class, p.name]
                                                 userInfo:nil];
                }

            }

            // 判断是否可选
            NSString *nsPropertyName = @(propertyName);
            if([[self class] propertyIsOptional:nsPropertyName]){
                p.isOptional = YES;
            }

            // 判断是否需要忽略,这里为何不continue？
            if([[self class] propertyIsIgnored:nsPropertyName]){
                p = nil;
            }

            // 貌似customClass 永远是nil，不知道这个代码是要干嘛?..
            Class customClass = [[self class] classForCollectionProperty:nsPropertyName];
            if (customClass) {
                p.protocol = NSStringFromClass(customClass);
            }

            //few cases where JSONModel will ignore properties automatically
            // 如果是Block自动忽略,这里为何不continue？
            if ([propertyType isEqualToString:@"Block"]) {
                p = nil;
            }

            //add the property object to the temp index
            // 将属性对象添加到临时字典里
            if (p && ![propertyIndex objectForKey:p.name]) {
                [propertyIndex setValue:p forKey:p.name];
            }

            // generate custom setters and getter
            if (p)
            {
                NSString *name = [p.name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[p.name substringToIndex:1].uppercaseString];

                // getter
                SEL getter = NSSelectorFromString([NSString stringWithFormat:@"JSONObjectFor%@", name]);

                if ([self respondsToSelector:getter])
                    p.customGetter = getter;

                // setters
                p.customSetters = [NSMutableDictionary new];

                SEL genericSetter = NSSelectorFromString([NSString stringWithFormat:@"set%@WithJSONObject:", name]);

                if ([self respondsToSelector:genericSetter])
                    p.customSetters[@"generic"] = [NSValue valueWithBytes:&genericSetter objCType:@encode(SEL)];

                for (Class type in allowedJSONTypes)
                {
                    NSString *class = NSStringFromClass([JSONValueTransformer classByResolvingClusterClasses:type]);

                    if (p.customSetters[class])
                        continue;

                    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@With%@:", name, class]);

                    if ([self respondsToSelector:setter])
                        p.customSetters[class] = [NSValue valueWithBytes:&setter objCType:@encode(SEL)];
                }
            }
        }

        free(properties);

        //ascend to the super of the class
        //(will do that until it reaches the root class - JSONModel)
        class = [class superclass];
    }

    //finally store the property index in the static property index
    objc_setAssociatedObject(
                             self.class,
                             &kClassPropertiesKey,
                             [propertyIndex copy],
                             OBJC_ASSOCIATION_RETAIN // This is atomic
                             );
}

#pragma mark - built-in transformer methods
//few built-in transformations
-(id)__transform:(id)value forProperty:(JSONModelClassProperty*)property error:(NSError**)err
{
    Class protocolClass = NSClassFromString(property.protocol);
    if (!protocolClass) {

        //no other protocols on arrays and dictionaries
        //except JSONModel classes
        if ([value isKindOfClass:[NSArray class]]) {
            @throw [NSException exceptionWithName:@"Bad property protocol declaration"
                                           reason:[NSString stringWithFormat:@"<%@> is not allowed JSONModel property protocol, and not a JSONModel class.", property.protocol]
                                         userInfo:nil];
        }
        return value;
    }

    //if the protocol is actually a JSONModel class
    if ([self __isJSONModelSubClass:protocolClass]) {

        //check if it's a list of models
        if ([property.type isSubclassOfClass:[NSArray class]]) {

            // Expecting an array, make sure 'value' is an array
            if(![[value class] isSubclassOfClass:[NSArray class]])
            {
                if(err != nil)
                {
                    NSString* mismatch = [NSString stringWithFormat:@"Property '%@' is declared as NSArray<%@>* but the corresponding JSON value is not a JSON Array.", property.name, property.protocol];
                    JSONModelError* typeErr = [JSONModelError errorInvalidDataWithTypeMismatch:mismatch];
                    *err = [typeErr errorByPrependingKeyPathComponent:property.name];
                }
                return nil;
            }

            //one shot conversion
            JSONModelError* arrayErr = nil;
            value = [[protocolClass class] arrayOfModelsFromDictionaries:value error:&arrayErr];
            if((err != nil) && (arrayErr != nil))
            {
                *err = [arrayErr errorByPrependingKeyPathComponent:property.name];
                return nil;
            }
        }

        //check if it's a dictionary of models
        if ([property.type isSubclassOfClass:[NSDictionary class]]) {

            // Expecting a dictionary, make sure 'value' is a dictionary
            if(![[value class] isSubclassOfClass:[NSDictionary class]])
            {
                if(err != nil)
                {
                    NSString* mismatch = [NSString stringWithFormat:@"Property '%@' is declared as NSDictionary<%@>* but the corresponding JSON value is not a JSON Object.", property.name, property.protocol];
                    JSONModelError* typeErr = [JSONModelError errorInvalidDataWithTypeMismatch:mismatch];
                    *err = [typeErr errorByPrependingKeyPathComponent:property.name];
                }
                return nil;
            }

            NSMutableDictionary* res = [NSMutableDictionary dictionary];

            for (NSString* key in [value allKeys]) {
                JSONModelError* initErr = nil;
                id obj = [[[protocolClass class] alloc] initWithDictionary:value[key] error:&initErr];
                if (obj == nil)
                {
                    // Propagate the error, including the property name as the key-path component
                    if((err != nil) && (initErr != nil))
                    {
                        initErr = [initErr errorByPrependingKeyPathComponent:key];
                        *err = [initErr errorByPrependingKeyPathComponent:property.name];
                    }
                    return nil;
                }
                [res setValue:obj forKey:key];
            }
            value = [NSDictionary dictionaryWithDictionary:res];
        }
    }

    return value;
}

//built-in reverse transformations (export to JSON compliant objects)
-(id)__reverseTransform:(id)value forProperty:(JSONModelClassProperty*)property
{
    Class protocolClass = NSClassFromString(property.protocol);
    if (!protocolClass) return value;

    //if the protocol is actually a JSONModel class
    if ([self __isJSONModelSubClass:protocolClass]) {

        //check if should export list of dictionaries
        if (property.type == [NSArray class] || property.type == [NSMutableArray class]) {
            NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity: [(NSArray*)value count] ];
            for (NSObject<AbstractJSONModelProtocol>* model in (NSArray*)value) {
                if ([model respondsToSelector:@selector(toDictionary)]) {
                    [tempArray addObject: [model toDictionary]];
                } else
                    [tempArray addObject: model];
            }
            return [tempArray copy];
        }

        //check if should export dictionary of dictionaries
        if (property.type == [NSDictionary class] || property.type == [NSMutableDictionary class]) {
            NSMutableDictionary* res = [NSMutableDictionary dictionary];
            for (NSString* key in [(NSDictionary*)value allKeys]) {
                id<AbstractJSONModelProtocol> model = value[key];
                [res setValue: [model toDictionary] forKey: key];
            }
            return [NSDictionary dictionaryWithDictionary:res];
        }
    }

    return value;
}

#pragma mark - custom transformations
- (BOOL)__customSetValue:(id <NSObject>)value forProperty:(JSONModelClassProperty *)property
{
    NSString *class = NSStringFromClass([JSONValueTransformer classByResolvingClusterClasses:[value class]]);

    SEL setter = nil;
    [property.customSetters[class] getValue:&setter];

    if (!setter)
        [property.customSetters[@"generic"] getValue:&setter];

    if (!setter)
        return NO;

    IMP imp = [self methodForSelector:setter];
    void (*func)(id, SEL, id <NSObject>) = (void *)imp;
    func(self, setter, value);

    return YES;
}

- (BOOL)__customGetValue:(id *)value forProperty:(JSONModelClassProperty *)property
{
    SEL getter = property.customGetter;

    if (!getter)
        return NO;

    IMP imp = [self methodForSelector:getter];
    id (*func)(id, SEL) = (void *)imp;
    *value = func(self, getter);

    return YES;
}

#pragma mark - persistance
-(void)__createDictionariesForKeyPath:(NSString*)keyPath inDictionary:(NSMutableDictionary**)dict
{
    //find if there's a dot left in the keyPath
    NSUInteger dotLocation = [keyPath rangeOfString:@"."].location;
    if (dotLocation==NSNotFound) return;

    //inspect next level
    NSString* nextHierarchyLevelKeyName = [keyPath substringToIndex: dotLocation];
    NSDictionary* nextLevelDictionary = (*dict)[nextHierarchyLevelKeyName];

    if (nextLevelDictionary==nil) {
        //create non-existing next level here
        nextLevelDictionary = [NSMutableDictionary dictionary];
    }

    //recurse levels
    [self __createDictionariesForKeyPath:[keyPath substringFromIndex: dotLocation+1]
                            inDictionary:&nextLevelDictionary ];

    //create the hierarchy level
    [*dict setValue:nextLevelDictionary  forKeyPath: nextHierarchyLevelKeyName];
}

-(NSDictionary*)toDictionary
{
    return [self toDictionaryWithKeys:nil];
}

-(NSString*)toJSONString
{
    return [self toJSONStringWithKeys:nil];
}

-(NSData*)toJSONData
{
    return [self toJSONDataWithKeys:nil];
}

//exports the model as a dictionary of JSON compliant objects
- (NSDictionary *)toDictionaryWithKeys:(NSArray <NSString *> *)propertyNames
{
    NSArray* properties = [self __properties__];
    NSMutableDictionary* tempDictionary = [NSMutableDictionary dictionaryWithCapacity:properties.count];

    id value;

    //loop over all properties
    for (JSONModelClassProperty* p in properties) {

        //skip if unwanted
        if (propertyNames != nil && ![propertyNames containsObject:p.name])
            continue;

        //fetch key and value
        NSString* keyPath = (self.__keyMapper||globalKeyMapper) ? [self __mapString:p.name withKeyMapper:self.__keyMapper] : p.name;
        value = [self valueForKey: p.name];

        //JMLog(@"toDictionary[%@]->[%@] = '%@'", p.name, keyPath, value);

        if ([keyPath rangeOfString:@"."].location != NSNotFound) {
            //there are sub-keys, introduce dictionaries for them
            [self __createDictionariesForKeyPath:keyPath inDictionary:&tempDictionary];
        }

        //check for custom getter
        if ([self __customGetValue:&value forProperty:p]) {
            //custom getter, all done
            [tempDictionary setValue:value forKeyPath:keyPath];
            continue;
        }

        //export nil when they are not optional values as JSON null, so that the structure of the exported data
        //is still valid if it's to be imported as a model again
        if (isNull(value)) {

            if (value == nil)
            {
                [tempDictionary removeObjectForKey:keyPath];
            }
            else
            {
                [tempDictionary setValue:[NSNull null] forKeyPath:keyPath];
            }
            continue;
        }

        //check if the property is another model
        if ([value isKindOfClass:JSONModelClass]) {

            //recurse models
            value = [(JSONModel*)value toDictionary];
            [tempDictionary setValue:value forKeyPath: keyPath];

            //for clarity
            continue;

        } else {

            // 1) check for built-in transformation
            if (p.protocol) {
                value = [self __reverseTransform:value forProperty:p];
            }

            // 2) check for standard types OR 2.1) primitives
            if (p.structName==nil && (p.isStandardJSONType || p.type==nil)) {

                //generic get value
                [tempDictionary setValue:value forKeyPath: keyPath];

                continue;
            }

            // 3) try to apply a value transformer
            if (YES) {

                //create selector from the property's class name
                NSString* selectorName = [NSString stringWithFormat:@"%@From%@:", @"JSONObject", p.type?p.type:p.structName];
                SEL selector = NSSelectorFromString(selectorName);

                BOOL foundCustomTransformer = NO;
                if ([valueTransformer respondsToSelector:selector]) {
                    foundCustomTransformer = YES;
                } else {
                    //try for hidden transformer
                    selectorName = [NSString stringWithFormat:@"__%@",selectorName];
                    selector = NSSelectorFromString(selectorName);
                    if ([valueTransformer respondsToSelector:selector]) {
                        foundCustomTransformer = YES;
                    }
                }

                //check if there's a transformer declared
                if (foundCustomTransformer) {
                    IMP imp = [valueTransformer methodForSelector:selector];
                    id (*func)(id, SEL, id) = (void *)imp;
                    value = func(valueTransformer, selector, value);

                    [tempDictionary setValue:value forKeyPath:keyPath];
                } else {
                    //in this case most probably a custom property was defined in a model
                    //but no default reverse transformer for it
                    @throw [NSException exceptionWithName:@"Value transformer not found"
                                                   reason:[NSString stringWithFormat:@"[JSONValueTransformer %@] not found", selectorName]
                                                 userInfo:nil];
                    return nil;
                }
            }
        }
    }

    return [tempDictionary copy];
}

//exports model to a dictionary and then to a JSON string
- (NSData *)toJSONDataWithKeys:(NSArray <NSString *> *)propertyNames
{
    NSData* jsonData = nil;
    NSError* jsonError = nil;

    @try {
        NSDictionary* dict = [self toDictionaryWithKeys:propertyNames];
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&jsonError];
    }
    @catch (NSException *exception) {
        //this should not happen in properly design JSONModel
        //usually means there was no reverse transformer for a custom property
        JMLog(@"EXCEPTION: %@", exception.description);
        return nil;
    }

    return jsonData;
}

- (NSString *)toJSONStringWithKeys:(NSArray <NSString *> *)propertyNames
{
    return [[NSString alloc] initWithData: [self toJSONDataWithKeys: propertyNames]
                                 encoding: NSUTF8StringEncoding];
}

#pragma mark - import/export of lists
//loop over an NSArray of JSON objects and turn them into models
+(NSMutableArray*)arrayOfModelsFromDictionaries:(NSArray*)array
{
    return [self arrayOfModelsFromDictionaries:array error:nil];
}

+ (NSMutableArray *)arrayOfModelsFromData:(NSData *)data error:(NSError **)err
{
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:err];
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;

    return [self arrayOfModelsFromDictionaries:json error:err];
}

+ (NSMutableArray *)arrayOfModelsFromString:(NSString *)string error:(NSError **)err
{
    return [self arrayOfModelsFromData:[string dataUsingEncoding:NSUTF8StringEncoding] error:err];
}

// Same as above, but with error reporting
+(NSMutableArray*)arrayOfModelsFromDictionaries:(NSArray*)array error:(NSError**)err
{
    //bail early
    if (isNull(array)) return nil;

    //parse dictionaries to objects
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [array count]];

    for (id d in array)
    {
        if ([d isKindOfClass:NSDictionary.class])
        {
            JSONModelError* initErr = nil;
            id obj = [[self alloc] initWithDictionary:d error:&initErr];
            if (obj == nil)
            {
                // Propagate the error, including the array index as the key-path component
                if((err != nil) && (initErr != nil))
                {
                    NSString* path = [NSString stringWithFormat:@"[%lu]", (unsigned long)list.count];
                    *err = [initErr errorByPrependingKeyPathComponent:path];
                }
                return nil;
            }

            [list addObject: obj];
        } else if ([d isKindOfClass:NSArray.class])
        {
            [list addObjectsFromArray:[self arrayOfModelsFromDictionaries:d error:err]];
        } else
        {
            // This is very bad
        }

    }

    return list;
}

+ (NSMutableDictionary *)dictionaryOfModelsFromString:(NSString *)string error:(NSError **)err
{
    return [self dictionaryOfModelsFromData:[string dataUsingEncoding:NSUTF8StringEncoding] error:err];
}

+ (NSMutableDictionary *)dictionaryOfModelsFromData:(NSData *)data error:(NSError **)err
{
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:err];
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;

    return [self dictionaryOfModelsFromDictionary:json error:err];
}

+ (NSMutableDictionary *)dictionaryOfModelsFromDictionary:(NSDictionary *)dictionary error:(NSError **)err
{
    NSMutableDictionary *output = [NSMutableDictionary dictionaryWithCapacity:dictionary.count];

    for (NSString *key in dictionary.allKeys)
    {
        id object = dictionary[key];

        if ([object isKindOfClass:NSDictionary.class])
        {
            id obj = [[self alloc] initWithDictionary:object error:err];
            if (obj == nil) return nil;
            output[key] = obj;
        }
        else if ([object isKindOfClass:NSArray.class])
        {
            id obj = [self arrayOfModelsFromDictionaries:object error:err];
            if (obj == nil) return nil;
            output[key] = obj;
        }
        else
        {
            if (err) {
                *err = [JSONModelError errorInvalidDataWithTypeMismatch:@"Only dictionaries and arrays are supported"];
            }
            return nil;
        }
    }

    return output;
}

//loop over NSArray of models and export them to JSON objects
+(NSMutableArray*)arrayOfDictionariesFromModels:(NSArray*)array
{
    //bail early
    if (isNull(array)) return nil;

    //convert to dictionaries
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [array count]];

    for (id<AbstractJSONModelProtocol> object in array) {

        id obj = [object toDictionary];
        if (!obj) return nil;

        [list addObject: obj];
    }
    return list;
}

//loop over NSArray of models and export them to JSON objects with specific properties
+(NSMutableArray*)arrayOfDictionariesFromModels:(NSArray*)array propertyNamesToExport:(NSArray*)propertyNamesToExport;
{
    //bail early
    if (isNull(array)) return nil;

    //convert to dictionaries
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [array count]];

    for (id<AbstractJSONModelProtocol> object in array) {

        id obj = [object toDictionaryWithKeys:propertyNamesToExport];
        if (!obj) return nil;

        [list addObject: obj];
    }
    return list;
}

+(NSMutableDictionary *)dictionaryOfDictionariesFromModels:(NSDictionary *)dictionary
{
    //bail early
    if (isNull(dictionary)) return nil;

    NSMutableDictionary *output = [NSMutableDictionary dictionaryWithCapacity:dictionary.count];

    for (NSString *key in dictionary.allKeys) {
        id <AbstractJSONModelProtocol> object = dictionary[key];
        id obj = [object toDictionary];
        if (!obj) return nil;
        output[key] = obj;
    }

    return output;
}

#pragma mark - custom comparison methods

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
-(NSString*)indexPropertyName
{
    //custom getter for an associated object
    return objc_getAssociatedObject(self.class, &kIndexPropertyNameKey);
}

-(BOOL)isEqual:(id)object
{
    //bail early if different classes
    if (![object isMemberOfClass:[self class]]) return NO;

    if (self.indexPropertyName) {
        //there's a defined ID property
        id objectId = [object valueForKey: self.indexPropertyName];
        return [[self valueForKey: self.indexPropertyName] isEqual:objectId];
    }

    //default isEqual implementation
    return [super isEqual:object];
}

-(NSComparisonResult)compare:(id)object
{
    if (self.indexPropertyName) {
        id objectId = [object valueForKey: self.indexPropertyName];
        if ([objectId respondsToSelector:@selector(compare:)]) {
            return [[self valueForKey:self.indexPropertyName] compare:objectId];
        }
    }

    //on purpose postponing the asserts for speed optimization
    //these should not happen anyway in production conditions
    NSAssert(self.indexPropertyName, @"Can't compare models with no <Index> property");
    NSAssert1(NO, @"The <Index> property of %@ is not comparable class.", [self class]);
    return kNilOptions;
}

- (NSUInteger)hash
{
    if (self.indexPropertyName) {
        id val = [self valueForKey:self.indexPropertyName];

        if (val) {
            return [val hash];
        }
    }

    return [super hash];
}

#pragma GCC diagnostic pop

#pragma mark - custom data validation
-(BOOL)validate:(NSError**)error
{
    return YES;
}

#pragma mark - custom recursive description
//custom description method for debugging purposes
-(NSString*)description
{
    NSMutableString* text = [NSMutableString stringWithFormat:@"<%@> \n", [self class]];

    for (JSONModelClassProperty *p in [self __properties__]) {

        id value = ([p.name isEqualToString:@"description"])?self->_description:[self valueForKey:p.name];
        NSString* valueDescription = (value)?[value description]:@"<nil>";

        if (p.isStandardJSONType && ![value respondsToSelector:@selector(count)] && [valueDescription length]>60) {

            //cap description for longer values
            valueDescription = [NSString stringWithFormat:@"%@...", [valueDescription substringToIndex:59]];
        }
        valueDescription = [valueDescription stringByReplacingOccurrencesOfString:@"\n" withString:@"\n   "];
        [text appendFormat:@"   [%@]: %@\n", p.name, valueDescription];
    }

    [text appendFormat:@"</%@>", [self class]];
    return text;
}

#pragma mark - key mapping
+(JSONKeyMapper*)keyMapper
{
    return nil;
}

+(void)setGlobalKeyMapper:(JSONKeyMapper*)globalKeyMapperParam
{
    globalKeyMapper = globalKeyMapperParam;
}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return NO;
}

+(BOOL)propertyIsIgnored:(NSString *)propertyName
{
    return NO;
}

+(NSString*)protocolForArrayProperty:(NSString *)propertyName
{
    return nil;
}

+(Class)classForCollectionProperty:(NSString *)propertyName
{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    NSString *protocolName = [self protocolForArrayProperty:propertyName];
#pragma GCC diagnostic pop

    if (!protocolName)
        return nil;

    return NSClassFromString(protocolName);
}

#pragma mark - working with incomplete models
- (void)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping
{
    [self mergeFromDictionary:dict useKeyMapping:useKeyMapping error:nil];
}

- (BOOL)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping error:(NSError **)error
{
    return [self __importDictionary:dict withKeyMapper:(useKeyMapping)? self.__keyMapper:nil validation:NO error:error];
}

#pragma mark - NSCopying, NSCoding
-(instancetype)copyWithZone:(NSZone *)zone
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:
        [NSKeyedArchiver archivedDataWithRootObject:self]
     ];
}

-(instancetype)initWithCoder:(NSCoder *)decoder
{
    NSString* json;

    if ([decoder respondsToSelector:@selector(decodeObjectOfClass:forKey:)]) {
        json = [decoder decodeObjectOfClass:[NSString class] forKey:@"json"];
    } else {
        json = [decoder decodeObjectForKey:@"json"];
    }

    JSONModelError *error = nil;
    self = [self initWithString:json error:&error];
    if (error) {
        JMLog(@"%@",[error localizedDescription]);
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.toJSONString forKey:@"json"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end

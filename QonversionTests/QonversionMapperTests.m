#import <XCTest/XCTest.h>

#import "QonversionMapper.h"
#import "Helpers/XCTestCase+TestJSON.h"

static NSString *JSONWithActiveProduct = @"check_result_with_active_product.json";
static NSString *JSONWithoutProducts = @"check_restul_without_products.json";
static NSString *checkFailedState = @"check_failed_state.json";
static NSString *initSuccessJSON = @"init.json";
static NSString *initFailedJSON = @"init_failed_state.json";

@interface QonversionMapperTests : XCTestCase
@property (nonatomic, strong) NSDictionary *activeUserDict;
@property (nonatomic, strong) NSDictionary *withoutProducts;
@property (nonatomic, strong) NSDictionary *userInitSuccess;
@property (nonatomic, strong) NSDictionary *userInitFailed;
@end

@implementation QonversionMapperTests

- (void)setUp {
    [super setUp];
    
    self.activeUserDict = [self JSONObjectFromContentsOfFile:JSONWithActiveProduct];
    self.withoutProducts = [self JSONObjectFromContentsOfFile:JSONWithoutProducts];
    self.userInitSuccess = [self JSONObjectFromContentsOfFile:initSuccessJSON];
    self.userInitFailed = [self JSONObjectFromContentsOfFile:initFailedJSON];
}

- (void)tearDown {
    self.activeUserDict = nil;
    self.withoutProducts = nil;
    self.userInitSuccess = nil;
    self.userInitFailed = nil;
    
    [super tearDown];
}

- (void)testThatAllRequiredDataPrepared {
    XCTAssertNotNil([self activeUserDict]);
    XCTAssertNotNil([self withoutProducts]);
}

- (void)testThatMapperParsePermissions {
    QonversionLaunchResult *result = [[QonversionMapper new] fillLaunchResult:self.userInitSuccess];
    
    XCTAssertNotNil(result);
    XCTAssertTrue([result.uid isEqualToString:@"qonversion_user_id"]);
    XCTAssertTrue([result.permissions isKindOfClass:NSDictionary.class]);
    
    QonversionPermission *premium = result.permissions[@"premium"];
    XCTAssertNotNil(premium);
    XCTAssertTrue(premium.isActive);
    XCTAssertEqual(premium.renewState, QonversionPermissionRenewStateBillingIssue);
    
    XCTAssertNotNil(premium.startedDate);
    
    XCTAssertTrue([premium.startedDate.description isEqualToString:@"2020-04-08 18:11:26 +0000"]);
    XCTAssertNotNil(premium.expirationDate);
    XCTAssertTrue(premium.isActive);
    
    XCTAssertTrue([premium.expirationDate.description isEqualToString:@"2020-05-08 14:51:26 +0000"]);
}

- (void)testThatMapperParseFewPermissionsCorrectly {
    QonversionLaunchResult *result = [[QonversionMapper new] fillLaunchResult:self.userInitSuccess];
      
    XCTAssertNotNil(result);
    XCTAssertEqual(result.permissions.count, 2);
    
    QonversionPermission *standart = result.permissions[@"standart"];
    XCTAssertNotNil(standart);
    XCTAssertTrue([standart.permissionID isEqualToString:@"standart"]);
    XCTAssertFalse(standart.isActive);
}

- (void)testThatMapparParsePermissionWithBrokenJson {
    QonversionLaunchComposeModel *result = [[QonversionMapper new] composeLaunchModelFrom:[self fileDataFromContentsOfFile:initFailedJSON]];
    
    XCTAssertNotNil(result);
    XCTAssertNotNil(result.error);
    XCTAssertNil(result.result);
    XCTAssertEqual(result.result.permissions.count, 0);
    
    QonversionLaunchComposeModel *brokenResult = [[QonversionMapper new] composeLaunchModelFrom:NULL];
    XCTAssertNotNil(brokenResult);
    XCTAssertNil(brokenResult.result);
    XCTAssertNotNil(brokenResult.error);
}

@end

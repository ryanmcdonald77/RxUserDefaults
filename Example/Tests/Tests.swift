import XCTest
import RxUserDefaults
import RxSwift


class Tests: XCTestCase {


    var userDefaults: UserDefaults!
    var settings: RxSettings!
    
    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "testing")
        settings = RxSettings(userDefaults: userDefaults)

    }
    
    override func tearDown() {

        // make sure we leave no values behind
        for key in userDefaults.dictionaryRepresentation().keys {
            userDefaults.removeObject(forKey: key)
        }

        super.tearDown()
    }
    
    func testStringSetting() {

        let setting = settings.setting(key: "string_test", defaultValue: "nothing")

        // first test default value
        XCTAssertEqual(setting.value, "nothing")
        // test that setting is not persisted
        XCTAssert(!setting.isSet)

        // set the value
        setting.value = "string_value"


        // check if value is present
        XCTAssertEqual(setting.value, "string_value")
        XCTAssert(setting.isSet)


        // remove value
        setting.remove()

        // check that value was removed
        XCTAssert(!setting.isSet)

    }

    func testIntSetting() {

        let setting = settings.setting(key: "int_test", defaultValue: 42)

        // first test default value
        XCTAssertEqual(setting.value, 42)
        // test that setting is not persisted
        XCTAssert(!setting.isSet)

        // set the value
        setting.value = 41


        // check if value is present
        XCTAssertEqual(setting.value, 41)
        XCTAssert(setting.isSet)


        // remove value
        setting.remove()

        // check that value was removed
        XCTAssert(!setting.isSet)
        
    }


    func testBoolSetting() {

        let setting = settings.setting(key: "bool_test", defaultValue: true)

        // first test default value
        XCTAssertEqual(setting.value, true)
        // test that setting is not persisted
        XCTAssert(!setting.isSet)

        // set the value
        setting.value = false


        // check if value is present
        XCTAssertEqual(setting.value, false)
        XCTAssert(setting.isSet)


        // remove value
        setting.remove()

        // check that value was removed
        XCTAssert(!setting.isSet)
        
    }


    func testEnumSetting() {

        enum TestEnum: Int, RxSettingEnum {

            case test0 = 0,
            test1 = 1,
            test2 = 2
            
        }

        let setting:Setting<TestEnum> = settings.setting(key: "enum_test", defaultValue: .test0)

        // first test default value
        XCTAssertEqual(setting.value, .test0)
        // test that setting is not persisted
        XCTAssert(!setting.isSet)

        // set the value
        setting.value = .test2


        // check if value is present
        XCTAssertEqual(setting.value, .test2)
        XCTAssert(setting.isSet)


        // remove value
        setting.remove()

        // check that value was removed
        XCTAssert(!setting.isSet)
        
    }

    func testArraySetting() {

        let setting:Setting<[Int]> = settings.setting(key: "array_test", defaultValue: [1,2])

        // first test default value
        XCTAssertEqual(setting.value, [1,2])
        // test that setting is not persisted
        XCTAssert(!setting.isSet)

        // set the value
        setting.value = [1,2,3]


        // check if value is present
        XCTAssertEqual(setting.value, [1,2,3])
        XCTAssert(setting.isSet)


        // remove value
        setting.remove()

        // check that value was removed
        XCTAssert(!setting.isSet)
        
    }


    func testSetSetting() {

        let setting:Setting<Set<Int>> = settings.setting(key: "set_test", defaultValue: [1,2])

        // first test default value
        XCTAssertEqual(setting.value, [1,2])
        // test that setting is not persisted
        XCTAssert(!setting.isSet)

        // set the value
        setting.value = [1,2,3]


        // check if value is present
        XCTAssertEqual(setting.value, [1,2,3])
        XCTAssert(setting.isSet)


        // remove value
        setting.remove()

        // check that value was removed
        XCTAssert(!setting.isSet)
        
    }


    func testRxSetting() {

        let expectation = self.expectation(description: "values observed")

        let setting = settings.setting(key: "rx_test", defaultValue: "nothing")


        _ = setting.asObservable().debug().take(5).toArray().subscribe(onNext: { (values) in

            // check the sequence
            XCTAssertEqual(values, ["nothing", "string_value_1", "string_value_2","string_value_3","nothing"])

            // release the semaphore
            expectation.fulfill()

            }, onError: { _ in
                XCTFail()
            }, onCompleted: nil, onDisposed: nil)

        // set two values
        setting.value = "string_value_1"
        setting.value = "string_value_2"

        // set a value directly
        userDefaults.set("string_value_3", forKey: "rx_test")

        // remove a value
        setting.remove()


        waitForExpectations(timeout: 10)

    }
    
    func testRxEnumSetting() {
        
        enum TestEnum: String, RxSettingEnum {
            
            case test0,
            test1,
            test2,
            defaultValue
            
        }
        
        let expectation = self.expectation(description: "values observed")
        let setting = settings.setting(key: "rx_enum_test", defaultValue: TestEnum.defaultValue)
        
        _ = setting.asObservable().debug().map { value in
                return value.rawValue
            } .take(5).toArray().subscribe(onNext: { (values) in
            
            // check the sequence
            XCTAssertEqual( values, [TestEnum.defaultValue.rawValue, TestEnum.test0.rawValue, TestEnum.test1.rawValue, TestEnum.test2.rawValue, TestEnum.defaultValue.rawValue])
            
            // release the semaphore
            expectation.fulfill()
            
            }, onError: { _ in
                XCTFail()
            }, onCompleted: nil, onDisposed: nil)
        
        // set two values
        setting.value = .test0
        setting.value = .test1
        
        // set a value directly
        userDefaults.set(TestEnum.test2.rawValue, forKey: "rx_enum_test")
        
        // remove a value
        setting.remove()
        
        waitForExpectations(timeout: 10)
        
    }

// TODO: figure out how to create an error when using unsupported types
//    func testUnsupportedType() {
//
//        struct Unsupported: RxSettingCompatible {
//            func toPersistedValue() -> Any {
//                return self
//            }
//
//            static func fromPersistedValue(value:Any) -> Unsupported {
//                return value as! Unsupported
//            }
//        }
//
//        let setting = Setting<Unsupported>(userDefaults: userDefaults, key: "unsupported_test", defaultValue: Unsupported())
//
//        setting.value = Unsupported()
//
//        
//    }

}


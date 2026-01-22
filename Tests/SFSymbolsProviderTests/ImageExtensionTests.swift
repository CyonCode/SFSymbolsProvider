import XCTest
import SwiftUI
@testable import SFSymbolsProvider

final class ImageExtensionTests: XCTestCase {
    
    func testParsePhosphorIconName() {
        let result1 = IconName.parse("ph.house")
        XCTAssertNotNil(result1)
        XCTAssertEqual(result1?.provider, .phosphor)
        XCTAssertEqual(result1?.name, "house")
        XCTAssertEqual(result1?.weight, .regular)
        
        let result2 = IconName.parse("ph.house.fill")
        XCTAssertEqual(result2?.weight, .fill)
        
        let result3 = IconName.parse("ph.arrow.up.bold")
        XCTAssertEqual(result3?.name, "arrow.up")
        XCTAssertEqual(result3?.weight, .bold)
    }
    
    func testParseIoniconsIconName() {
        let result1 = IconName.parse("ion.home")
        XCTAssertNotNil(result1)
        XCTAssertEqual(result1?.provider, .ionicons)
        XCTAssertEqual(result1?.name, "home")
        XCTAssertEqual(result1?.variant, .default)
        
        let result2 = IconName.parse("ion.home.outline")
        XCTAssertEqual(result2?.variant, .outline)
        
        let result3 = IconName.parse("ion.settings.sharp")
        XCTAssertEqual(result3?.variant, .sharp)
    }
    
    func testInvalidIconReturnsNil() {
        XCTAssertNil(IconName.parse("invalid"))
        XCTAssertNil(IconName.parse("sf.house"))
        XCTAssertNil(IconName.parse(""))
    }
    
    func testAutoProviderDetection() {
        let ph = IconName.parse("ph.house")
        XCTAssertEqual(ph?.provider, .phosphor)
        
        let ion = IconName.parse("ion.home")
        XCTAssertEqual(ion?.provider, .ionicons)
    }
    
    func testAssetNameGeneration() {
        let result1 = IconName.parse("ph.house")
        XCTAssertEqual(result1?.assetName, "ph.house")
        
        let result2 = IconName.parse("ph.house.fill")
        XCTAssertEqual(result2?.assetName, "ph.house.fill")
        
        let result3 = IconName.parse("ion.home.outline")
        XCTAssertEqual(result3?.assetName, "ion.home.outline")
    }
}

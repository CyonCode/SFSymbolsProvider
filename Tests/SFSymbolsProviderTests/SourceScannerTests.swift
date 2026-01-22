import XCTest
@testable import SFSymbolsProvider

final class SourceScannerTests: XCTestCase {
    
    // Test 1: Basic Image detection
    func testScanSimpleImageCall() {
        let code = #"let img = Image("ph.house")"#
        let icons = SourceScanner.scan(source: code)
        XCTAssertEqual(icons, ["ph.house"])
    }
    
    // Test 2: Image with weight
    func testScanImageWithWeight() {
        let code = #"Image("ph.house.fill")"#
        let icons = SourceScanner.scan(source: code)
        XCTAssertEqual(icons, ["ph.house.fill"])
    }
    
    // Test 3: Ionicons
    func testScanIonicons() {
        let code = #"Image("ion.home.outline")"#
        let icons = SourceScanner.scan(source: code)
        XCTAssertEqual(icons, ["ion.home.outline"])
    }
    
    // Test 4: Ignore comments
    func testIgnoreComments() {
        let code = """
        // Image("ph.house")
        Image("ph.gear")
        """
        let icons = SourceScanner.scan(source: code)
        XCTAssertEqual(icons, ["ph.gear"])
    }
    
    // Test 5: Multiple icons
    func testMultipleIcons() {
        let code = """
        Image("ph.house")
        Image("ph.gear.fill")
        Image("ion.home")
        Image("ion.settings.outline")
        Image("ph.star.bold")
        """
        let icons = SourceScanner.scan(source: code)
        XCTAssertEqual(icons.count, 5)
        XCTAssertTrue(icons.contains("ph.house"))
        XCTAssertTrue(icons.contains("ion.home"))
    }
    
    // Test 6: Icon name parsing
    func testParsePhosphorIconName() {
        let result1 = IconName.parse("ph.house")
        XCTAssertEqual(result1?.provider, .phosphor)
        XCTAssertEqual(result1?.name, "house")
        XCTAssertEqual(result1?.weight, .regular)
        
        let result2 = IconName.parse("ph.house.bold")
        XCTAssertEqual(result2?.weight, .bold)
    }
    
    func testParseIoniconsIconName() {
        let result1 = IconName.parse("ion.home")
        XCTAssertEqual(result1?.provider, .ionicons)
        XCTAssertEqual(result1?.name, "home")
        XCTAssertEqual(result1?.variant, .default)
        
        let result2 = IconName.parse("ion.home.sharp")
        XCTAssertEqual(result2?.variant, .sharp)
    }
    
    // Test 7: Scan directory
    func testScanDirectory() throws {
        // Create a temp directory with test files
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        let file1 = tempDir.appendingPathComponent("View1.swift")
        try #"Image("ph.house")"#.write(to: file1, atomically: true, encoding: .utf8)
        
        let file2 = tempDir.appendingPathComponent("View2.swift")
        try #"Image("ion.home")"#.write(to: file2, atomically: true, encoding: .utf8)
        
        let icons = SourceScanner.scanDirectory(at: tempDir)
        XCTAssertEqual(Set(icons), Set(["ph.house", "ion.home"]))
    }
    
    // Test 8: Generate manifest
    func testGenerateManifest() throws {
        let icons = ["ph.house", "ion.home"]
        let data = SourceScanner.generateManifest(icons: icons)
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let manifestIcons = json?["icons"] as? [String]
        XCTAssertEqual(Set(manifestIcons ?? []), Set(icons))
    }
    
    // Test 9: Block comments should be ignored
    func testIgnoreBlockComments() {
        let code = """
        /* Image("ph.house") */
        Image("ph.gear")
        """
        let icons = SourceScanner.scan(source: code)
        XCTAssertEqual(icons, ["ph.gear"])
    }
    
    // Test 10: Multiline block comments
    func testIgnoreMultilineBlockComments() {
        let code = """
        /*
         Image("ph.house")
         Image("ph.star")
        */
        Image("ph.gear")
        """
        let icons = SourceScanner.scan(source: code)
        XCTAssertEqual(icons, ["ph.gear"])
    }
    
    // Test 11: Deduplicate icons
    func testDeduplicateIcons() {
        let code = """
        Image("ph.house")
        Image("ph.house")
        Image("ph.house")
        """
        let icons = SourceScanner.scan(source: code)
        XCTAssertEqual(icons, ["ph.house"])
    }
    
    // Test 12: Invalid icon names should not match
    func testInvalidIconNames() {
        let code = """
        Image("house")
        Image("sf.house")
        Image("phosphor.house")
        """
        let icons = SourceScanner.scan(source: code)
        XCTAssertEqual(icons, [])
    }
}

import XCTest
@testable import SFSymbolsProviderTool

final class AssetGeneratorTests: XCTestCase {
    
    // Test 1: Map Phosphor icon paths
    func testMapPhosphorIconPath() {
        let config = AssetGeneratorConfig(
            phosphorPath: "/path/to/phosphor",
            ioniconsPath: "/path/to/ionicons"
        )
        
        let path1 = AssetGenerator.mapIconPath("ph.house", config: config)
        XCTAssertEqual(path1, "/path/to/phosphor/regular/house.svg")
        
        let path2 = AssetGenerator.mapIconPath("ph.house.fill", config: config)
        XCTAssertEqual(path2, "/path/to/phosphor/fill/house-fill.svg")
        
        let path3 = AssetGenerator.mapIconPath("ph.gear.bold", config: config)
        XCTAssertEqual(path3, "/path/to/phosphor/bold/gear-bold.svg")
    }
    
    // Test 2: Map Ionicons icon paths
    func testMapIoniconsIconPath() {
        let config = AssetGeneratorConfig(
            phosphorPath: "/path/to/phosphor",
            ioniconsPath: "/path/to/ionicons"
        )
        
        let path1 = AssetGenerator.mapIconPath("ion.home", config: config)
        XCTAssertEqual(path1, "/path/to/ionicons/home.svg")
        
        let path2 = AssetGenerator.mapIconPath("ion.home.outline", config: config)
        XCTAssertEqual(path2, "/path/to/ionicons/home-outline.svg")
        
        let path3 = AssetGenerator.mapIconPath("ion.settings.sharp", config: config)
        XCTAssertEqual(path3, "/path/to/ionicons/settings-sharp.svg")
    }
    
    // Test 3: Generate Contents.json
    func testGenerateContentsJson() {
        let json = AssetGenerator.generateContentsJson(filename: "house.svg")
        
        let data = json.data(using: .utf8)!
        let dict = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let images = dict["images"] as! [[String: String]]
        XCTAssertEqual(images[0]["filename"], "house.svg")
        XCTAssertEqual(images[0]["idiom"], "universal")
        
        let properties = dict["properties"] as! [String: String]
        XCTAssertEqual(properties["template-rendering-intent"], "template")
    }
    
    // Test 4: Generate xcassets Contents.json
    func testGenerateXcassetsRootContents() {
        let json = AssetGenerator.generateXcassetsRootContents()
        XCTAssertTrue(json.contains("\"author\""))
        XCTAssertTrue(json.contains("\"version\""))
    }
    
    // Test 5: Report invalid icons
    func testInvalidIconReporting() {
        let config = AssetGeneratorConfig(
            phosphorPath: "/nonexistent/path",
            ioniconsPath: "/nonexistent/path"
        )
        
        let result = AssetGenerator.validateIcons(["ph.nonexistent", "ph.house"], config: config)
        XCTAssertTrue(result.invalid.contains("ph.nonexistent"))
    }
    
    // Test 6: Asset name generation (avoid invalid characters)
    func testAssetNameGeneration() {
        // Icon name should be valid for xcassets folder name
        let name1 = AssetGenerator.assetName(for: "ph.house")
        XCTAssertEqual(name1, "ph.house")
        
        let name2 = AssetGenerator.assetName(for: "ph.house.fill")
        XCTAssertEqual(name2, "ph.house.fill")
        
        let name3 = AssetGenerator.assetName(for: "ion.home.outline")
        XCTAssertEqual(name3, "ion.home.outline")
    }
    
    // Test 7: Process Ionicons outline SVG (color replacement)
    func testProcessIoniconsOutlineSVG() {
        let input = """
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
        <path stroke="#000" fill="none" d="M123 456"/>
        </svg>
        """
        
        let output = AssetGenerator.processIoniconsOutlineSVG(input)
        XCTAssertTrue(output.contains("stroke=\"currentColor\""))
        XCTAssertFalse(output.contains("stroke=\"#000\""))
    }
}

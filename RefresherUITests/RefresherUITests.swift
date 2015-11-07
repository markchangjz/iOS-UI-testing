import XCTest

class RefresherUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        XCUIApplication().launch()
    
        // XCUIDevice().orientation = UIDeviceOrientation.LandscapeLeft
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func addNewItem(item: String) {
        let app = XCUIApplication()
        
        app.navigationBars.buttons["Add"].tap()
        
        let itemTextField = app.textFields.elementBoundByIndex(0)
        itemTextField.typeText(item)
        
        app.alerts.buttons["Add"].tap()
    }
    
    func pullDownToRefresh() {
        let app = XCUIApplication()
        
        let dragFromItem = app.tables.staticTexts.elementBoundByIndex(0)
        let dragToItem = app.tables.staticTexts.elementBoundByIndex(5)
        dragFromItem.pressForDuration(0.5, thenDragToElement: dragToItem)
    }
    
    func testSelectItem() {
        let app = XCUIApplication()
        
        let firstItem = app.tables.staticTexts.elementBoundByIndex(0)
        let selectItemString = firstItem.label
        firstItem.tap()
        
        let showItemString = app.staticTexts["detailLabel"].label
        
        XCTAssertEqual(selectItemString, showItemString)
    }
    
    func testAddNewItem() {
        let app = XCUIApplication()
        
        addNewItem("Taiwan")
        
        let addItem = app.tables.staticTexts["Taiwan"]
        
        XCTAssertTrue(addItem.exists)
    }
    
    func testDeleteItem() {
        let app = XCUIApplication()
        
        let originalNumberOfCell =  app.tables.staticTexts.count
        
        app.navigationBars.buttons["Edit"].tap()
        app.tables.buttons.elementBoundByIndex(0).tap()
        app.tables.buttons["Delete"].tap()
        app.navigationBars.buttons["Done"].tap()
        
        let currentlyNumberOfCell =  app.tables.staticTexts.count

        XCTAssertEqual(originalNumberOfCell - 1, currentlyNumberOfCell)
    }
    
    func testSearchItem() {
        let app = XCUIApplication()
        
        app.tables.searchFields["Search"].tap()
        app.tables.searchFields["Search"].typeText("japan")
        
        let searchFirstItem = app.tables.staticTexts.elementBoundByIndex(0)
        
        XCTAssertTrue(searchFirstItem.label.lowercaseString.containsString("japan"))
    }
    
    func testPullDownToRefresh() {
        let app = XCUIApplication()
        
        addNewItem("A")
        addNewItem("zzzzz")
        
        pullDownToRefresh()
        let firstItem = app.tables.staticTexts.elementBoundByIndex(0)
        XCTAssertEqual(firstItem.label, "zzzzz")
        
        pullDownToRefresh()
        XCTAssertEqual(firstItem.label, "A")
    }
}

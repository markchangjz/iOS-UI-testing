import XCTest

class RefresherUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        XCUIApplication().launch()
    
//        XCUIDevice().orientation = UIDeviceOrientation.LandscapeLeft
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
    
    func testDeleteItemByEditButton() {
        let app = XCUIApplication()
        
        let originalNumberOfCell =  app.tables.staticTexts.count
        
        app.navigationBars.buttons["Edit"].tap()
        let cell = app.tables.cells.elementBoundByIndex(0)
        cell.buttons.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Delete'")).element.tap()
        app.tables.buttons["Delete"].tap()
        app.navigationBars.buttons["Done"].tap()
        
        let currentlyNumberOfCell =  app.tables.staticTexts.count

        XCTAssertEqual(originalNumberOfCell - 1, currentlyNumberOfCell)
    }
    
//    func testDeleteItemBySwipeGesture() {
//        let app = XCUIApplication()
//        
//        let originalNumberOfCell =  app.tables.staticTexts.count
//        
//        let firstItem = app.tables.staticTexts.elementBoundByIndex(0)
//        firstItem.swipeLeft()
//        
//        XCUIApplication().tables.buttons["Delete"].tap()
//        
//        let currentlyNumberOfCell =  app.tables.staticTexts.count
//        
//        XCTAssertEqual(originalNumberOfCell - 1, currentlyNumberOfCell)
//    }
//    
//    func testSearchItem() {
//        let app = XCUIApplication()
//        
//        app.tables.searchFields["Search"].tap()
//        app.tables.searchFields["Search"].typeText("japan")
//        
//        let searchFirstItem = app.tables.staticTexts.elementBoundByIndex(0)
//        
//        XCTAssertTrue(searchFirstItem.label.lowercaseString.containsString("japan"))
//        
//        let firstItem = app.tables.staticTexts.elementBoundByIndex(0)
//        let firstItemName = firstItem.label
//        
//        firstItem.tap()
//        let showItemString = app.staticTexts["detailLabel"].label
//        
//        XCTAssertEqual(firstItemName, showItemString)
//    }
//    
//    func testPullDownToRefresh() {
//        let app = XCUIApplication()
//        
//        addNewItem("A")
//        addNewItem("zzzzz")
//        
//        pullDownToRefresh()
//        let firstItem = app.tables.staticTexts.elementBoundByIndex(0)
//        XCTAssertEqual(firstItem.label, "zzzzz")
//        
//        pullDownToRefresh()
//        XCTAssertEqual(firstItem.label, "A")
//    }
//    
//    func testReorder() {
//        let app = XCUIApplication()
//        
//        app.navigationBars.buttons["Edit"].tap()
//        let originalItem1Name = app.tables.staticTexts.elementBoundByIndex(0).label
//        let originalItem2Name = app.tables.staticTexts.elementBoundByIndex(1).label
//        
//        let cell1 = app.tables.cells.elementBoundByIndex(0)
//        let reorderButton1 = cell1.buttons.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Reorder'")).element
//        let cell2 = app.tables.cells.elementBoundByIndex(1)
//        let reorderButton2 = cell2.buttons.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Reorder'")).element
//        reorderButton1.pressForDuration(0.5, thenDragToElement: reorderButton2)
//        app.navigationBars.buttons["Done"].tap()
//        
//        let currentlyItem1Name = app.tables.staticTexts.elementBoundByIndex(0).label
//        let currentlyItem2Name = app.tables.staticTexts.elementBoundByIndex(1).label
//
//        XCTAssertEqual(originalItem1Name, currentlyItem2Name)
//        XCTAssertEqual(originalItem2Name, currentlyItem1Name)
//    }
}

import XCTest

class RefresherUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        XCUIApplication().launch()
    
        // 設定螢幕方向
        // XCUIDevice().orientation = UIDeviceOrientation.LandscapeLeft
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func addNewItem(item: String) {
        let app = XCUIApplication()
        // 點選新增按鈕
        app.navigationBars.buttons["Add"].tap()
        
        // 輸入新增項目的名稱
        let itemTextField = app.textFields.elementBoundByIndex(0)
        itemTextField.typeText(item)
        
        // 點選 alert 上的 Add 按鈕
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
        
        let addItem = app.tables.staticTexts["Mark"]
        
        addNewItem("Mark")
        
        // 新增後確認 Mark 項目存在
        XCTAssertTrue(addItem.exists)
    }
    
    func testDeleteItem() {
        
        let app = XCUIApplication()
        
        let originalNumberOfCell =  app.tables.staticTexts.count
        
        // 點選 Edit 按鈕, 進入編輯模式
        app.navigationBars.buttons["Edit"].tap()
        
        // 刪除指定的項目
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
        addNewItem("Z")
        
        pullDownToRefresh()
        
        let firstItem = app.tables.staticTexts.elementBoundByIndex(0)
        XCTAssertEqual(firstItem.label, "Z")
        
        pullDownToRefresh()
        XCTAssertEqual(firstItem.label, "A")
    }
}

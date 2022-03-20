import XCTest
@testable import ViewStore

struct TestState {
    var testValue = 0
}

enum TestAction {
    case increase
}

struct TestEnvironment {}

let testReducer: ReduceFunction<TestState, TestAction, TestEnvironment> = { state, action, env in
    switch action {
    case .increase:
        state.testValue = state.testValue + 1
    }
    return .none
}

typealias TestStore = ViewStore<TestState, TestAction, TestEnvironment>

final class ViewStoreTests: XCTestCase {
    func testAwaitAction() async {
        let viewStore = TestStore(
            state: TestState(testValue: 1),
            environment: .init(),
            reduceFunction: testReducer
        )

        await viewStore.awaitSend(.increase)
        XCTAssertEqual(viewStore.testValue, 2)
    }
}

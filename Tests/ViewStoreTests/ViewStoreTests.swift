import XCTest
@testable import ViewStore

struct TestState {
    var testValue = 0
}

enum TestAction {
    case increase
}

struct TestEnvironment {}

let testReducer: ReduceFunction<TestState, TestAction, TestEnvironment> = { state, action, env, cont in
    switch action {
    case .increase:
//            Task {
        cont.handle(.change { state in state.testValue = state.testValue + 1 })
//            }
//            Task {
        cont.handle(.change { state in state.testValue = state.testValue + 2 })
//            }
        cont.finish()
    }
}

struct ScopedTestState {
    var testValue = 0
}

enum ScopedTestAction {
    case increase
}

struct ScopedTestEnvironment {}

let scopedtestReducer: ReduceFunction<ScopedTestState, ScopedTestAction, ScopedTestEnvironment> = { state, action, env, handler in
    Task {
        switch action {
        case .increase:
            handler.handle(.change { state in print(state) })
        }
        handler.finish()
    }
}

typealias ScopedTestStore = ViewStore<ScopedTestState, ScopedTestAction, ScopedTestEnvironment>
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

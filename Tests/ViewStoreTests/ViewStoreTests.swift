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
    return AsyncStream { coninuation in
        switch action {
        case .increase:
            coninuation.yield(
                .change { state in
                    var state = state
                    state.testValue = state.testValue + 1
                    return state
                }
            )
            Task {
                coninuation.yield(
                    .change { state in
                        var state = state
                        state.testValue = state.testValue + 2
                        return state
                    }
                )
            }
        }
        coninuation.finish()
    }
}

struct ScopedTestState {
    var testValue = 0
}

enum ScopedTestAction {
    case increase
}

struct ScopedTestEnvironment {}

let scopedtestReducer: ReduceFunction<ScopedTestState, ScopedTestAction, ScopedTestEnvironment> = { state, action, env in
    AsyncStream { coninuation in
        switch action {
        case .increase:
            state.testValue = state.testValue + 1
        }
        coninuation.yield(ActionResult.change { state in return state } )
        coninuation.finish()
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

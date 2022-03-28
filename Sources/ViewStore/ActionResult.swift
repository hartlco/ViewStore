import Foundation

public enum ActionResult<Action, State> {
    case change((inout State) -> Void)
    case perform(Action)
}

public struct ActionHandler<Action, State> {
    private let continuation: AsyncStream<ActionResult<Action, State>>.Continuation
    
    public init(continuation: AsyncStream<ActionResult<Action, State>>.Continuation) {
        self.continuation = continuation
    }
    
    // TODO: Rename
    public func handle(_ actionResult: ActionResult<Action, State>) {
        continuation.yield(actionResult)
    }
    
    public func finish() {
        continuation.finish()
    }
}

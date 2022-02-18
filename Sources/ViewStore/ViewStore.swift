import SwiftUI

@dynamicMemberLookup
public final class ViewStore<State: Sendable, Action: Sendable, Environment>: ObservableObject {

    @Published private var state: State
    private let environment: Environment
    private let reduceFunction: ReduceFunction<State, Action, Environment>

    init(
        state: State,
        environment: Environment,
        reduceFunction: @escaping ReduceFunction<State, Action, Environment>
    ) {
        self.environment = environment
        self.state = state
        self.reduceFunction = reduceFunction
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }

    @MainActor
    public func binding<Value>(
        get keyPath: KeyPath<State, Value>,
        send action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { [unowned self] in
                state[keyPath: keyPath]
            },
            set: { [unowned self] newValue in
                self.send(action(newValue))
            }
        )
    }

    @MainActor
    public func send(_ action: Action) {
        Task {
            await reduceFunction(&state, action, environment)
        }
    }
}

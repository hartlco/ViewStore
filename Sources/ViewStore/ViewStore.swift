import SwiftUI

@dynamicMemberLookup
public final class ViewStore<State: Sendable, Action: Sendable, Environment>: ObservableObject {
    @Published private var state: State {
        didSet {
            print("Change: \(state)")
        }
    }
    private let environment: Environment
    private let reduceFunction: ReduceFunction<State, Action, Environment>

    public init(
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
    public func scope<LocalState, LocalAction>(
        state toLocalState: @escaping (State) -> LocalState,
        action fromLocalAction: @escaping (LocalAction) -> Action,
        scopedReducer: @escaping ReduceFunction<LocalState, LocalAction, Environment>
    ) -> ViewStore<LocalState, LocalAction, Environment> {
        let localStore = ViewStore<LocalState, LocalAction, Environment>(
            state: toLocalState(self.state),
            environment: self.environment) { localState, localAction, env in
                let actionResult = scopedReducer(localState, localAction, self.environment)
                self.send(fromLocalAction(localAction))

                return actionResult
            }
        return localStore
    }

    @MainActor
    public func send(_ action: Action) {
        Task {
            for await result in reduceFunction(state, action, environment) {
                switch result {
                case let .change(changeBlock):
                    changeBlock(&state)
                case let .perform(action):
                    send(action)
                } 
            }
        }
    }

    public func awaitSend(_ action: Action) async {
        for await result in reduceFunction(state, action, environment) {
            switch result {
            case let .change(changeBlock):
                changeBlock(&state)
            case let .perform(action):
                await awaitSend(action)
            }
        }
    }
}

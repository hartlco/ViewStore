import SwiftUI

@dynamicMemberLookup
public final class ViewStore<State: Sendable, Action: Sendable, Environment>: ObservableObject {
    @Published private var state: State
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

    public func scope<LocalState, LocalAction>(
        state toLocalState: @escaping (State) -> LocalState,
        action fromLocalAction: @escaping (LocalAction) -> Action,
        scopedReducer: @escaping ReduceFunction<LocalState, LocalAction, Environment>
    ) -> ViewStore<LocalState, LocalAction, Environment> {
        let localStore = ViewStore<LocalState, LocalAction, Environment>(
            state: toLocalState(self.state),
            environment: self.environment) { localState, localAction, env in
                let actionResult = await scopedReducer(&localState, localAction, self.environment)
                await self.send(fromLocalAction(localAction))

                return actionResult
            }
        return localStore
    }

    @MainActor
    public func send(_ action: Action) {
        Task {
            let result = await reduceFunction(&state, action, environment)

            switch result {
            case .none:
                return
            case let .perform(action):
                send(action)
            }
        }
    }

    public func awaitSend(_ action: Action) async {
        let result = await reduceFunction(&state, action, environment)

        switch result {
        case .none:
            return
        case let .perform(action):
            await awaitSend(action)
        }
    }
}

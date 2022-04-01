import Foundation
import CloudKit

public typealias ReduceFunction<State, Action: Sendable, Environment> = (State, Action, Environment, ActionHandler<Action, State>) async -> Void

import Foundation

public typealias ReduceFunction<State, Action: Sendable, Environment> = (inout State, Action, Environment) async -> Void

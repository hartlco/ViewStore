import Foundation
import CloudKit

//public typealias ReduceFunction<State, Action: Sendable, Environment> = (inout State, Action, Environment) async -> ActionResult<Action>

public typealias ReduceFunction<State, Action: Sendable, Environment> = (State, Action, Environment) -> AsyncStream<ActionResult<Action, State>>

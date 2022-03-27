import Foundation

public typealias ReduceFunction<State, Action, Environment> = (inout State, Action, Environment) -> ActionResult<Action>

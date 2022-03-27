import Foundation

public enum ActionResult<Action, State> {
    case change((inout State) -> Void)
    case perform(Action)
}

import Foundation

public enum ActionResult<Action, State> {
    case change((State) -> State)
    case perform(Action)
}

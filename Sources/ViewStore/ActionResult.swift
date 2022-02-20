import Foundation

public enum ActionResult<Action> {
    case none
    case perform(Action)
}

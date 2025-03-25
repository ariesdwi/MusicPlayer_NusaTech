
import Foundation
import Alamofire

public extension Bundle {
    static var core: Bundle {
        Bundle(for: Reference.self)
    }
}

private class Reference {
    
}

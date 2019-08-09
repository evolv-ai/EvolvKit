import SwiftyJSON

public typealias EvolvRawAllocations = [JSON]

extension EvolvRawAllocations {
    
    public enum Key: String {
        case experimentId = "eid"
        case userId = "uid"
        case sessionId = "sid"
        case candidateId = "cid"
        case type
        case score
    }
    
}

import Stencil
import PathKit

enum AccessLevelParameter: String {
    case `public`
    case `internal`
    case `private`
    
    func toAccessLevel() -> AccessLevel {
        switch self {
        case .internal: return .internal
        case .private: return .private
        case .public: return .public
        }
    }
}

enum AccessLevel: String {
    case `public` = "public "
    case `internal` = ""
    case `private` = "private "
}

struct Context {
    let name: String
    let accessLevel: AccessLevel
    let isStepsPropducer: Bool
    let isProcessingEventsEmitter: Bool
    let includePresenter: Bool
    let useSwinject: Bool
}



let fsLoader = FileSystemLoader(paths: ["/Users/hadrienmazelier/perso/Arcus/templates/Arcus/templates"])
let environment = Environment(loader: fsLoader)

let context = [
    "name": "Test",
    "accessLevel": AccessLevel.public.rawValue,
    "isStepsPropducer": true,
    "isProcessingEventsEmitter": true,
    "includePresenter": true,
    "useSwinject": true,
    ] as [String : Any]
let text = try environment.renderTemplate(name: "Reducer.swift", context: context)

let path = Path("/Users/hadrienmazelier/perso/Arcus/templates/Arcus/templates/Reduplus.swift")
try path.write(text)
print(text)


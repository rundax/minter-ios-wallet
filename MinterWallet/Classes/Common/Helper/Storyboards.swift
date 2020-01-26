//
// Autogenerated by Natalie - Storyboard Generator
// by Marcin Krzyzanowski http://krzyzanowskim.com
//
import UIKit

// MARK: - Storyboards

extension UIStoryboard {
    func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
        let instance = type.init()
        if let identifier = instance.storyboardIdentifier {
            return self.instantiateViewController(withIdentifier: identifier) as? T
        }
        return nil
    }

}

protocol Storyboard {
    static var storyboard: UIStoryboard { get }
    static var identifier: String { get }
}

struct Storyboards {

    struct Settings: Storyboard {

        static let identifier = "Settings"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> UINavigationController {
            return self.storyboard.instantiateInitialViewController() as! UINavigationController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }

        static func instantiateSettingsViewController() -> SettingsViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        }
    }

    struct Popup: Storyboard {

        static let identifier = "Popup"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> SendPopupViewController {
            return self.storyboard.instantiateInitialViewController() as! SendPopupViewController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }

        static func instantiateSendPopupViewController() -> SendPopupViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "SendPopupViewController") as! SendPopupViewController
        }

        static func instantiateSentPopupViewController() -> SentPopupViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "SentPopupViewController") as! SentPopupViewController
        }

        static func instantiateConfirmPopupViewController() -> ConfirmPopupViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "ConfirmPopupViewController") as! ConfirmPopupViewController
        }
    }

    struct PIN: Storyboard {

        static let identifier = "PIN"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> PINViewController {
            return self.storyboard.instantiateInitialViewController() as! PINViewController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }

        static func instantiatePINViewController() -> PINViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "PINViewController") as! PINViewController
        }
    }

    struct CreateWallet: Storyboard {

        static let identifier = "CreateWallet"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> CreateWalletViewController {
            return self.storyboard.instantiateInitialViewController() as! CreateWalletViewController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }
    }

    struct Delegated: Storyboard {

        static let identifier = "Delegated"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> DelegatedViewController {
            return self.storyboard.instantiateInitialViewController() as! DelegatedViewController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }

        static func instantiateDelegatedViewController() -> DelegatedViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "DelegatedViewController") as! DelegatedViewController
        }
    }

    struct Coins: Storyboard {

        static let identifier = "Coins"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> UINavigationController {
            return self.storyboard.instantiateInitialViewController() as! UINavigationController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }

        static func instantiateCoinsViewController() -> CoinsViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "CoinsViewController") as! CoinsViewController
        }
    }

    struct Receive: Storyboard {

        static let identifier = "Receive"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> UINavigationController {
            return self.storyboard.instantiateInitialViewController() as! UINavigationController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }

        static func instantiateReceiveViewController() -> ReceiveViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "ReceiveViewController") as! ReceiveViewController
        }
    }

    struct Transactions: Storyboard {

        static let identifier = "Transactions"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> TransactionsViewController {
            return self.storyboard.instantiateInitialViewController() as! TransactionsViewController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }

        static func instantiateTransactionsViewController() -> TransactionsViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "TransactionsViewController") as! TransactionsViewController
        }
    }

    struct PairedMode: Storyboard {

        static let identifier = "PairedMode"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> PairedModeViewController {
            return self.storyboard.instantiateInitialViewController() as! PairedModeViewController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }
    }

    struct Address: Storyboard {

        static let identifier = "Address"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> AddressViewController {
            return self.storyboard.instantiateInitialViewController() as! AddressViewController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }
    }

    struct AdvancedMode: Storyboard {

        static let identifier = "AdvancedMode"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> AdvancedModeViewController {
            return self.storyboard.instantiateInitialViewController() as! AdvancedModeViewController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }
    }

    struct Root: Storyboard {

        static let identifier = "Root"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> RootViewController {
            return self.storyboard.instantiateInitialViewController() as! RootViewController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }
    }

    struct Send: Storyboard {

        static let identifier = "Send"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> UINavigationController {
            return self.storyboard.instantiateInitialViewController() as! UINavigationController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }

        static func instantiateSendViewController() -> SendViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "SendViewController") as! SendViewController
        }
    }

    struct Login: Storyboard {

        static let identifier = "Login"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> UINavigationController {
            return self.storyboard.instantiateInitialViewController() as! UINavigationController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }

        static func instantiateLoginViewController() -> HomeViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! HomeViewController
        }
    }

    struct Convert: Storyboard {

        static let identifier = "Convert"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> RootConvertViewController {
            return self.storyboard.instantiateInitialViewController() as! RootConvertViewController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }

        static func instantiateRootConvertViewController() -> RootConvertViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "RootConvertViewController") as! RootConvertViewController
        }

        static func instantiateSpendCoinsViewController() -> SpendCoinsViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "SpendCoinsViewController") as! SpendCoinsViewController
        }

        static func instantiateGetCoinsViewController() -> GetCoinsViewController {
            return self.storyboard.instantiateViewController(withIdentifier: "GetCoinsViewController") as! GetCoinsViewController
        }
    }

    struct LaunchScreen: Storyboard {

        static let identifier = "LaunchScreen"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> UIViewController {
            return self.storyboard.instantiateInitialViewController()!
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }
    }

    struct Main: Storyboard {

        static let identifier = "Main"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> TabBarController {
            return self.storyboard.instantiateInitialViewController() as! TabBarController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }
    }

    struct RawTransaction: Storyboard {

        static let identifier = "RawTransaction"

        static var storyboard: UIStoryboard {
            return UIStoryboard(name: self.identifier, bundle: nil)
        }

        static func instantiateInitialViewController() -> UINavigationController {
            return self.storyboard.instantiateInitialViewController() as! UINavigationController
        }

        static func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            return self.storyboard.instantiateViewController(withIdentifier: identifier)
        }

        static func instantiateViewController<T: UIViewController>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {
            return self.storyboard.instantiateViewController(ofType: type)
        }
    }
}

// MARK: - ReusableKind
enum ReusableKind: String, CustomStringConvertible {
    case tableViewCell = "tableViewCell"
    case collectionViewCell = "collectionViewCell"

    var description: String { return self.rawValue }
}

// MARK: - SegueKind
enum SegueKind: String, CustomStringConvertible {
    case relationship = "relationship"
    case show = "show"
    case presentation = "presentation"
    case embed = "embed"
    case unwind = "unwind"
    case push = "push"
    case modal = "modal"
    case popover = "popover"
    case replace = "replace"
    case custom = "custom"

    var description: String { return self.rawValue }
}

// MARK: - IdentifiableProtocol

public protocol IdentifiableProtocol: Equatable {
    var storyboardIdentifier: String? { get }
}

// MARK: - SegueProtocol

public protocol SegueProtocol {
    var identifier: String? { get }
}

public func ==<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {
    return lhs.identifier == rhs.identifier
}

public func ~=<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {
    return lhs.identifier == rhs.identifier
}

public func ==<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {
    return lhs.identifier == rhs
}

public func ~=<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {
    return lhs.identifier == rhs
}

public func ==<T: SegueProtocol>(lhs: String, rhs: T) -> Bool {
    return lhs == rhs.identifier
}

public func ~=<T: SegueProtocol>(lhs: String, rhs: T) -> Bool {
    return lhs == rhs.identifier
}

// MARK: - ReusableViewProtocol
public protocol ReusableViewProtocol: IdentifiableProtocol {
    var viewType: UIView.Type? { get }
}

public func ==<T: ReusableViewProtocol, U: ReusableViewProtocol>(lhs: T, rhs: U) -> Bool {
    return lhs.storyboardIdentifier == rhs.storyboardIdentifier
}

// MARK: - Protocol Implementation
extension UIStoryboardSegue: SegueProtocol {
}

extension UICollectionReusableView: ReusableViewProtocol {
    public var viewType: UIView.Type? { return type(of: self) }
    public var storyboardIdentifier: String? { return self.reuseIdentifier }
}

extension UITableViewCell: ReusableViewProtocol {
    public var viewType: UIView.Type? { return type(of: self) }
    public var storyboardIdentifier: String? { return self.reuseIdentifier }
}

// MARK: - UIViewController extension
extension UIViewController {
    func perform<T: SegueProtocol>(segue: T, sender: Any?) {
        if let identifier = segue.identifier {
            performSegue(withIdentifier: identifier, sender: sender)
        }
    }

    func perform<T: SegueProtocol>(segue: T) {
        perform(segue: segue, sender: nil)
    }
}
// MARK: - UICollectionView

extension UICollectionView {

    func dequeue<T: ReusableViewProtocol>(reusable: T, for: IndexPath) -> UICollectionViewCell? {
        if let identifier = reusable.storyboardIdentifier {
            return dequeueReusableCell(withReuseIdentifier: identifier, for: `for`)
        }
        return nil
    }

    func register<T: ReusableViewProtocol>(reusable: T) {
        if let type = reusable.viewType, let identifier = reusable.storyboardIdentifier {
            register(type, forCellWithReuseIdentifier: identifier)
        }
    }

    func dequeueReusableSupplementaryViewOfKind<T: ReusableViewProtocol>(elementKind: String, withReusable reusable: T, for: IndexPath) -> UICollectionReusableView? {
        if let identifier = reusable.storyboardIdentifier {
            return dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: identifier, for: `for`)
        }
        return nil
    }

    func register<T: ReusableViewProtocol>(reusable: T, forSupplementaryViewOfKind elementKind: String) {
        if let type = reusable.viewType, let identifier = reusable.storyboardIdentifier {
            register(type, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)
        }
    }
}
// MARK: - UITableView

extension UITableView {

    func dequeue<T: ReusableViewProtocol>(reusable: T, for: IndexPath) -> UITableViewCell? {
        if let identifier = reusable.storyboardIdentifier {
            return dequeueReusableCell(withIdentifier: identifier, for: `for`)
        }
        return nil
    }

    func register<T: ReusableViewProtocol>(reusable: T) {
        if let type = reusable.viewType, let identifier = reusable.storyboardIdentifier {
            register(type, forCellReuseIdentifier: identifier)
        }
    }

    func dequeueReusableHeaderFooter<T: ReusableViewProtocol>(_ reusable: T) -> UITableViewHeaderFooterView? {
        if let identifier = reusable.storyboardIdentifier {
            return dequeueReusableHeaderFooterView(withIdentifier: identifier)
        }
        return nil
    }

    func registerReusableHeaderFooter<T: ReusableViewProtocol>(_ reusable: T) {
        if let type = reusable.viewType, let identifier = reusable.storyboardIdentifier {
             register(type, forHeaderFooterViewReuseIdentifier: identifier)
        }
    }
}

// MARK: - SettingsViewController
extension UIStoryboardSegue {
    func selection() -> SettingsViewController.Segue? {
        if let identifier = self.identifier {
            return SettingsViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}
protocol SettingsViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension SettingsViewController: SettingsViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: SettingsViewController {
    var storyboardIdentifier: String? { return "SettingsViewController" }
    static var storyboardIdentifier: String? { return "SettingsViewController" }
}
extension SettingsViewController {

    enum Segue: String, CustomStringConvertible, SegueProtocol {
        case showAddress
        case showUsername
        case showEmail
        case showPassword
        case showPIN

        var kind: SegueKind? {
            switch self {
            case .showAddress:
                return SegueKind(rawValue: "show")
            case .showUsername:
                return SegueKind(rawValue: "show")
            case .showEmail:
                return SegueKind(rawValue: "show")
            case .showPassword:
                return SegueKind(rawValue: "show")
            case .showPIN:
                return SegueKind(rawValue: "show")
            }
        }

        var destination: UIViewController.Type? {
            switch self {
            case .showUsername:
                return UsernameEditViewController.self
            case .showEmail:
                return EmailEditViewController.self
            case .showPassword:
                return PasswordEditViewController.self
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.rawValue }
        var description: String { return "\(self.rawValue)" }
    }

}
extension SettingsViewController {

    enum Reusable: String, CustomStringConvertible, ReusableViewProtocol {
        case SettingsAvatarTableViewCell_ = "SettingsAvatarTableViewCell"

        var kind: ReusableKind? {
            switch self {
            case .SettingsAvatarTableViewCell_:
                return ReusableKind(rawValue: "tableViewCell")
            }
        }

        var viewType: UIView.Type? {
            switch self {
            case .SettingsAvatarTableViewCell_:
                return SettingsAvatarTableViewCell.self
            }
        }

        var storyboardIdentifier: String? { return self.description }
        var description: String { return self.rawValue }
    }

}

// MARK: - UsernameEditViewController

// MARK: - MobileEditViewController

// MARK: - EmailEditViewController

// MARK: - PasswordEditViewController

// MARK: - SendPopupViewController
protocol SendPopupViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension SendPopupViewController: SendPopupViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: SendPopupViewController {
    var storyboardIdentifier: String? { return "SendPopupViewController" }
    static var storyboardIdentifier: String? { return "SendPopupViewController" }
}

// MARK: - SentPopupViewController
protocol SentPopupViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension SentPopupViewController: SentPopupViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: SentPopupViewController {
    var storyboardIdentifier: String? { return "SentPopupViewController" }
    static var storyboardIdentifier: String? { return "SentPopupViewController" }
}

// MARK: - ConfirmPopupViewController
protocol ConfirmPopupViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension ConfirmPopupViewController: ConfirmPopupViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: ConfirmPopupViewController {
    var storyboardIdentifier: String? { return "ConfirmPopupViewController" }
    static var storyboardIdentifier: String? { return "ConfirmPopupViewController" }
}

// MARK: - PINViewController
protocol PINViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension PINViewController: PINViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: PINViewController {
    var storyboardIdentifier: String? { return "PINViewController" }
    static var storyboardIdentifier: String? { return "PINViewController" }
}

// MARK: - CreateWalletViewController

// MARK: - DelegatedViewController
protocol DelegatedViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension DelegatedViewController: DelegatedViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: DelegatedViewController {
    var storyboardIdentifier: String? { return "DelegatedViewController" }
    static var storyboardIdentifier: String? { return "DelegatedViewController" }
}
extension DelegatedViewController {

    enum Reusable: String, CustomStringConvertible, ReusableViewProtocol {
        case DelegatedTableViewCell_ = "DelegatedTableViewCell"
        case TwoTitleTableViewCell_ = "TwoTitleTableViewCell"

        var kind: ReusableKind? {
            switch self {
            case .DelegatedTableViewCell_:
                return ReusableKind(rawValue: "tableViewCell")
            case .TwoTitleTableViewCell_:
                return ReusableKind(rawValue: "tableViewCell")
            }
        }

        var viewType: UIView.Type? {
            switch self {
            case .DelegatedTableViewCell_:
                return DelegatedTableViewCell.self
            case .TwoTitleTableViewCell_:
                return TwoTitleTableViewCell.self
            }
        }

        var storyboardIdentifier: String? { return self.description }
        var description: String { return self.rawValue }
    }

}

// MARK: - CoinsViewController
extension UIStoryboardSegue {
    func selection() -> CoinsViewController.Segue? {
        if let identifier = self.identifier {
            return CoinsViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}
protocol CoinsViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension CoinsViewController: CoinsViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: CoinsViewController {
    var storyboardIdentifier: String? { return "CoinsViewController" }
    static var storyboardIdentifier: String? { return "CoinsViewController" }
}
extension CoinsViewController {

    enum Segue: String, CustomStringConvertible, SegueProtocol {
        case showDelegated
        case showTransactions
        case showConvert

        var kind: SegueKind? {
            switch self {
            case .showDelegated:
                return SegueKind(rawValue: "show")
            case .showTransactions:
                return SegueKind(rawValue: "show")
            case .showConvert:
                return SegueKind(rawValue: "show")
            }
        }

        var destination: UIViewController.Type? {
            switch self {
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.rawValue }
        var description: String { return "\(self.rawValue)" }
    }

}

// MARK: - ReceiveViewController
protocol ReceiveViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension ReceiveViewController: ReceiveViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: ReceiveViewController {
    var storyboardIdentifier: String? { return "ReceiveViewController" }
    static var storyboardIdentifier: String? { return "ReceiveViewController" }
}
extension ReceiveViewController {

    enum Reusable: String, CustomStringConvertible, ReusableViewProtocol {
        case QRTableViewCell_ = "QRTableViewCell"
        case ReceiveEmailTableViewCell_ = "ReceiveEmailTableViewCell"

        var kind: ReusableKind? {
            switch self {
            case .QRTableViewCell_:
                return ReusableKind(rawValue: "tableViewCell")
            case .ReceiveEmailTableViewCell_:
                return ReusableKind(rawValue: "tableViewCell")
            }
        }

        var viewType: UIView.Type? {
            switch self {
            case .QRTableViewCell_:
                return QRTableViewCell.self
            case .ReceiveEmailTableViewCell_:
                return ReceiveEmailTableViewCell.self
            }
        }

        var storyboardIdentifier: String? { return self.description }
        var description: String { return self.rawValue }
    }

}

// MARK: - TransactionsViewController
protocol TransactionsViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension TransactionsViewController: TransactionsViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: TransactionsViewController {
    var storyboardIdentifier: String? { return "TransactionsViewController" }
    static var storyboardIdentifier: String? { return "TransactionsViewController" }
}

// MARK: - PairedModeViewController

// MARK: - AddressViewController
extension UIStoryboardSegue {
    func selection() -> AddressViewController.Segue? {
        if let identifier = self.identifier {
            return AddressViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}
extension AddressViewController {

    enum Segue: String, CustomStringConvertible, SegueProtocol {
        case showBalance

        var kind: SegueKind? {
            switch self {
            case .showBalance:
                return SegueKind(rawValue: "show")
            }
        }

        var destination: UIViewController.Type? {
            switch self {
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.rawValue }
        var description: String { return "\(self.rawValue)" }
    }

}
extension AddressViewController {

    enum Reusable: String, CustomStringConvertible, ReusableViewProtocol {
        case annotationCell = "annotationCell"

        var kind: ReusableKind? {
            switch self {
            case .annotationCell:
                return ReusableKind(rawValue: "tableViewCell")
            }
        }

        var viewType: UIView.Type? {
            switch self {
            default:
                return nil
            }
        }

        var storyboardIdentifier: String? { return self.description }
        var description: String { return self.rawValue }
    }

}

// MARK: - AdvancedModeViewController
extension UIStoryboardSegue {
    func selection() -> AdvancedModeViewController.Segue? {
        if let identifier = self.identifier {
            return AdvancedModeViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}
extension AdvancedModeViewController {

    enum Segue: String, CustomStringConvertible, SegueProtocol {
        case showGenerate

        var kind: SegueKind? {
            switch self {
            case .showGenerate:
                return SegueKind(rawValue: "show")
            }
        }

        var destination: UIViewController.Type? {
            switch self {
            case .showGenerate:
                return GenerateAddressViewController.self
            }
        }

        var identifier: String? { return self.rawValue }
        var description: String { return "\(self.rawValue)" }
    }

}

// MARK: - GenerateAddressViewController

// MARK: - RootViewController

// MARK: - SendViewController
protocol SendViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension SendViewController: SendViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: SendViewController {
    var storyboardIdentifier: String? { return "SendViewController" }
    static var storyboardIdentifier: String? { return "SendViewController" }
}

// MARK: - HomeViewController
extension UIStoryboardSegue {
    func selection() -> HomeViewController.Segue? {
        if let identifier = self.identifier {
            return HomeViewController.Segue(rawValue: identifier)
        }
        return nil
    }
}
protocol HomeViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension HomeViewController: HomeViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: HomeViewController {
    var storyboardIdentifier: String? { return "LoginViewController" }
    static var storyboardIdentifier: String? { return "LoginViewController" }
}
extension HomeViewController {

    enum Segue: String, CustomStringConvertible, SegueProtocol {
        case showAdvanced

        var kind: SegueKind? {
            switch self {
            case .showAdvanced:
                return SegueKind(rawValue: "show")
            }
        }

        var destination: UIViewController.Type? {
            switch self {
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String? { return self.rawValue }
        var description: String { return "\(self.rawValue)" }
    }

}

// MARK: - LoginViewController

// MARK: - RootConvertViewController
protocol RootConvertViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension RootConvertViewController: RootConvertViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: RootConvertViewController {
    var storyboardIdentifier: String? { return "RootConvertViewController" }
    static var storyboardIdentifier: String? { return "RootConvertViewController" }
}

// MARK: - SpendCoinsViewController
protocol SpendCoinsViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension SpendCoinsViewController: SpendCoinsViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: SpendCoinsViewController {
    var storyboardIdentifier: String? { return "SpendCoinsViewController" }
    static var storyboardIdentifier: String? { return "SpendCoinsViewController" }
}

// MARK: - GetCoinsViewController
protocol GetCoinsViewControllerIdentifiableProtocol: IdentifiableProtocol { }

extension GetCoinsViewController: GetCoinsViewControllerIdentifiableProtocol { }

extension IdentifiableProtocol where Self: GetCoinsViewController {
    var storyboardIdentifier: String? { return "GetCoinsViewController" }
    static var storyboardIdentifier: String? { return "GetCoinsViewController" }
}

// MARK: - TabBarController

// MARK: - RawTransactionViewController


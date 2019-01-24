
import UIKit

protocol EditSummaryViewDelegate: AnyObject {
    func summaryChanged(newSummary: String)
    func learnMoreButtonTapped(sender: UIButton)
    func cannedButtonTapped(type: EditSummaryViewCannedButtonType)
}

enum EditSummaryViewCannedButtonType: Int {
    case typo, grammar, link
}

class EditSummaryViewController: UIViewController, Themeable {
    static let maximumSummaryLength = 255
    
    public var theme: Theme = .standard {
        didSet {
            apply(theme: theme)
        }
    }

    public weak var delegate: EditSummaryViewDelegate?
    
    @IBOutlet private weak var addSummaryLabel: UILabel!
    @IBOutlet private weak var learnMoreButton: UIButton!
    @IBOutlet private weak var summaryTextField: ThemeableTextField!
    @IBOutlet private weak var fixedTypoButton: UIButton!
    @IBOutlet private weak var fixedGrammarButton: UIButton!
    @IBOutlet private weak var addedLinksButton: UIButton!
    @IBOutlet private weak var dividerView: UIView!

    private let placeholderText = WMFLocalizedStringWithDefaultValue("edit-summary-placeholder-text", nil, nil, "How did you improve the article?", "Placeholder text which appears initially in the free-form edit summary text box")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fixedTypoButton.titleLabel?.numberOfLines = 1
        fixedGrammarButton.titleLabel?.numberOfLines = 1
        addedLinksButton.titleLabel?.numberOfLines = 1

        fixedTypoButton.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        fixedGrammarButton.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        addedLinksButton.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        addSummaryLabel.text = WMFLocalizedStringWithDefaultValue("edit-summary-add-summary-text", nil, nil, "Add an edit summary", "Text for add summary label")
        learnMoreButton.setTitle(WMFLocalizedStringWithDefaultValue("edit-summary-learn-more-text", nil, nil, "Learn more", "Text for learn more button"), for: .normal)
        summaryTextField.placeholder = placeholderText
        summaryTextField.delegate = self
        summaryTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        fixedTypoButton.setTitle(WMFLocalizedStringWithDefaultValue("edit-summary-choice-fixed-typos", nil, nil, "Fixed typo", "Button text for quick 'fixed typos' edit summary selection"), for: .normal)
        fixedGrammarButton.setTitle(WMFLocalizedStringWithDefaultValue("edit-summary-choice-fixed-grammar", nil, nil, "Fixed grammar", "Button text for quick 'improved grammar' edit summary selection"), for: .normal)
        addedLinksButton.setTitle(WMFLocalizedStringWithDefaultValue("edit-summary-choice-linked-words", nil, nil, "Added links", "Button text for quick 'link addition' edit summary selection"), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        summaryTextField.becomeFirstResponder()
    }
    
    @IBAction private func learnMoreButtonTapped(sender: UIButton) {
        delegate?.learnMoreButtonTapped(sender: sender)
    }

    @objc public func textFieldDidChange(textField: UITextField){
        notifyDelegateOfSummaryChange()
    }

    private func notifyDelegateOfSummaryChange() {
        delegate?.summaryChanged(newSummary: summaryTextField.text ?? "")
    }

    @IBAction private func cannedSummaryButtonTapped(sender: UIButton) {
        summaryTextField.text = sender.titleLabel?.text
        notifyDelegateOfSummaryChange()
        guard let buttonType = EditSummaryViewCannedButtonType(rawValue: sender.tag) else {
            assertionFailure("Expected button type not found")
            return
        }
        delegate?.cannedButtonTapped(type: buttonType)
    }

    public func apply(theme: Theme) {
        view.backgroundColor = theme.colors.paperBackground
        dividerView.backgroundColor = theme.colors.border
        
        addSummaryLabel.textColor = theme.colors.secondaryText
        learnMoreButton.titleLabel?.textColor = theme.colors.link
        fixedTypoButton.titleLabel?.textColor = theme.colors.link
        fixedGrammarButton.titleLabel?.textColor = theme.colors.link
        addedLinksButton.titleLabel?.textColor = theme.colors.link
        summaryTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: theme.colors.tertiaryText])

        fixedTypoButton.backgroundColor = theme.colors.border
        fixedGrammarButton.backgroundColor = theme.colors.border
        addedLinksButton.backgroundColor = theme.colors.border
        summaryTextField.textColor = theme.colors.primaryText
    }
}

extension EditSummaryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //save()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        return newLength <= EditSummaryViewController.maximumSummaryLength
    }
}

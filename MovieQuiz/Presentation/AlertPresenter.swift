import Foundation
import UIKit

class AlertPresenter: AlertPresenterProtocol {
    private weak var controller : UIViewController?
    
    init (_ controller: UIViewController) {
        self.controller = controller
    }
    
    func showAlert(alert model: AlertModel) {
        guard let controller = controller else { return }
        
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = model.accesibilityIdentifier
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in model.completion() }
        
        alert.addAction(action)
        
        controller.present(alert, animated: true, completion: nil)
    }
}

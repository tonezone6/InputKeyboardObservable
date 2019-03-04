# Input keyboard observable
Handling text inputs (UITextField, UITextView) embeded in a UIScrollView when keyboard is presented.

## Getting Started
All you have to do is to adopt InputKeyboardObservable protocol in your custom text input

```
class RoundedTextField: UITextField, InputKeyboardObservable {
  // ...
}
```
and then, inherit from InputKeyboardObservableViewController

```
class ViewController: InputKeyboardObservableViewController {
  // ...
}
```

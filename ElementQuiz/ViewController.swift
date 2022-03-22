//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Park JooHyun on 2022/03/20.
//

import UIKit

enum Mode {
    case flashCard
    case quiz
}

enum State {
    case question
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var orderSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList: [String] = []
    
    var currentElementIndex = 0
    var mode: Mode = .flashCard {
        // property observer : 해당 property값이 변경될 때마다 코드 실행
        didSet {
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            
            updateUI()
        }
    }
    var state: State = .question
    
    // 퀴즈 모드 상태
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    // 모드에 따라 앱 UI 변경 메서드를 호출한다.
    func updateUI() {
        // 모드에 관계없이 이미지 업데이트
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        // 모드에 따라 다른 메서드 호출
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    // 플래시카드 모드에서 앱 UI를 변경한다.
    func updateFlashCardUI(elementName: String) {
        // segment 컨트롤
        modeSelector.selectedSegmentIndex = 0
        
        // 버튼
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        
        // 텍스트필드, 키보드
        /*
         상태가 변경되지 않는데도 굳이 매번 호출해야하는 이유
            이유 1. 해당 코드는 크게 부하를 주지 않음
            이유 2. 간결하고 이해하기 쉬운 코드 (언제 키보드를 숨겨야할지 따질 필요 X)
         */
        textField.isHidden = true
        textField.resignFirstResponder() // 키보드 숨김
        
        // 정답 라벨
        if state == .question {
            answerLabel.text = "?"
        } else {
            answerLabel.text = elementName
        }
    }
    
    // 퀴즈 모드에서 앱 UI를 변경한다.
    func updateQuizUI(elementName: String) {
        // segment 컨트롤
        modeSelector.selectedSegmentIndex = 1
        
        // 버튼
        showAnswerButton.isHidden = true
        
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
        
        // 텍스트필드, 키보드
        textField.isHidden = false
        
        switch state {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder() // 키보드 띄우기
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder() // 키보드 숨김
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        // 정답 라벨
        switch state {
        case .question:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "❌\nCorrect Answer: " + elementName
            }
        case .score:
            answerLabel.text = ""
        }
        
        // 점수 보여줌
        if state == .score {
            displayScoreAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        elementList = fixedElementList
        mode = .flashCard
    }

    @IBAction func showAnswer(_ sender: UIButton) {
        state = .answer
        
        updateUI()
    }
    
    @IBAction func next(_ sender: UIButton) {
        currentElementIndex += 1
        
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        
        state = .question
        
        updateUI()
    }
    
    @IBAction func switchModes(_ sender: UISegmentedControl) {
        if orderSelector.selectedSegmentIndex == 0 {
            elementList = fixedElementList
        } else {
            elementList = fixedElementList.shuffled()
        }
        
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
    
    // 플래시 카드 모드 초기화
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
    }
    
    // 퀴즈 모드 초기화
    func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }
    
    // 사용자가 키보드 엔터를 누르면 실행됨
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 텍스트필드의 텍스트 가져옴
        let textFieldContents = textField.text!
        
        // 사용자가 정답을 맞췄는지 판별 후, 퀴즈 상태 업데이트
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        
        // 정답 화면에 보여줌
        state = .answer
        
        updateUI()
        
        return true
    }
    
    // 퀴즈점수를 보여주는 알림을 띄운다.
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count).", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:)) // callback
        
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    // score 알림에서 ok버튼을 누를 경우 실행
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
}


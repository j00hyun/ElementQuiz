//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Park JooHyun on 2022/03/20.
//

import UIKit

enum Mode {
    case flashCard
    case freeResponse
    case multiChoice
}

enum State {
    case question
    case answer
    case score
    case delete
}

enum Order {
    case predictable
    case randomize
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var orderSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mistakeLabel: UILabel!
    @IBOutlet weak var choice1: UIButton!
    @IBOutlet weak var choice2: UIButton!
    @IBOutlet weak var choice3: UIButton!
    
    var fixedElementList: [Element] = [
        Element(name: "Carbon"),
        Element(name: "Gold"),
        Element(name: "Chlorine"),
        Element(name: "Sodium")
    ]
    
    var elementList: [Element] = []
    
    var currentElementIndex = 0
    var mode: Mode = .flashCard {
        // property observer : 해당 property값이 변경될 때마다 코드 실행
        didSet {
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .freeResponse:
                setupFreeResponse()
            case .multiChoice:
                setupMultiChoice()
            }
            
            updateUI()
        }
    }
    var state: State = .question
    
    // 퀴즈 모드 상태
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    // 원소 순서 랜덤 여부
    var order: Order = .predictable {
        didSet {
            setupOrder()
        }
    }
    
    // 원소당 틀린 평균 횟수
    var averageMisses = 0
    
    // 모드에 따라 앱 UI 변경 메서드를 호출한다.
    func updateUI() {
        // 모드에 관계없이 이미지 업데이트
        let elementName = elementList[currentElementIndex].name
        let image = UIImage(named: elementName)
        imageView.image = image
        
        // 자주 틀린 문제 체크
        if elementList[currentElementIndex].misstimes > averageMisses {
            mistakeLabel.text = "most mistake !!"
        } else {
            mistakeLabel.text = ""
        }
        
        // 선택지 숨기기
        choice1.isHidden = true
        choice2.isHidden = true
        choice3.isHidden = true
        
        // 모드에 따라 다른 메서드 호출
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .freeResponse:
            updateFreeResponseUI(elementName: elementName)
        case .multiChoice:
            updateMultiChoiceUI(elementName: elementName)
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
        
        if state == .question {
            showAnswerButton.setTitle("Show Answer", for: .normal)
            showAnswerButton.tintColor = .systemBlue
        } else {
            showAnswerButton.setTitle("Delete Element", for: .normal)
            showAnswerButton.tintColor = .systemRed
        }
        
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
        
        // 삭제 알림 띄움
        if state == .delete {
            displayDeleteAlert()
        }
    }
    
    // 퀴즈 모드에서 앱 UI를 변경한다.
    func updateFreeResponseUI(elementName: String) {
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
        case .delete:
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
        case .delete:
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
        case .delete:
            answerLabel.text = ""
        }
        
        // 점수 보여줌
        if state == .score {
            displayScoreAlert()
        }
    }
    
    func updateMultiChoiceUI(elementName: String) {
        // segment 컨트롤
        modeSelector.selectedSegmentIndex = 2
        
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
        case .delete:
            nextButton.isEnabled = false
        }
        
        // 텍스트필드, 키보드
        textField.isHidden = true
        textField.resignFirstResponder()
        
        // 선택지
        let choices = [choice1, choice2, choice3]
        
        if state == .question {
            for choice in choices {
                choice!.isHidden = false
                choice!.isEnabled = true
                choice!.isSelected = false
            }
            
            let shuffledChoices = choices.shuffled()
            var elements = elementList
            
            shuffledChoices[0]!.setTitle(elementName, for: .normal)
            elements.remove(at: currentElementIndex)
            elements = elements.shuffled()
            
            for i in 1 ... 2 {
                shuffledChoices[i]!.setTitle(elements.popLast()?.name, for: .normal)
            }
        } else if state == .answer {
            for choice in choices {
                choice!.isHidden = false
                choice!.isEnabled = false
            }
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
        case .delete:
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
        order = .predictable
        mode = .flashCard
    }

    @IBAction func showAnswer(_ sender: UIButton) {
        if state == .answer {
            state = .delete
        } else {
            state = .answer
        }
        
        updateUI()
    }
    
    @IBAction func next(_ sender: UIButton) {
        currentElementIndex += 1
        
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            
            if mode == .freeResponse || mode == .multiChoice {
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
            order = .predictable
        } else {
            order = .randomize
        }
        
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else if modeSelector.selectedSegmentIndex == 1 {
            mode = .freeResponse
        } else {
            mode = .multiChoice
        }
    }
    
    // 플래시 카드 모드 초기화
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
    }
    
    // 키보드 입력 퀴즈 모드 초기화
    func setupFreeResponse() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }
    
    // 선택 퀴즈 모드 초기화
    func setupMultiChoice() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }
    
    // 문제 순서 설정
    func setupOrder() {
        switch order {
        case .predictable:
            elementList = fixedElementList
        case .randomize:
            elementList = fixedElementList.shuffled()
        }
    }
    
    // 사용자가 키보드 엔터를 누르면 실행됨
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        answerProcess(myAnswer: textField.text!)
        
        // 정답 화면에 보여줌
        state = .answer
        
        updateUI()
        
        return true
    }
    
    // multiple choice 모드에서 정답 선택하면 실행
    @IBAction func selectChoice(_ sender: UIButton) {
        answerProcess(myAnswer: sender.currentTitle!)
        
        // 정답 화면에 보여줌
        state = .answer
        
        updateUI()
    }
    
    // 퀴즈모드에서 정답 맞는지 확인
    func answerProcess(myAnswer: String) {
        let elementName = elementList[currentElementIndex].name
        
        if myAnswer.lowercased() == elementName.lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
            
            // 해당 원소 틀린 횟수 1 증가
            for element in fixedElementList {
                if element.name == elementName {
                    element.updateMissTimes()
                }
            }
            
            calculateMissAverage()
        }
    }
    
    // 원소당 틀린 평균 횟수 초기화
    func calculateMissAverage() {
        var sumOfMisses = 0
        
        for element in fixedElementList {
            sumOfMisses += element.misstimes
        }
        
        averageMisses = sumOfMisses / fixedElementList.count
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
        setupOrder()
        mode = .flashCard
    }
    
    // 원소를 삭제할 것인지 물어보는 알림을 띄운다.
    func displayDeleteAlert() {
        let alert = UIAlertController(title: "Delete Element", message: "Are you sure you want to delete it?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive, handler: deleteElement(_:))
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: deleteAlertCancel(_:))
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // delete 알림에서 ok버튼을 누를 경우 실행
    func deleteElement(_ action: UIAlertAction) {
        
        // 원소가 마지막 1개 밖에 안남은 상태일 때 삭제 거절 알림 띄움
        if fixedElementList.count <= 1 {
            
            let alert = UIAlertController(title: "Error", message: "You can't delete the last element.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .default, handler: deleteAlertCancel(_:))

            alert.addAction(dismissAction)
            
            present(alert, animated: true, completion: nil)
            
        } else {
            
            fixedElementList.remove(at: currentElementIndex)
            calculateMissAverage()
            setupOrder()
            mode = .flashCard
            
        }
    }
    
    // delete 알림에서 no버튼을 누를 경우 실행
    func deleteAlertCancel(_ action: UIAlertAction) {
        state = .answer
        updateUI()
    }
}


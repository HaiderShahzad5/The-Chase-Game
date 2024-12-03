//
//  TheChaseViewController.swift
//  TheChase
//
//

import UIKit
import AVFoundation

class TheChaseViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var bottomQuestionsView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel1: UILabel!
    @IBOutlet weak var answerLabel2: UILabel!
    @IBOutlet weak var answerLabel3: UILabel!
    @IBOutlet weak var resultLabel: UILabel!

    @IBOutlet weak var ladderStep7Button: UIButton!
    @IBOutlet weak var ladderStep6Button: UIButton!
    @IBOutlet weak var ladderStep5Button: UIButton!
    @IBOutlet weak var ladderStep4Button: UIButton!
    @IBOutlet weak var ladderStep3Button: UIButton!
    @IBOutlet weak var ladderStep2Button: UIButton!
    @IBOutlet weak var ladderStep1Button: UIButton!
    
//Variables
    var currentQuestionIndex = 0 {
        didSet{
            setQuestionOnIndex()
        }
    }
    var selectedAmount = 0
    var timer: Timer?
    var timerCount = 0
    var shuffledQuestions: [QuestionItems] = [] // Holds the randomized questions
    var gameStarted = false
    var chaserStep = 7 {
        didSet{
            setLadderStepping()
        }
    }
    var playerStep = 0 {
        didSet{
            setLadderStepping()
        }
    }
    var audioPlayer: AVAudioPlayer?
    var audioClips = [String:URL]()
    
    
//IBActions
    @IBAction func didTapLaddarStep6(_ sender: Any) {
        guard gameStarted == false else { return }
        gameStarted = true
        setViewHidding(hidden: false)
        selectedAmount = 30000
        playerStep = 6
        ladderStep6Button.backgroundColor = .tintColor
        startTimer()
        startSound()
    }
    @IBAction func didTapLaddarStep5(_ sender: Any) {
        guard gameStarted == false else { return }
        gameStarted = true
        setViewHidding(hidden: false)
        selectedAmount = 7000
        playerStep = 5
        ladderStep5Button.backgroundColor = .tintColor
        startTimer()
        startSound()
    }
    @IBAction func didTapLaddarStep4(_ sender: Any) {
        guard gameStarted == false else { return }
        gameStarted = true
        setViewHidding(hidden: false)
        selectedAmount = 1000
        playerStep = 4
        ladderStep4Button.backgroundColor = .tintColor
        startTimer()
        startSound()
    }
    
    @IBAction func didTapAnswer1(_ sender: Any) {
        CheckAnswer(SelectedAnswer: 1)
    }
    @IBAction func didTapAnswer2(_ sender: Any) {
        CheckAnswer(SelectedAnswer: 2)
    }
    @IBAction func didTapAnswer3(_ sender: Any) {
        CheckAnswer(SelectedAnswer: 3)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let questions = getJSONQuestionData()?.questions {
            shuffledQuestions = questions.shuffled() // Randomize question order
        }
        currentQuestionIndex = 0
        setViewHidding(hidden: true)
        setLadderDefaultColor()
        setHighlightedStartLadder()
        timerCount = 0
        // Load and shuffle questions
        audioClips = getAllMP3FileNameURLs() //Load the details of all the audio files
    }
}
extension TheChaseViewController{
    func setQuestionOnIndex() {
        if let questionItem = getQuestionItems() {
            questionLabel.text = questionItem.question_text
            answerLabel1.text  = questionItem.answers[0]
            answerLabel2.text  = questionItem.answers[1]
            answerLabel3.text  = questionItem.answers[2]
        }
    }
    //Use this function for questions in file sorting
//    func getQuestionItems() -> QuestionItems? {
//        let theQuizQuestions = getJSONQuestionData()   //Fetching data from JSON file
//        if let theQuizQuestions = theQuizQuestions, currentQuestionIndex <= theQuizQuestions.questions.count - 1 {   //Safe unwrap the data returned to prevent App from crashing
//            return theQuizQuestions.questions[currentQuestionIndex]
//        }
//        return nil
//    }
    //Use this function to get suffled questions from the file
    func getQuestionItems() -> QuestionItems? {
        guard currentQuestionIndex < shuffledQuestions.count else { return nil }
        return shuffledQuestions[currentQuestionIndex]
    }
    func CheckAnswer(SelectedAnswer: Int) {
        startSound()
        if let theQuizQuestions = getQuestionItems() {   //Safe unwrap the data returned to prevent App from crashing
            if theQuizQuestions.correct == SelectedAnswer {
                resultLabel.text = "Correct"
                playerStep -= 1
            }else{
                resultLabel.text = "Incorrect"
            }
            stopTimer()
            startTimer()
            chaserStep -= 1
            currentQuestionIndex += 1
        }
    }
    func skipQuestion() {
        startSound()
        stopTimer()
        resultLabel.text = "Skipped"
        chaserStep -= 1
        currentQuestionIndex += 1
        startTimer()
    }
    func setLadderDefaultColor() {
        let ladder = [ladderStep1Button, ladderStep2Button, ladderStep3Button, ladderStep4Button, ladderStep5Button, ladderStep6Button, ladderStep7Button]
        ladder.forEach { button in
            button?.backgroundColor = .systemCyan
        }
    }
    func setHighlightedStartLadder() {
        let ladder = [ladderStep4Button, ladderStep5Button, ladderStep6Button]
        ladder.forEach { button in
            button?.backgroundColor = .systemMint
        }
    }
    func setViewHidding(hidden: Bool) {
        bottomQuestionsView.isHidden = hidden
        timerLabel.isHidden = hidden
        resultLabel.isHidden = hidden
    }
    func setLadderStepping() {
        let ladder = [ladderStep1Button, ladderStep2Button, ladderStep3Button, ladderStep4Button, ladderStep5Button, ladderStep6Button, ladderStep7Button]
        if chaserStep + 1 == playerStep {
            // Game Over
            currentQuestionIndex = 0
            setViewHidding(hidden: true)
            setLadderDefaultColor()
            setHighlightedStartLadder()
            timerCount = 0
            stopTimer()
            // Define the dictionary to save
            let recentGameData: [String: Any] = [
                "amount": selectedAmount,
                "player": "Chaser"
            ]

            // Save the dictionary in UserDefaults
            UserDefaults.standard.set(recentGameData, forKey: "recentGame")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let viewController = baseController {
                    viewController.recentGameTableView.reloadData()
                }
                self.dismiss(animated: true)
            }
        }else if playerStep == 0{
            // Player Won
            let highScore = UserDefaults.standard.integer(forKey: "highScore")
            if highScore == 0 || selectedAmount > highScore {
                UserDefaults.standard.set(selectedAmount, forKey: "highScore")
            }
            // Define the dictionary to save
            let recentGameData: [String: Any] = [
                "amount": selectedAmount,
                "player": "Player"
            ]

            // Save the dictionary in UserDefaults
            UserDefaults.standard.set(recentGameData, forKey: "recentGame")
            if let viewController = baseController {
                viewController.setHighScore()
                viewController.recentGameTableView.reloadData()
            }
            currentQuestionIndex = 0
            setViewHidding(hidden: true)
            setLadderDefaultColor()
            setHighlightedStartLadder()
            timerCount = 0
            stopTimer()
            self.dismiss(animated: true)
            return
        }
        ladder.forEach { button in
            button?.backgroundColor = .systemCyan
        }
        ladder[playerStep - 1]?.backgroundColor = .tintColor
        ladder.forEach { button in
            button?.setTitle("", for: .normal)
        }
        for i in 0..<playerStep {
            ladder[i]?.backgroundColor = .tintColor
        }
        
        let chaserLadder = ladder.suffix(from: chaserStep)
        chaserLadder.forEach { button in
            button?.backgroundColor = .red
        }
        
        ladder[playerStep - 1]?.setTitle("£\(selectedAmount)", for: .normal)
    }
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        }
    }
    func stopTimer() {
        if timer != nil {
            timer?.invalidate() //stop the timer
            timer = nil
            timerLabel.text = "00"
            timerCount = 0
        }
    }
    func setupAudioPlayer(toPlay audioFileURL:URL) {
        do {
            try self.audioPlayer = AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Can't play the audio \(audioFileURL.absoluteString)")
            print(error.localizedDescription)
        }
    }
    func getAllMP3FileNameURLs() -> [String:URL] {
        var filePaths = [URL]() //URL array
        var audioFileNames = [String]() //String array
        var theResult = [String:URL]()

        let bundlePath = Bundle.main.bundleURL
        do {
            try FileManager.default.createDirectory(atPath: bundlePath.relativePath, withIntermediateDirectories: true)
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: bundlePath, includingPropertiesForKeys: nil, options: [])
            
            // filter the directory contents
            filePaths = directoryContents.filter{ $0.pathExtension == "mp3" }
            
            //get the file names, without the extensions
            audioFileNames = filePaths.map{ $0.deletingPathExtension().lastPathComponent }
        } catch {
            print(error.localizedDescription) //output the error
        }
        //print(audioFileNames) //for debugging purposes only
        for loop in 0..<filePaths.count { //Build up the dictionary.
            theResult[audioFileNames[loop]] = filePaths[loop]
        }
        return theResult
    }
    func startSound() {
        if (self.audioPlayer == nil) || (self.audioPlayer?.isPlaying == false) {
            //select a random audio clip URL from those in the audioClips dictionary
            let (_,randomClipURL) = audioClips.randomElement()!
            setupAudioPlayer(toPlay: randomClipURL) //prepare it for playing
            self.audioPlayer?.play() //and play it
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.audioPlayer?.isPlaying == true { //we can only stop it if it's still playing
                self.audioPlayer?.stop()
                self.audioPlayer = nil
            }
        }
    }
}
extension TheChaseViewController{
    @objc  func timerFired() {
        timerCount += 1 //increment our seconds counter
        timerLabel.text = String(format: "%02d", timerCount)
        if timerCount == 15 {
            skipQuestion()
        }
    }
}

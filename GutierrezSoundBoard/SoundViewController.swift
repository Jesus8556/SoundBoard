//
//  SoundViewController.swift
//  GutierrezSoundBoard
//
//  Created by Luis Gutierrez on 1/11/23.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    @IBOutlet weak var grabarButton: UIButton!
    
    @IBOutlet weak var reproducirButton: UIButton!
    
    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var tiempoLabel: UILabel!
    @IBOutlet weak var agregarButton: UIButton!
    
    var grabarAuido:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer: Timer?
    var elpasedTime: TimeInterval = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate() // Detén el timer al salir de la vista
    }

    
    @IBAction func grabarTapped(_ sender: Any) {
        
        if grabarAuido!.isRecording{
            grabarAuido?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            timer?.invalidate()
        }else{
            grabarAuido?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            startTimer()
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch{}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context:context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.tiempo = tiempoLabel.text
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
        
    }
    func startTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){
            [weak self] timer in
            guard let self = self else {return}
            self.elpasedTime += 1.0
            self.updateTimeLabel()
        }
    }
    func updateTimeLabel() {
        let minutes = Int(elpasedTime) / 60
        let seconds = Int(elpasedTime) % 60
        tiempoLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    func configurarGrabacion(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default,options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("*********************")
            print(audioURL!)
            print("*********************")
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAuido = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAuido!.prepareToRecord()
        }catch let error as NSError{
            print(error)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

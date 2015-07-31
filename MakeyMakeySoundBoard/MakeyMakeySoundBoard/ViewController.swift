//
//  ViewController.swift
//  MakeyMakeySoundBoard
//
//  Created by Matthew Prockup on 7/21/15.
//  Copyright (c) 2015 Matthew Prockup. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIKeyInput, UITableViewDelegate, UITableViewDataSource{
    
    
    // MARK: Declare
    
    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var helpButton: UIButton!
    
    //create list of keymap strings
    var items: [String] = [ "D5: w",
                            "D4: a",
                            "D3: s",
                            "D2: d",
                            "D1: f",
                            "D0: g",
                            "CLICK: c",
                            "SPACE:  \' \'",
                            "ARROW UP: u",
                            "ARROW DOWN: v",
                            "ARROW LEFT: l",
                            "ARROW RIGHT: r",
                            "A5: 5",
                            "A4: 4",
                            "A3: 3",
                            "A2: 2",
                            "A1: 1",
                            "A0: 0"]
    
    //crate list of keymap keycodes
    var itemKeys  = [   "w",
                        "a",
                        "s",
                        "d",
                        "f",
                        "g",
                        "c",
                        " ",
                        "u",
                        "v",
                        "l",
                        "r",
                        "5",
                        "4",
                        "3",
                        "2",
                        "1",
                        "0"]
    
    
    //popover for loading files
    var popOver:UIPopoverController!
 
    //popover for help menu
    var helpPopOver:UIPopoverController!
    
    //array for filepaths
    var fullPaths:NSMutableArray = [];
    
    //array for audio file names
    var fileNames:NSMutableArray=[];
    
    //create a flag for the selected table row in the keymap tableview.
    //This is needed for reference once the file is selected in the files tableview popover
    var selectedIndexPath:NSIndexPath!
    

    
    //dictionary of audio sample buffers for easy retrieval
    var samplesDict = [String:AVAudioPlayer]()
    
    //dict of indicators based keyed on keypress events
    var leds = [String:UIView]()
    
    //dict of filebuttons based keyed on keypress events
    //file buttons show the file name assigned to a keymapping
    //you can also press them to preview the file
    var fileButtons = [String:UIButton]()
    
    //MARK: Startup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //copy audio examples from resources into docs folder so theres something there from the start
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        var snareFile = NSBundle.mainBundle().pathForResource("Snare", ofType: "wav")
        var kickFile = NSBundle.mainBundle().pathForResource("Kick", ofType: "wav")
        var hihatFile = NSBundle.mainBundle().pathForResource("HiHat", ofType: "wav")
        var crashFile = NSBundle.mainBundle().pathForResource("Crash", ofType: "wav")
    
        var error:NSError?
        NSFileManager.defaultManager().copyItemAtPath(snareFile!, toPath: (documentsPath as String + "/Snare.wav"), error: &error)
        NSFileManager.defaultManager().copyItemAtPath(kickFile!, toPath:(documentsPath as String + "/Kick.wav"), error: &error)
        NSFileManager.defaultManager().copyItemAtPath(hihatFile!, toPath: (documentsPath as String + "/HiHat.wav"), error: &error)
        NSFileManager.defaultManager().copyItemAtPath(crashFile!, toPath: (documentsPath as String + "/Crash.wav"), error: &error)

        //get List of wave files in docs dir to display in popover
        var directoryContent = NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsPath as String, error: nil)
        var cnt = 0
        for var i = 0; i < directoryContent?.count; ++i {
            
            var fp = "\(documentsPath)/\((directoryContent as! [String])[i])"
            var filename = "\((directoryContent as! [String])[i])"
            var components:NSArray = filename.componentsSeparatedByString(".")
            var suffix:String = components[components.count-1] as! String
            
            //make sure its an audio file supported
            if suffix == "wav" || suffix=="mp3" || suffix=="aiff" || suffix=="m4a"{
                ++cnt
                println("\(cnt) : \(documentsPath)/\((directoryContent as! [String])[i])")
                fullPaths.addObject(fp)
                fileNames.addObject(filename)
            }
        }
        
        
        //make this UIViewVontroller the first resoponder (aka listener) to the keyboard
        becomeFirstResponder()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //Start AudioSession
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Text input response
    
    //Allow this view to be a first responder in the first place
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //These function below are needed to adhere to the UIKeyInput protocol
    func hasText() -> Bool {
        return true
    }
    
    //This event is fired on a key press. text:String is string of the pressed key
    func insertText(text: String) {
        play(text)
        return
    }
    
    func deleteBackward() {
        return
    }
    
    
    //MARK: Table Setup
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Check main table vs loadfile table in popover
        if tableView == self.tableView{
            return self.items.count;
        }
        else{
            return self.fileNames.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var  cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell

        //Check main table vs loadfile table in popover
        if tableView == self.tableView{//main table
            
            //create cell
            cell.textLabel?.text = self.items[indexPath.row]
            var led:UIView = UIView(frame: CGRectMake(cell.frame.width, cell.frame.height/5, cell.frame.height/5*3, cell.frame.height/5*3))
            
            //create indicator
            led.backgroundColor = UIColor.redColor()
            led.alpha = 0.0
            leds[itemKeys[indexPath.row]] = led //refer to  it based on keypress
            cell.addSubview(leds[itemKeys[indexPath.row]]!)
            
            
            //create file name button
            var fileButton:UIButton = UIButton(frame: CGRectMake(cell.frame.width + 100, cell.frame.height/5, 200, cell.frame.height/5*3))
            fileButton.titleLabel!.font = UIFont(name: "Menlo", size: CGFloat(16))
            fileButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            fileButton.addTarget(self, action: "soundButtonPressed:", forControlEvents: UIControlEvents.TouchDown)
            
            //refer to  it based on keypress
            fileButtons[itemKeys[indexPath.row]] = fileButton
            
            //tag to respond to seperate button events in the same callback
            fileButtons[itemKeys[indexPath.row]]!.tag = fileButtons.count - 1
            
            
            //add cell to tableview
            cell.addSubview(fileButtons[itemKeys[indexPath.row]]!)
        }
        else{//popover for file names
            
            //make cell text the name of the file
            cell.textLabel?.text = self.fileNames.objectAtIndex(indexPath.row) as? String
        }
        
        //make the cell match the UI design
        cell.textLabel?.textColor = UIColor.redColor()
        cell.textLabel?.font = UIFont(name: "Menlo", size: CGFloat(22))
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Selected: \(indexPath.row)")
        
        //Check main table vs loadfile table in popover
        if tableView == self.tableView{
            
            //get global reference of selected row
            selectedIndexPath = indexPath
            
            
            //create load file popover
            var popW:CGFloat = 250;
            var popH:CGFloat = 400;
            var popOverContent:UIViewController = UIViewController()
            var popOverView:UIView = UIView()
            var tableViewFiles:UITableView = UITableView(frame: CGRectMake(0,0,popW,popH))
            tableViewFiles.rowHeight = 40
            
            popOverView.addSubview(tableViewFiles)
            
            popOverContent.view = popOverView
            popOverContent.preferredContentSize = CGSizeMake(popW, popH)
            self.popOver = UIPopoverController(contentViewController: popOverContent)
            
            tableViewFiles.delegate = self
            tableViewFiles.dataSource = self
            
            self.popOver.presentPopoverFromRect((tableView.cellForRowAtIndexPath(indexPath)?.frame as CGRect?)!, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            
        }
        else{ // load the file selected to a key row
            println("File Selected: \(fileNames.objectAtIndex(indexPath.row))")
            popOver.dismissPopoverAnimated(true)
            loadFile(itemKeys[selectedIndexPath.row], filePathToLoad: fullPaths.objectAtIndex(indexPath.row) as! String)
            
            self.tableView.cellForRowAtIndexPath(selectedIndexPath)?.selected = false
        }
        
    }
    
    
    //MARK: Table Swipe Actions
    
    //Swipe right to show a clear button to remove a sound mapping
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        //Check main table vs loadfile table in popover
        if tableView == self.tableView{
            let delete = UITableViewRowAction(style: .Normal, title: "Clear") { action, index in
                println("remove tapped")
                
                //remove file
                var key = self.itemKeys[indexPath.row]
                self.fileButtons[key]?.setTitle("", forState: UIControlState.Normal)
                
                if self.samplesDict[key] != nil {
                    self.samplesDict.removeValueForKey(key)
                }
                tableView.editing=false
            }
            
            delete.backgroundColor = UIColor.redColor()
            return [delete]
        }
        else{
            return nil
        }
    }
    
    //Make rows swipeable
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        
        if tableView == self.tableView{
            return true
        }
        else{
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
        
    }
    
    
    
    //MARK: Audio Playback
    
    //load an audio file to respond to a keypress
    func loadFile(key:String,filePathToLoad:String){
        
        //create audio path url
        var audioURL:NSURL = NSURL(fileURLWithPath: filePathToLoad)!
        
        //create audio player and load file
        var audioPlayer = AVAudioPlayer()
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: audioURL, error: &error)
        audioPlayer.prepareToPlay()
        
        //load into samples dictionary
        samplesDict[key] = audioPlayer
        
        //put filename on preview button
        var fileNameComponents = filePathToLoad.componentsSeparatedByString("/")
        self.fileButtons[key]?.setTitle(fileNameComponents[fileNameComponents.count - 1], forState: UIControlState.Normal)
        
    }
    
    func play(key:String){
        
        //check if sample is loaded
        if samplesDict[key] != nil {
            
            //reset to time 0 and play sample
            samplesDict[key]?.currentTime=0
            samplesDict[key]?.play()
            
            //light indicator green abd fade based on length of sample
            leds[key]?.backgroundColor = UIColor.greenColor()
            leds[key]?.alpha = 1.0
            UIView.animateWithDuration(self.samplesDict[key]!.duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.leds[key]?.alpha = 0.0
                }, completion: nil)
            
            
        }
        // No file is loaded, flash red
        else{
            leds[key]?.alpha = 1.0
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.leds[key]?.alpha = 0.0
                }, completion: nil)
        }
        
        
    }
    
  
    //Make a simple help menu popover
    @IBAction func helpPressed(sender: AnyObject) {
        var popW:CGFloat = self.view.frame.width/3 * 2;
        var popH:CGFloat = self.view.frame.height/2;
        
        var popOverContent:UIViewController = UIViewController()
        var popOverView:UIView = UIView(frame: CGRectMake(0, 0, popW, popH))
        popOverView.backgroundColor = UIColor.whiteColor()
        var helpText:UITextView = UITextView(frame: CGRectMake(10, 10, popW-20, popH-20))
        helpText.editable = false
        helpText.dataDetectorTypes = UIDataDetectorTypes.Link;
        helpText.text =         "Welcome to the MaKeyMakey Soundboard App! \n\n"
                            +   "With this application, you can connect a modified MaKey MaKey to an iPad and trigger sounds.\n\n"
                            +   "CONNECTING THE MAKEYMAKEY\n"
                            +   "===========================\n"
                            +   "Step 1: Modify the MaKeyMakey. Download the modified Arduino source and install on your MakeyMakey\n"
                            +   "    http://music.ece.drexel.edu (code will eventially be here)\n\n"
                            +   "Step 2: Use the Apple Camera Connection Kit and attach a powered USB hub. The iPad cannot supply enough power to the MaKey MaKey, so a hub that has an external AC power source is requred.\n\n"
                            +   "Step 3: Connect the MakeyMakey to one of the ports in that hub\n\n\n"
                            +   "USING THE APP \n"
                            +   "===========================\n"
                            +   "- Touch a key on the MakeyMakey, you should see a light appear in a corresponding row in the table. \n\n"
                            +   "- Tap a row and select a sound. That sound will then be played each time you touch that key. (An indicator should turn green and last the length of the sound) \n\n"
                            +   "- Additional sounds can be added through iTunes File Sharing \n"
                                "    - Plug iPad to computer\n"
                                "    - Open iTunes and select the iPad icon on the top left\n"
                                "    - Select the Apps in the table on the right.\n"
                                "    - Scroll down to Filesharing and select MMSoundB\n"
                                "    - Drag in any sounds you want here (aiff, mp3, m4a, wav)\n\n"
                            +   "    - The Makey Makey acts as a simple usb keyboard. You can trigger sonds in this app with a simple keyboard as well. Key presses are case sensitive. \n\n"
                            +   "- Swipe right on a row to remove the assigned sound. \n\n\n\n"
                            +   "This app was designed by Matthew Prockup and the Drexel App Lab as part of the Summer Music Technology program at Drexel University \n\n"
                            +   "Copyright (c) 2015 Matthew Prockup. All rights reserved.\n"
        
        helpText.font = UIFont(name: "Menlo", size: CGFloat(14))
        helpText.textColor = UIColor.redColor()
        
        popOverView.layer.borderColor = UIColor.redColor().CGColor
        popOverView.layer.borderWidth = 5.0
        
        popOverView.addSubview(helpText)
        popOverContent.view=popOverView
        
        self.helpPopOver = UIPopoverController(contentViewController: popOverContent)
        self.helpPopOver.popoverContentSize = CGSize(width: popW,height: popH)
        
        self.helpPopOver.presentPopoverFromRect(helpButton.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        
    }
    
    
    //MARK: Respond to Buttons
    @IBAction func showKeyboard(sender: AnyObject) {
        self.becomeFirstResponder()
    }
    
    //Present modal to save sound settings file
    @IBAction func saveButton(sender: AnyObject) {
        var saveAlert = UIAlertController(title: "Save Preset", message: "Are you sure you want to save? Previously saved data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        
        saveAlert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction!) in
            println("Preset Saved")
            self.savePreset()
        }))
        
        saveAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            println("Button Canceled")
        }))
        
        presentViewController(saveAlert, animated: true, completion: nil)
    }
    
    //present modal to load sound settings from file
    @IBAction func loadButton(sender: AnyObject) {
        var loadAlert = UIAlertController(title: "Load Preset", message: "Are you sure you want to Load? Current edited data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        
        loadAlert.addAction(UIAlertAction(title: "Load", style: .Default, handler: { (action: UIAlertAction!) in
            println("Preset Loaded")
            self.loadPreset()
        }))
        
        loadAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            println("Button Canceled")
        }))
    
        presentViewController(loadAlert, animated: true, completion: nil)
        
    }
    
    
    func soundButtonPressed(sender:UIButton)
    {
        
        var key:String = itemKeys[sender.tag]
        println("Play Pressed: \(sender.titleLabel?.text as String!), KEY: \(key)")
        
        play(key)
        
    }
    
    //MARK: Presets
    
    //Save presets "key:soundfile.type\nkey2:soundfile2.type "
    func savePreset(){
        var saveStr:String = ""
        for (key, value) in samplesDict {
            var filePath = ("\((value as AVAudioPlayer).url.path as String!)").componentsSeparatedByString("/")
            var fileName = filePath[filePath.count - 1]
            saveStr += "\(key):\(fileName)\n"
        }
        println(saveStr)
        
    
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        saveStr.writeToFile((documentsPath as String) + "/" + "savedPreset.txt", atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    //load presets
    func loadPreset(){
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let loadStr:String = String(contentsOfFile: (documentsPath as String) + "/" + "savedPreset.txt", encoding: NSUTF8StringEncoding, error: nil)!
        
        var filesList = loadStr.componentsSeparatedByString("\n")
        for f in filesList{
            
            if f != "" {
                var fileComponents = (f as String).componentsSeparatedByString(":")
                var key:String = fileComponents[0]
                var fileName:String = fileComponents[1]
                //            var filePathComponents = filePath.componentsSeparatedByString("/")
                //            var fileName:String = fileComponents[filePathComponents.count - 1]
                fileName = (documentsPath as String) + "/" + fileName
                self.loadFile(key, filePathToLoad: fileName)
            }
        }
        
        
    }
    
}


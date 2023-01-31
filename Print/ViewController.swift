import Cocoa
import Foundation
import AppKit
import WebKit
//ppd located in /etc/cups
class ViewController: NSViewController {
    let NSURLResponseUnknownLength = Int64(-1)
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var labelNotify: NSTextField!
    
    
    private let printernames = ["ROOM-01", "ROOM-02", "ROOM-03", "ROOM-04", "ROOM-05", "ROOM-06", "ROOM-07", "ROOM-08", "ROOM-09", "ROOM-10", "ROOM-11"]
    
    private let printerlists = ["ROOM-01 - Room 1", "ROOM-02 - Office", "ROOM-03 - Another office", "ROOM-04", "ROOM-05", "ROOM-06", "ROOM-07", "ROOM-08", "ROOM-09", "ROOM-10", "ROOM-11"]
    private let ppd = ["5073CDB0", "CEF129DB", "469E2FF2", "706D2F31", "7818D60B", "PCFEB5735", "AB8C732B", "49507747", "D8B88F5E", "9EAEDA70", "DD64FB3F"]
    private let IP = ["ipp://xxx.xxx.7.29", "ipp://xxx.xxx.7.20", "ipp://xxx.xxx.7.19", "ipp://xxx.xxx.7.23", "ipp://xxx.xxx.7.25", "socket://xxx.xxx.7.28", "ipp://xxx.xxx.7.24", "ipp://xxx.xxx.7.32", "ipp://xxx.xxx.7.33", "ipp://xxx.xxx.7.31", "socket://xxx.xxx.7.27"]
    
    var downloadResponse: URLResponse?
    var bytesReceived: Float = 0
    
    @IBOutlet weak var downloadURLTextField: NSTextField!
    @IBOutlet weak var downloadProgressTextField: NSTextField!
    
    @IBOutlet weak var menuItem: NSPopUpButton!
    @IBAction func addPrintBtn(_ sender: Any) {
        
        let task = Process()
        let pipe = Pipe()
        let errpipe = Pipe()
        let printName = printernames[menuItem.indexOfSelectedItem]
        let printIP = IP[menuItem.indexOfSelectedItem]
        
        task.launchPath = "/usr/sbin/lpadmin"
        if printName.range(of:"ROOM-01") != nil || printName.range(of:"ROOM-02") != nil {
            installSoftware()
            task.arguments = ["-p", "\(printName)", "-v", "\(printIP)", "-P", "/Users/Shared/PPD/KONICA-Bizhub-C558.ppd", "-o", "printer-is-shared=false", "-E"]
        }
        else if printName.range(of:"ROOM-03") != nil {
            installSoftware()
            task.arguments = ["-p", "\(printName)", "-v", "\(printIP)", "-P", "/Users/Shared/PPD/KONICA-Bizhub-C368.ppd", "-o", "printer-is-shared=false", "-E"]
        }
        else if printName.range(of:"ROOM-04") != nil {
            task.arguments = ["-p", "\(printName)", "-v", "\(printIP)", "-P", "/Users/Shared/PPD/RICOH-MP-C3003.ppd", "-o", "printer-is-shared=false", "-E"]
        }
        else if printName.range(of:"ROOM-05") != nil {
            task.arguments = ["-p", "\(printName)", "-v", "\(printIP)", "-P", "/Users/Shared/PPD/Lexmark-CS510de.ppd", "-o", "printer-is-shared=false", "-E"]
        }
        else if printName.range(of:"ROOM-06") != nil || printName.range(of:"ROOM-07") != nil ||
                    printName.range(of:"ROOM-08") != nil || printName.range(of:"ROOM-09") != nil{
            task.arguments = ["-p", "\(printName)", "-v", "\(printIP)", "-P", "/Users/Shared/PPD/Lexmark-MS415dn.ppd", "-o", "printer-is-shared=false", "-E"]
        }
        else if printName.range(of:"ROOM-10") != nil {
            task.arguments = ["-p", "\(printName)", "-v", "\(printIP)", "-P", "/Users/Shared/PPD/HP-LaserJet-M4345.ppd", "-o", "printer-is-shared=false", "-E"]
        }
        else if printName.range(of:"ROOM-11") != nil {
            task.arguments = ["-p", "\(printName)", "-v", "\(printIP)", "-P", "/Users/Shared/PPD/RICOH-Aficio-SP4310N.ppd", "-o", "printer-is-shared=false", "-E"]
        }
        else{
            task.arguments = ["-p", "\(printName)", "-v", "\(printIP)", "-P", "/Users/Shared/PPD/Generic.ppd", "-o", "printer-is-shared=false", "-E"]
        }
        
        task.standardOutput = pipe
        task.standardError = errpipe
        task.launch()
        task.waitUntilExit()
        let data = errpipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        if output.contains("No such file or directory")
        {
            labelNotify.stringValue = "PPD file is not found"
        }
        else
        {
            labelNotify.stringValue = "Printer \(printName) has been added."
        }
    }
    
    @IBAction func removeBtn(_ sender: Any) {
        
        let task:Process = Process()
        let pipe:Pipe = Pipe()
        let printName = printernames[menuItem.indexOfSelectedItem]
        
        task.launchPath = "/usr/sbin/lpadmin"
        task.arguments = ["-x", "\(printName)"]
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        // let slabel =
        labelNotify.stringValue = "Printer \(printName) has been removed."
    }
    
    func installSoftware() {
        labelNotify.stringValue = "Downloading printer software..."
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Users/Shared/C759_C658_C368_C287_C3851_109.pkg") {
            print("File exists /Users/Shared/PPD.zip")
        } else {
            let task:Process = Process()
            let pipe:Pipe = Pipe()
            task.launchPath = "/usr/bin/curl"
            task.arguments = ["-o", "/Users/Shared/C759_C658_C368_C287_C3851_109.pkg", "https://xxxxx/C759_C658_C368_C287_C3851_109.pkg"]
            task.standardOutput = pipe
            task.launch()
            task.waitUntilExit()
            
            let task2:Process = Process()
            let pipe2:Pipe = Pipe()
            task2.launchPath = "/usr/bin/open"
            task2.arguments = ["/Users/Shared/C759_C658_C368_C287_C3851_109.pkg"]
            task2.standardOutput = pipe2
            task2.launch()
            task2.waitUntilExit()
            
            func dialogOK(question: String, text: String) -> Bool {
                let alert = NSAlert()
                alert.messageText = question
                alert.informativeText = text
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                return alert.runModal() == .alertFirstButtonReturn
            }
            
            let answer = dialogOK(question: "You must install printer software to be able to use this printer", text: "\n1. Click \"Continue\" 3 times\n2. Click \"Agree\"\n3. Click \"Install\"\n4. Type your password and click \"Install Software\"")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Did load")
        // Do any additional setup after loading the view.
        let pipe = Pipe()
        
        let echo = Process()
        echo.launchPath = "/usr/bin/env"
        echo.arguments = ["lpstat", "-p"]
        echo.standardOutput = pipe
        
        let uniq = Process()
        uniq.launchPath = "/usr/bin/env"
        uniq.arguments = ["awk", "{print $2}"]
        uniq.standardInput = pipe
        
        let out = Pipe()
        uniq.standardOutput = out
        
        echo.launch()
        uniq.launch()
        uniq.waitUntilExit()
        
        let data = out.fileHandleForReading.readDataToEndOfFile()
        let output : String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        var printersOutput = output.split{$0 == "\n"}.map(String.init)
        
        var matched : Bool = false;
        for printers in printerlists
        {
            for print in printersOutput
            {
                if printers.contains(print) //&& i < printersOutput.count
                {
                    menuItem.addItem(withTitle: printers + " (Tilføjet)");
                    matched = true;
                    break
                }
            }
            
            if matched
            {
                matched = false;
            }
            else {
                menuItem.addItem(withTitle: printers);
            }
        }
    }
}

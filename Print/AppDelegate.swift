import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // Check if file exists, given its path
        // ppd file taken from /etc/cups/ppd
        
        print("Downloading ppd file")
        let task:Process = Process()
        let pipe:Pipe = Pipe()
        task.launchPath = "/usr/bin/curl"
        task.arguments = ["-o", "/Users/Shared/PPD.zip", "https://xxxxx/PPD.zip"]
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        print("unzipping")
        
        task.launchPath = "/usr/bin/unzip"
        task.arguments = ["-o", "/Users/Shared/PPD.zip", "-d", "/Users/Shared/",]
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

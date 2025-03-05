import Cocoa
import SwiftUI

var checkInWindow: NSWindow!
var recordsWindow: NSWindow!

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var notesWindow: NSWindow!
    var scheduleWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "习惯助手")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "打开记事本", action: #selector(openNotes), keyEquivalent: "N"))
           
            menu.addItem(NSMenuItem(title: "今日打卡", action: #selector(checkIn), keyEquivalent: "D"))
            menu.addItem(NSMenuItem(title: "查看打卡记录", action: #selector(viewRecords), keyEquivalent: "R"))
            menu.addItem(NSMenuItem(title: "提醒日程", action: #selector(addSchedule), keyEquivalent: "A"))
            
            menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "Q"));
        
        statusItem.menu = menu
    }
    
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }

    @objc func openNotes() {
        if notesWindow == nil {
            let hostingController = NSHostingController(rootView: NotesView())
            notesWindow = NSWindow(
                contentViewController: hostingController
            )
            notesWindow.setContentSize(NSSize(width: 420, height: 380))
            notesWindow.title = "记事本"
            notesWindow.makeKeyAndOrderFront(nil)
        } else {
            notesWindow.makeKeyAndOrderFront(nil)
        }
    }
   
    @objc func checkIn() {
        if checkInWindow == nil {
            let hostingController = NSHostingController(rootView: CheckInView())
            checkInWindow = NSWindow(
                contentViewController: hostingController
            )
            checkInWindow?.styleMask.insert(.resizable)
            checkInWindow?.setContentSize(NSSize(width: 420, height: 500))
            checkInWindow?.maxSize = NSSize(width: 800, height: 1000)  // ✅ 最大大小
            checkInWindow?.minSize = NSSize(width: 400, height: 400)  // ✅ 最小大小（可选）
            checkInWindow?.title = "今日打卡"
            checkInWindow?.makeKeyAndOrderFront(nil)
        } else {
            checkInWindow.makeKeyAndOrderFront(nil)
        }
    }

    @objc func viewRecords() {
        if recordsWindow == nil {
            let hostingController = NSHostingController(rootView: RecordsView())  // 使用 RecordsView 作为窗口内容
            recordsWindow = NSWindow(
                contentViewController: hostingController
            )
            recordsWindow.setContentSize(NSSize(width: 420, height: 600))
            recordsWindow.title = "打卡记录"
            recordsWindow.makeKeyAndOrderFront(nil)
        } else {
            recordsWindow.makeKeyAndOrderFront(nil)
        }
    }

    @objc func addSchedule() {
        if scheduleWindow == nil {
            let hostingController = NSHostingController(rootView: ScheduleView())
            scheduleWindow = NSWindow(
                contentViewController: hostingController
            )
            scheduleWindow?.setContentSize(NSSize(width: 420, height: 500))
            scheduleWindow?.title = "提醒日程"
            scheduleWindow?.makeKeyAndOrderFront(nil)
        } else {
            scheduleWindow?.makeKeyAndOrderFront(nil)
        }
    }
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}

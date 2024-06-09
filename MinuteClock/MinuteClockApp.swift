//
//  MinuteClock.swift
//  MinuteClock
//
//  Show the time as minutes elapsed since (or remaining until) midnight.
//  Alternatively, show seconds or metric time.
//
//  Copyright 2024, Michael A. Olson.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of
//     conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of
//     conditions and the following disclaimer in the documentation and/or other materials
//     provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its contributors may be
//     used to endorse or promote products derived from this software without specific prior
//     written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
//  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
//  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
//  TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import SwiftUI

extension Date
{
    var timeIntervalSinceMidnight: TimeInterval?{
        return self.timeIntervalSince(self.midnight)
    }
    
    // local time at midnight today
    var midnight: Date {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal.startOfDay(for: self)
    }
}

class MinuteClock: ObservableObject {
    // we want to update our clock every quarter second
    // fast enough to keep the display right, infrequent enough to avoid wasting CPU time
    private var mc_timer = Timer()
    
    // what time is it?
    private var mc_now = Date()

    // settable in the iOS Settings app
    var mc_idletimerdisabled = false    // keep the display active for use as a desk clock
    var mc_countdown = false            // count down instead of up
    var mc_colorchoice = 0              // let the user select the text color
    var mc_color = [ Color.black, Color.red, Color.yellow, Color.green, Color.blue ] // available color choices
    
    @Published var mc_minutes_display = ""
    @Published var mc_metric_display = ""
    @Published var mc_seconds_display = ""
    
    private func updateTimes() -> Void {
        let elapsedSecs = Date().timeIntervalSinceMidnight!
        var seconds:Int
        var minutes:Int
        var metric:Int

        // Assume we're counting up, get minutes/seconds/metric ticks elapsed
        minutes = Int(floor(elapsedSecs / 60.0))    // 60 seconds in a ninute
        metric = Int(floor(elapsedSecs / 8.64))     // 8.64 secs in one hundred microdays
        seconds = Int(floor(elapsedSecs))           // 86400 seconds in a day

        // If we're counting down, adjust all the times
        if (self.mc_countdown) {
            minutes = 1440 - minutes    // 1440 minutes in a day
            metric = 10000 - metric      // 10000 hundred microdays in a day
            seconds = 86400 - seconds   // 86400 seconds in a day
        }

        let f = NumberFormatter()
        mc_minutes_display = f.string(from: minutes as NSNumber)!
        mc_metric_display = f.string(from: metric as NSNumber)!
        mc_seconds_display = f.string(from: seconds as NSNumber)!
    }
    
    func start() {
        // get settings from the user defaults
        self.initDefaults()
        self.loadDefaults()
        
        // look at the clock
        self.updateTimes()
        
        // A quarter second is fast enough to keep all the displays current
        let updateInterval = 0.250
        mc_timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            // when the timer goes off, call our updateTimes routine to figure out if anything has changed
            self.updateTimes() }
    }
    
    init() {
        start()
    }
    
    // is this necessary?
    deinit {
        // turn off the timer when the app shuts down
        mc_timer.invalidate()
    }
    
    private func initDefaults() {
        // First time we run on a device, need to register the defaults set in the Setting bundle with
        // the UserDefaults database. It's kind of bogus that iOS doesn't do this for you automatically.
        // Thanks, StackOverflow!
        let settingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
        let settingsPlist = NSDictionary(contentsOf:settingsUrl)!
        let preferences = settingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        
        var defaultsToRegister = Dictionary<String, Any>()
        
        for preference in preferences {
            guard let key = preference["Key"] as? String else {
                NSLog("Key not found")
                continue
            }
            defaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: defaultsToRegister)
    }
    
    func loadDefaults() {
        let defaults = UserDefaults.standard
        self.mc_idletimerdisabled = defaults.bool(forKey: "mc_idletimerdisabled")
        self.mc_countdown = defaults.bool(forKey: "mc_countdown")
        self.mc_colorchoice = defaults.integer(forKey: "mc_colorchoice")
    }
}

@main
struct MinuteClockApp: App {
    // we make this a state object so it's visible in the views
    @StateObject private var mc = MinuteClock()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mc)
        }
    }
}

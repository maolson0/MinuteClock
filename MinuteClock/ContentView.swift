//
//  ContentView.swift
//  MinuteClock
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

// constants for display
let fontSize: CGFloat = 110    // works on an iPhone SE without wrapping in any View
let hPadding: CGFloat = 20
let vPadding: CGFloat = 50


// We use this notification to reload user defaults from system settings when iOS notifies us that
// they have changed. Those defaults control whether or not we highlight primes, whether we use a 12-
// or a 24-hour clock, the layout of the time converter in landscape mode (keypad on left or on
// right), and whether we should keep the display active (in case the user is using MultiClock as a desk
// clock).
extension NSNotification {
    static let uDefaults = Notification.Name.init("NSUserDefaultsDidChangeNotification")
}

struct ContentView: View {
    @EnvironmentObject var mc: MinuteClock

    // XXX add tab view, use the three different displayable properties, find images for the tabs
    var body: some View {
        TabView() {
            MinView()
                .tabItem {
                    Label("minutes", systemImage: "m.circle")
                        .foregroundColor(.gray)
                    Text("Minutes")
                }.tag(0)
            SecView()
                .tabItem {
                    Label("seconds", systemImage: "s.circle")
                        .foregroundColor(.gray)
                    Text("Seconds)")
                }.tag(1)
            MetricView()
                .tabItem {
                    Label("metric", systemImage: "ruler")
                        .foregroundColor(.gray)
                    Text("Metric")
                }.tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.uDefaults, object: nil, queue: nil) { _ in
                // if the user changes defaults in the systems settings, reload the state variables in the clock
                mc.loadDefaults()
            }
        }
    }
}

struct MinView: View {
    @EnvironmentObject var mc: MinuteClock
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            Text(mc.mc_minutes_display)
                .font(.system(size: fontSize))
            HStack {
                if (mc.mc_minutes_display == "1") {
                    Text("minute")
                } else {
                    Text("minutes")
                }
                if (mc.mc_countdown) {
                    Text("until")
                } else {
                    Text("since")
                }
                Text("midnight")
            }
        }
        .foregroundColor(mc.mc_colorchoice != 0 ?
                         mc.mc_color[mc.mc_colorchoice] : (colorScheme == .dark ? .white : .black))
        .padding(.vertical, vPadding)
        .padding(.horizontal, hPadding)
    }
}

struct SecView: View {
    @EnvironmentObject var mc: MinuteClock
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            Text(mc.mc_seconds_display)
                .font(.system(size: fontSize))
            HStack {
                if (mc.mc_seconds_display == "1") {
                    Text("second")
                } else {
                    Text("seconds")
                }
                if (mc.mc_countdown) {
                    Text("until")
                } else {
                    Text("since")
                }
                Text("midnight")
            }
        }
        .foregroundColor(mc.mc_colorchoice != 0 ?
                         mc.mc_color[mc.mc_colorchoice] : (colorScheme == .dark ? .white : .black))
        .padding(.vertical, vPadding)
        .padding(.horizontal, hPadding)
    }
}

struct MetricView: View {
    @EnvironmentObject var mc: MinuteClock
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            Text(mc.mc_metric_display)
                .font(.system(size: fontSize))
            HStack {
                Text("hundred microdays")
                if (mc.mc_countdown) {
                    Text("until")
                } else {
                    Text("since")
                }
                Text("midnight")
            }
        }
        .foregroundColor(mc.mc_colorchoice != 0 ?
                         mc.mc_color[mc.mc_colorchoice] : (colorScheme == .dark ? .white : .black))
        .padding(.vertical, vPadding)
        .padding(.horizontal, hPadding)
    }
}


#Preview {
    ContentView()
}

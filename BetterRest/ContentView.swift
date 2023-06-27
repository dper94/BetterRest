//
//  ContentView.swift
//  BetterRest
//
//  Created by Diego Perdomo on 26/6/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text(calculateBedTime())
                } header: {
                    Text("Your ideal bedtime is:")
                        .font(.headline)
                }
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                        .font(.headline)
                }
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                        .font(.headline)
                }

                Section {
                    Picker("Number of cups", selection: $coffeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text($0, format: .number)
                        }
                    }
                } header: {
                    Text("Daily coffe intake")
                        .font(.headline)
                }
            }
            .navigationTitle("BetterRest")
        }
    }

    func calculateBedTime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))

            let sleepTime = wakeUp - prediction.actualSleep
            let idealBedTime = sleepTime.formatted(date: .omitted, time: .shortened)
            return idealBedTime
        } catch {
            return "Sorry, there was a problem calculating your ideal bedtime."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

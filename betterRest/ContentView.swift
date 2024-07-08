//
//  ContentView.swift
//  BetterRest
//
//  Created by Paul Hudson on 15/10/2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    @State private var recommendedBedtime: Date = Date()
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)

                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)

                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)

                    Picker("Coffee amount: ", selection: $coffeeAmount) {
                        ForEach(1..<6) { cups in
                            Text("^[\(cups) cup](inflect: true)")
                        }
                    }
                    Text("Your recommended bedtime is: \(recommendedBedtime.formatted(date: .omitted, time: .shortened))")               .font(.title)
                            .padding()
                            .background()
                }
                
            }
            .navigationTitle("BetterRest")
                .onChange(of: wakeUp, perform: { _ in
                    calculateBedtime()
                })
                .onChange(of: sleepAmount, perform: { _ in
                    calculateBedtime()
                })
                .onChange(of: coffeeAmount, perform: { _ in
                    calculateBedtime()
                })
            }
        }
    

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep
            recommendedBedtime = sleepTime
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
            
        showingAlert = true
    }

}
#Preview {
    ContentView()
}

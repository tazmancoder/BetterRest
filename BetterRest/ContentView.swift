//
//  ContentView.swift
//  BetterRest
//
//  Created by Mark Perryman on 5/18/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 2
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Wake Up") {
                    Text("When do you want to wake up?")
                        .font(.headline)

                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onTapGesture {
                            calculateBedtime()
                        }
                }

                Section("Sleep Amount") {
                    Text("Desired amount of sleep")
                        .font(.headline)

                    Stepper {
                        Text("\(sleepAmount.formatted()) hours")
                    } onIncrement: {
                        sleepAmount += 0.25
                        if sleepAmount > 12 { sleepAmount = 12 }
                        calculateBedtime()
                    } onDecrement: {
                        sleepAmount -= 0.25
                        if sleepAmount < 4 { sleepAmount = 4 }
                        calculateBedtime()
                    }
                }

                Section("Coffee") {
                    Text("Daily coffee intake")
                        .font(.headline)

                    Stepper {
                        Text(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups")
                    } onIncrement: {
                        coffeeAmount += 1
                        if coffeeAmount > 20 { coffeeAmount = 20 }
                        calculateBedtime()
                    } onDecrement: {
                        coffeeAmount -= 1
                        if coffeeAmount < 1 { coffeeAmount = 1 }
                        calculateBedtime()
                    }
                }

                VStack(alignment: .center) {
                    Text(alertTitle)
                    Text(alertMessage)
                        .font(.largeTitle)
                }
            }
            .navigationTitle("BetterRest")
        }
        .onAppear {
            calculateBedtime()
        }
    }

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let cal = Calendar.current
            let components = cal.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep

            alertTitle = "You ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "There was a problem calculating your bedtime"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

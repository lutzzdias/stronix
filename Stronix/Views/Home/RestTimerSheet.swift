//
  //  RestTimerSheet.swift
  //  Stronix
  //

  import SwiftUI

  struct RestTimerSheet: View {
      @Environment(RestTimer.self) var restTimer
      @Environment(\.dismiss) var dismiss

      var body: some View {
          let _ = restTimer.tick
          NavigationStack {
              Group {
                  if restTimer.isRunning {
                      runningView
                  } else {
                      presetsView
                  }
              }
              .navigationTitle("Rest Timer")
              .navigationBarTitleDisplayMode(.inline)
              .toolbar {
                  ToolbarItem(placement: .cancellationAction) {
                      Button("Close") { dismiss() }
                  }
              }
          }
      }

      private var runningView: some View {
          VStack(spacing: 32) {
              Spacer()

              Text(AppFormatter.restTimer(restTimer.remainingTime))
                  .font(.system(size: 56, weight: .light).monospacedDigit())
                  .foregroundStyle(restTimer.remainingTime < 0 ? .red : .primary)

              if let duration = restTimer.duration {
                  Text("of \(AppFormatter.restTimer(duration))")
                      .foregroundStyle(.secondary)
              }

              HStack(spacing: 24) {
                  Button("-10s") { restTimer.adjustDuration(by: -10) }
                      .buttonStyle(.bordered)
                  Button("+10s") { restTimer.adjustDuration(by: 10) }
                      .buttonStyle(.bordered)
                  Button("Cancel") { restTimer.stop() }
                      .buttonStyle(.borderedProminent)
                      .tint(.red)
              }

              Spacer()
          }
      }

      private var presetsView: some View {
          List {
              ForEach(RestTimer.presets, id: \.self) { duration in
                  Button(AppFormatter.restTimer(duration)) {
                      restTimer.begin(duration: duration)
                  }
              }
          }
      }
  }

//
//  ContentView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 19/04/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Four ways to time.")
                            .font(.title2.weight(.semibold))
                        Text("Everyday clocks and two dedicated game modes.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel("CLOCKS")
                        HStack(spacing: 16) {
                            NavigationLink {
                                StopwatchView()
                                    .navigationTitle("Stopwatch")
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                FeatureCard(
                                    title: "Stopwatch",
                                    subtitle: "Count up",
                                    systemImage: "stopwatch.fill",
                                    gradient: LinearGradient(
                                        colors: [Palette.stopwatch, Palette.stopwatch.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                            NavigationLink {
                                TimerView()
                                    .navigationTitle("Timer")
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                FeatureCard(
                                    title: "Timer",
                                    subtitle: "Count down",
                                    systemImage: "timer",
                                    gradient: LinearGradient(
                                        colors: [Palette.timer, Palette.timer.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                        }
                        .buttonStyle(CardButtonStyle())
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel("GAMES")
                        HStack(spacing: 16) {
                            NavigationLink {
                                RubiksView()
                            } label: {
                                FeatureCard(
                                    title: "Rubik's",
                                    subtitle: "Palm sensor",
                                    systemImage: "cube.fill",
                                    gradient: LinearGradient(
                                        colors: [Palette.rubiks, Palette.rubiks.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                            NavigationLink {
                                ChessView()
                            } label: {
                                FeatureCard(
                                    title: "Chess",
                                    subtitle: "Two-player clock",
                                    systemImage: "crown.fill",
                                    gradient: LinearGradient(
                                        colors: [Palette.chess, Palette.chess.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("GameClock")
        }
    }
}

private struct SectionLabel: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .tracking(1.2)
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
    }
}

private struct FeatureCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: systemImage)
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
            Spacer(minLength: 24)
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
    }
}

private struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  FitTrack Pro
//
//  Created by Principal iOS Developer on 9/14/26.
//

import SwiftUI

// MARK: - Models

struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let type: ExerciseType
    let color: Color
}

enum ExerciseType {
    case strength
    case cardio
}

struct WorkoutLog: Identifiable {
    let id = UUID()
    let exercise: Exercise
    let timestamp: Date
    let weight: Int?
    let reps: Int?
    let duration: Int?
    
    var displayText: String {
        if let weight = weight, let reps = reps {
            return "\(weight) lbs × \(reps) reps"
        } else if let duration = duration {
            return "\(duration) min"
        }
        return ""
    }
}

// MARK: - View Model

@Observable
class WorkoutViewModel {
    var workoutLogs: [WorkoutLog] = []
    var selectedExercise: Exercise?
    
    // Exercise input states
    var benchPressWeight: Int = 135
    var benchPressReps: Int = 10
    
    var squatWeight: Int = 185
    var squatReps: Int = 8
    
    var treadmillDuration: Int = 20
    
    // Animation states
    var showLogAnimation: Bool = false
    var justLoggedExercise: Exercise?
    
    var dailyStreak: Int = 5
    
    var todayWorkoutCount: Int {
        workoutLogs.filter { Calendar.current.isDateInToday($0.timestamp) }.count
    }
    
    var progressPercentage: Double {
        let target = 6.0
        return min(Double(todayWorkoutCount) / target, 1.0)
    }
    
    let exercises: [Exercise] = [
        Exercise(name: "Bench Press", icon: "figure.strengthtraining.traditional", type: .strength, color: .blue),
        Exercise(name: "Squats", icon: "figure.strengthtraining.functional", type: .strength, color: .purple),
        Exercise(name: "Treadmill Run", icon: "figure.run", type: .cardio, color: .orange)
    ]
    
    func logWorkout(exercise: Exercise, weight: Int? = nil, reps: Int? = nil, duration: Int? = nil) {
        let log = WorkoutLog(
            exercise: exercise,
            timestamp: Date(),
            weight: weight,
            reps: reps,
            duration: duration
        )
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            workoutLogs.insert(log, at: 0)
            justLoggedExercise = exercise
            showLogAnimation = true
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Reset animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                self.showLogAnimation = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                self.justLoggedExercise = nil
            }
        }
    }
}

// MARK: - Main View

struct ContentView: View {
    @State private var viewModel = WorkoutViewModel()
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Progress Card
                    dailyProgressCard
                    
                    // Quick Workout Tracker
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Log")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            benchPressCard
                            squatCard
                            treadmillCard
                        }
                        .padding(.horizontal)
                    }
                    
                    // Activity Feed
                    if !viewModel.workoutLogs.isEmpty {
                        activityFeed
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("FitTrack Pro")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Daily Progress Card
    
    private var dailyProgressCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("🔥")
                            .font(.title2)
                        Text("\(viewModel.dailyStreak) Day Streak")
                            .font(.title3.bold())
                    }
                    
                    Text("\(viewModel.todayWorkoutCount) workouts logged today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.progressPercentage)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progressPercentage)
                    
                    Text("\(Int(viewModel.progressPercentage * 100))%")
                        .font(.system(.headline, design: .rounded))
                        .bold()
                }
            }
            
            // Progress bar alternative
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Daily Goal")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(viewModel.todayWorkoutCount)/6")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * viewModel.progressPercentage,
                                height: 12
                            )
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progressPercentage)
                    }
                }
                .frame(height: 12)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    // MARK: - Exercise Cards
    
    private var benchPressCard: some View {
        let exercise = viewModel.exercises[0]
        return ExerciseCard(
            exercise: exercise,
            isJustLogged: viewModel.justLoggedExercise == exercise
        ) {
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight (lbs)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Button {
                                if viewModel.benchPressWeight > 45 {
                                    withAnimation(.snappy) {
                                        viewModel.benchPressWeight -= 5
                                    }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(exercise.color)
                            }
                            
                            Text("\(viewModel.benchPressWeight)")
                                .font(.title3.bold())
                                .frame(width: 60)
                                .contentTransition(.numericText())
                            
                            Button {
                                withAnimation(.snappy) {
                                    viewModel.benchPressWeight += 5
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(exercise.color)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Button {
                                if viewModel.benchPressReps > 1 {
                                    withAnimation(.snappy) {
                                        viewModel.benchPressReps -= 1
                                    }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(exercise.color)
                            }
                            
                            Text("\(viewModel.benchPressReps)")
                                .font(.title3.bold())
                                .frame(width: 60)
                                .contentTransition(.numericText())
                            
                            Button {
                                withAnimation(.snappy) {
                                    viewModel.benchPressReps += 1
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(exercise.color)
                            }
                        }
                    }
                }
                
                Button {
                    viewModel.logWorkout(
                        exercise: exercise,
                        weight: viewModel.benchPressWeight,
                        reps: viewModel.benchPressReps
                    )
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Log Exercise")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(exercise.color)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(SpringButtonStyle())
            }
        }
    }
    
    private var squatCard: some View {
        let exercise = viewModel.exercises[1]
        return ExerciseCard(
            exercise: exercise,
            isJustLogged: viewModel.justLoggedExercise == exercise
        ) {
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight (lbs)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Button {
                                if viewModel.squatWeight > 45 {
                                    withAnimation(.snappy) {
                                        viewModel.squatWeight -= 5
                                    }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(exercise.color)
                            }
                            
                            Text("\(viewModel.squatWeight)")
                                .font(.title3.bold())
                                .frame(width: 60)
                                .contentTransition(.numericText())
                            
                            Button {
                                withAnimation(.snappy) {
                                    viewModel.squatWeight += 5
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(exercise.color)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Button {
                                if viewModel.squatReps > 1 {
                                    withAnimation(.snappy) {
                                        viewModel.squatReps -= 1
                                    }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(exercise.color)
                            }
                            
                            Text("\(viewModel.squatReps)")
                                .font(.title3.bold())
                                .frame(width: 60)
                                .contentTransition(.numericText())
                            
                            Button {
                                withAnimation(.snappy) {
                                    viewModel.squatReps += 1
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(exercise.color)
                            }
                        }
                    }
                }
                
                Button {
                    viewModel.logWorkout(
                        exercise: exercise,
                        weight: viewModel.squatWeight,
                        reps: viewModel.squatReps
                    )
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Log Exercise")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(exercise.color)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(SpringButtonStyle())
            }
        }
    }
    
    private var treadmillCard: some View {
        let exercise = viewModel.exercises[2]
        return ExerciseCard(
            exercise: exercise,
            isJustLogged: viewModel.justLoggedExercise == exercise
        ) {
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration (minutes)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Button {
                            if viewModel.treadmillDuration > 5 {
                                withAnimation(.snappy) {
                                    viewModel.treadmillDuration -= 5
                                }
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(exercise.color)
                        }
                        
                        Spacer()
                        
                        Text("\(viewModel.treadmillDuration)")
                            .font(.system(.largeTitle, design: .rounded).bold())
                            .contentTransition(.numericText())
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.snappy) {
                                viewModel.treadmillDuration += 5
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(exercise.color)
                        }
                    }
                }
                
                Button {
                    viewModel.logWorkout(
                        exercise: exercise,
                        duration: viewModel.treadmillDuration
                    )
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Log Exercise")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(exercise.color)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(SpringButtonStyle())
            }
        }
    }
    
    // MARK: - Activity Feed
    
    private var activityFeed: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.title2.bold())
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(viewModel.workoutLogs) { log in
                    ActivityRow(log: log)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}

// MARK: - Supporting Views

struct ExerciseCard<Content: View>: View {
    let exercise: Exercise
    let isJustLogged: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(exercise.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: exercise.icon)
                        .font(.title3)
                        .foregroundStyle(exercise.color)
                }
                
                Text(exercise.name)
                    .font(.headline)
                
                Spacer()
                
                if isJustLogged {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Logged!")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isJustLogged ? exercise.color : Color.gray.opacity(0.2), lineWidth: isJustLogged ? 2 : 1)
                .animation(.spring(response: 0.3), value: isJustLogged)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(isJustLogged ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isJustLogged)
    }
}

struct ActivityRow: View {
    let log: WorkoutLog
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(log.exercise.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: log.exercise.icon)
                    .font(.body)
                    .foregroundStyle(log.exercise.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(log.exercise.name)
                    .font(.subheadline.bold())
                
                Text(log.displayText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(log.timestamp, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Button Styles

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}

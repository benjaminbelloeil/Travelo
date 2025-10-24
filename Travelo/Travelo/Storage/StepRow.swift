//
//  StepRow.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 10/22/25.
//

import SwiftUI

struct StepRow: View {
    let item: StepItem
    let isDone: Bool
    let onToggle: () -> Void
    let index: Int
    let isLastItem: Bool
    let canToggle: Bool
    let isActive: Bool
    let showStepNumber: Bool
    
    @State private var showDisabledFeedback = false
    
    init(item: StepItem, isDone: Bool, onToggle: @escaping () -> Void, index: Int, isLastItem: Bool, canToggle: Bool, isActive: Bool, showStepNumber: Bool = false) {
        self.item = item
        self.isDone = isDone
        self.onToggle = onToggle
        self.index = index
        self.isLastItem = isLastItem
        self.canToggle = canToggle
        self.isActive = isActive
        self.showStepNumber = showStepNumber
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                // Step Number (back to left, smaller)
                VStack {
                    Text("\(item.stepNumber)")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 32) // Reduced from original 44 to 32
                
                // Timeline indicator (back to left, closer to number)
                ZStack(alignment: .top) {
                    // Vertical line that extends through the entire height
                    if !isLastItem {
                        Rectangle()
                            .fill(isDone ? Color("Primary") : Color.gray.opacity(0.2))
                            .frame(width: 3, height: 100)
                            .offset(y: 26)
                            .animation(.easeInOut(duration: 0.4), value: isDone)
                    }
                    
                    // Circle on top
                    Group {
                        if isDone {
                            // Completed: solid Primary fill
                            Circle()
                                .fill(Color("Primary"))
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 32, height: 32)
                                )
                        } else if isActive {
                            // Active (not completed): outlined ring
                            Circle()
                                .fill(Color.white)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Circle()
                                        .stroke(Color("Primary"), lineWidth: 3)
                                )
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 32, height: 32)
                                )
                        } else {
                            // Pending: gray fill
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 32, height: 32)
                                )
                        }
                    }
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isActive)
                }
                .frame(width: 28)
                
                // Content (more space for titles, aligned with step numbers)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        if showStepNumber {
                            Text("Step \(item.stepNumber)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("Primary"))
                        }
                        Spacer()
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) { // Changed to firstTextBaseline alignment with smaller spacing
                        Text(item.title)
                            .font(.system(size: 16, weight: .bold)) // Reduced from 18 to 16
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        // Info icon to indicate clickable for more details - positioned right after title
                        Image(systemName: "info.circle")
                            .font(.system(size: 14, weight: .medium)) // Made proportionally smaller
                            .foregroundColor(Color("Primary").opacity(0.7))
                        
                        Spacer()
                    }
                    
                    Text(item.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 4)
                
                // Interactive status button (back to right side)
                Button(action: handleToggle) {
                    Image(systemName: isDone ? "checkmark" : "xmark")
                        .font(.system(size: 18, weight: .thin))
                        .foregroundColor(isDone ? .green : (canToggle ? .gray : .gray.opacity(0.4)))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(isDone ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                        .overlay(
                            showDisabledFeedback && !canToggle ?
                            Text("Complete previous step first")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(6)
                                .shadow(radius: 2)
                                .offset(x: -100, y: 0)
                                .transition(.opacity)
                            : nil
                        )
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDone)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!canToggle && !isDone)
            }
            .frame(height: 100)
        }
    }
    
    private func handleToggle() {
        // Check if can toggle
        if !canToggle && !isDone {
            withAnimation(.easeInOut(duration: 0.2)) {
                showDisabledFeedback = true
            }
            
            // Haptic feedback for error
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDisabledFeedback = false
                }
            }
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            onToggle()
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

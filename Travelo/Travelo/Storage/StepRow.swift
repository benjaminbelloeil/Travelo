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
    
    @State private var showDisabledFeedback = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // Date
                VStack {
                    Text(item.formattedDate)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 60)
                
                // Timeline indicator
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
                .frame(width: 32)
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(item.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 8)
                
                // Interactive status button
                Button(action: handleToggle) {
                    Image(systemName: isDone ? "checkmark" : "xmark")
                        .font(.system(size: 20, weight: .thin))
                        .foregroundColor(isDone ? .green : (canToggle ? .gray : .gray.opacity(0.4)))
                        .frame(width: 40, height: 40)
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

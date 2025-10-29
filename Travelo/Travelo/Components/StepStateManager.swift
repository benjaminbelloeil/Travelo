//
//  StepStateManager.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 23/10/25.
//

import Foundation
import Combine

/// Shared state manager for synchronizing step completion between Home and Guide views
final class StepStateManager: ObservableObject {
    @Published private(set) var checkStore: CheckStateStore
    @Published private(set) var currentCountry: String = "IT"
    
    private var cancellables = Set<AnyCancellable>()
    
    init(countryCode: String = "IT", templateVersion: Int = 1) {
        self.currentCountry = countryCode
        self.checkStore = CheckStateStore(countryCode: countryCode, templateVersion: templateVersion)
        
        // Listen to changes from the check store
        checkStore.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func updateCountry(_ countryCode: String, templateVersion: Int = 1) {
        if currentCountry != countryCode {
            currentCountry = countryCode
            checkStore.updateCountry(countryCode, templateVersion: templateVersion)
            objectWillChange.send()
        }
    }
    
    // MARK: - Step Management
    func isDone(_ stepId: String) -> Bool {
        checkStore.isDone(stepId)
    }
    
    func setDone(_ done: Bool, stepId: String) {
        checkStore.setDone(done, id: stepId)
    }
    
    func toggle(_ stepId: String) {
        checkStore.toggle(stepId)
    }
    
    // MARK: - Home View Specific Logic
    func getVisibleStepsForHome(allSteps: [StepItem]) -> [StepItem] {
        let sortedSteps = allSteps.sorted { $0.order < $1.order }
        
        // Find the first incomplete step
        var firstIncompleteIndex = sortedSteps.count // Default to showing all if all complete
        
        for (index, step) in sortedSteps.enumerated() {
            if !isDone(step.id) {
                firstIncompleteIndex = index
                break
            }
        }
        
        // Show first 3 steps if we're in the beginning, otherwise show the current group
        if firstIncompleteIndex < 3 {
            return Array(sortedSteps.prefix(3))
        } else {
            // Show current group of 3 starting from the first incomplete step
            let startIndex = (firstIncompleteIndex / 3) * 3
            let endIndex = min(startIndex + 3, sortedSteps.count)
            return Array(sortedSteps[startIndex..<endIndex])
        }
    }
    
    func canToggleStep(_ step: StepItem, in allSteps: [StepItem]) -> Bool {
        let sortedSteps = allSteps.sorted { $0.order < $1.order }
        
        guard let currentIndex = sortedSteps.firstIndex(where: { $0.id == step.id }) else {
            return false
        }
        
        // First step can always be toggled
        if currentIndex == 0 {
            return true
        }
        
        // Can toggle if already done (to uncheck)
        if isDone(step.id) {
            return true
        }
        
        // Can toggle if previous step is completed
        return isDone(sortedSteps[currentIndex - 1].id)
    }
    
    func isStepActive(_ step: StepItem, in allSteps: [StepItem]) -> Bool {
        let sortedSteps = allSteps.sorted { $0.order < $1.order }
        
        guard let currentIndex = sortedSteps.firstIndex(where: { $0.id == step.id }) else {
            return false
        }
        
        // Step is active if it's not completed and can be toggled
        return !isDone(step.id) && canToggleStep(step, in: allSteps)
    }
}


//
//  didSet_willSetTests.swift
//  didSet willSetTests
//
//  Created by ynom on 11/21/24.
//

import Testing

struct didSet_willSetTests {
    
    @Test func notHowDidSetWorks() async throws {
        var numberOfCows = 42
        var changedBool = false
        var updatingNumberOfCows = numberOfCows {
            didSet {
                changedBool = true
            }
        }
        numberOfCows = 900
        
        #expect(numberOfCows == 900)
        #expect(changedBool != true)
    }
    
    @Test func didSetInitializedInAClass() async throws {
        class countingCows {
            var numberOfCows = 42 {
                didSet {
                    numberOfCows += 1
                }
            }
        }
        
        /// where does chocolate milk come from?
        var chocolateCows = countingCows()
        #expect(chocolateCows.numberOfCows == 42)
        
        chocolateCows.numberOfCows = 999
        /// this is where didSet was fired
        #expect(chocolateCows.numberOfCows != 43)
        #expect(chocolateCows.numberOfCows == 1000)
    }
    
    @Test func willSetInitializedInAClass() async throws {
        class countingCows {
            var numberOfCows = 42 {
                willSet {
                    numberOfChanges += 1
                }
            }
            var numberOfChanges = 0
        }
        
        /// where does chocolate milk come from?
        var chocolateCows = countingCows()
        #expect(chocolateCows.numberOfCows == 42)
        
        #expect(chocolateCows.numberOfChanges == 0)
        /// this is where willSet fires
        chocolateCows.numberOfCows = 999
        #expect(chocolateCows.numberOfChanges == 1)
    }
    
}

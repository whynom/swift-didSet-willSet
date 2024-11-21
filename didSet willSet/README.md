# `didSet`

It probably wasn't the first time I saw this function, but in the `GRBD demo` app, I saw this pice of code.

``` swift
    /// The player ordering
    var ordering = Ordering.byScore {
        didSet { observePlayers() }
    }
```
It seems that `didSet` just fires off that closure the `observePlayers` function is in, but what is it doing more than just having that function within the `Ordering.byScore` closure?

## My first attempt
Initially I tried the following

``` swift
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
        #expect(changedBool == true) // FAIL: FALSE
    }
```

This fails.  The `didSet` function can't just run in app's general scope, it needs to be brought up in a class so that it's being held in device's memory.

### I don't understand on device memory
I think when a `class` or a `struct` is initialized they are stored in the device's memory or in _the stack_ or both, or something like that.  When I run the above test the code is just executed, but there's no way for a function like `didSet` to remain running and observing for a change in the `numberOfCows` variable.  It needs to be within a `class` (maybe it can also work in a `struct`?) so that that when that `class` is initialized and stored in the device's memory, it can remain "running".

Again, this is all very vague and not well understood by me, but this is what I'm thinking right now.  Anyway, on to trying to put it in a `class`

### I thought you had class!  I thought _you_ had class!@
This next test shows proper usage and where exactly `didSet` fires.

``` swift
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
```
 
`didSet` fires whenever the `numberOfCows` property on the `countingCows` _class_ changes.  As the test shows, it fires after the setting, so when we changed `numberOfCows` to 999, it fired the `didSet` code block to add 1 more cow and ending up with 1000 cows.

One wonders what should be done if we wish to execute a block of code _before_ a property is changed.

### `willSet`
This function does the same thing as `didSet` except it does it just _before_ a property is changed.  Making the following example does _not_ show it doing anything different from the `didSet` function because I couldn't think of one.  Maybe, some day, I'll run into a situation where I need a `willSet`, or maybe I'll stumble upon some code where it is needed but for now, bask in my ignorance!

``` swift
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
```

This is example can be a bit less confusing because `willSet` is not running a code block that changes itself, it changes the `numberOfChanges` variable instead.

## Back to that original code
I more or less kind of understood what the original code was doing but I have a better grasp about how `didSet` has to be a function on a property in a `class`.  Originally, I was kind of thinking why not just define a closure on the `byScore` property but that would only fire once and not on updates.  It'd probably add more complexity to the `byScore` property as well as making the calling of it more difficult to read.


``` swift
    /// The player ordering
    var ordering = Ordering.byScore {
        didSet { observePlayers() }
    }
```

## Some final notes
I realized that I was thinking of them and referring to them as functions, but it appears they are `observers`.

You can't have an observer on a lazy property which intuitively feels right because lazily stored properties don't exist when the `class` they are a part of is initialized, thus these observers would have nothing to observe.  It seems like a syntax thing to protect against programmer errors.

There's also _different_ kinds of `observers` for computed properties which are `get` and `set`which I've certainly seen, and to some point understood, like I did `didSet` and `willSet` but I should probably throw together another branch and essay to get a better full idea of using them.  I did not realize they were used only on computed variables.

package main

import (
	"fmt"
)

var globalVariable = "global variable"
var scopeTestVar = "global"
var scopeTestVar1 = "global1"
var scopeTestVar2 = "global2"

func main() {
	// // // // // Nested subprogram definitions // // // // //
	fmt.Println("-------------- Nested subprogram definitions --------------")

	// Go does not allow nested functions in the traditional sense
	//func sub() {				// ./prog.go:13:7: syntax error: unexpected sub1, expecting (
	//	fmt.Println("Invalid sub")	// It does not expect a name assigned the usual way to a func value
	//}
	//sub()

	// Instead, a function can be declared as a value in a function to be instantly called...
	func() { fmt.Println("Unreferenced function") }()
	sub1 := func() { fmt.Println("sub1") } // 			...or to be assigned o a variable
	sub1()

	// Using this trick, one can have deeply nested functions in go
	func() {
		func(parent string) {
			fmt.Printf("Nested function in a %s\n", parent)
		}("nested function")
	}()

	fmt.Println("----------------- Scope of local variables ----------------")

	fmt.Println("In main")
	fmt.Println(scopeTestVar)
	scopeTestVar := "main" // Declaring a new variable with same name as the global

	subB := func(callerScopeName string) {
		// static scoped by default
		if callerScopeName == scopeTestVar {
			fmt.Println("Dynamic scoping")
		} else {
			fmt.Println("Static scoping")
		}
		fmt.Println(scopeTestVar) // static scoped by default
	}

	subA := func() {
		fmt.Println("In subA")
		fmt.Println(scopeTestVar)  // Is affected by the name reassignment
		fmt.Println(scopeTestVar1) // Is affected by the value change
		fmt.Println(scopeTestVar2) // Is not affected by the name reassignment

		scopeTestVar := "subA" // Test Dynamic scoping
		subB(scopeTestVar)
	}

	scopeTestVar1 := "main1" // Declaring a new variable with same name as the global
	scopeTestVar2 = "main2"  // Changing value of the global variable

	fmt.Println(scopeTestVar1)
	fmt.Println(scopeTestVar2)
	subA()

	fmt.Println("---------------- Parameter passing methods ----------------")

	// Pass an int by reference
	passedByRef := 1
	doubleByRef(&passedByRef)
	fmt.Println(passedByRef)

	// Pass an int by value
	passedByValue := 10
	doubleByVal(passedByValue)
	fmt.Println(passedByValue)

	// Pass a struct by reference
	typeExample1 := exampleType{num: 1}
	doubleNumOfRef(&typeExample1)
	fmt.Println(typeExample1)

	// Pass a struct by value
	typeExample2 := exampleType{num: 10}
	doubleNumOfVal(typeExample2)
	fmt.Println(typeExample2)

	// Example code for questions 4 and 5 are moved below for easiear following
	kwAndDefParamTest()
	closureDemonstration()
}

func doubleByVal(goStruct int) {
	goStruct *= 2
}

func doubleByRef(goStruct *int) {
	*goStruct *= 2
}

type exampleType struct {
	num int
}

func doubleNumOfRef(goStruct *exampleType) {
	goStruct.num *= 2
}

func doubleNumOfVal(goStruct exampleType) {
	goStruct.num *= 2
}

func kwAndDefParamTest() {
	fmt.Println("------------- Keyword and default parameters --------------")
	//	var x int
	//	aFunc(x)
	// Keyword arguments implementation using a struct
	fmt.Println(coefficientAddition(additionArgs{firstTermCoefficient: 2, firstTerm: 3, secondTerm: 4}))
}

//func aFunc(x int) {
//	if reflect.ValueOf(x).IsNil() { and if x == nil { both result in errors
//		x = 5
//	}
//	fmt.Println(x)
//}

//func a(x int) {	// ./prog.go:108:6: a redeclared in this block
//
//	fmt.Println(x)
//}
//
//func a() {
//	a(5)
//}

// Define arguments in a struct
type additionArgs struct {
	firstTermCoefficient int
	firstTerm            int
	secondTerm           int
}
func coefficientAddition(args additionArgs) int {
	return (args.firstTermCoefficient*args.firstTerm + args.secondTerm)
}

func closureDemonstration() {
	fmt.Println("------------------------- Closures ------------------------")

	logger := getLogger(3)
	for i := 0; i < 15; i++ {
		logger("Hello"[i%5 : i%5+1])
	}
}

// My implementation of a logger using a closure
func getLogger(logSize int) func(string) {
	logCount := 0
	log := "Log:\n"
	return func(message string) {
		log += message + "\n"
		logCount++
		if logCount > logSize {
			fmt.Print(log)
			logCount = 0
			log = "Log:\n"
		}
	}

}

//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Rob Isenberg on 15/02/2015.
//  Copyright (c) 2015 Rob Isenberg. All rights reserved.
//

import Foundation

class CalculatorBrain {
  
  var variableValues = [String: Double]()
  
  var description: String {
    get {
      var remaining = opStack
      var descriptionString = ""
      
      while !remaining.isEmpty {
        let result: String?
        (result, remaining) = description(remaining)
        
        if let descriptionOfCurrentExpression = result {
          if descriptionString.isEmpty {
            descriptionString = "\(descriptionOfCurrentExpression)"
          }
          else {
            descriptionString = "\(descriptionOfCurrentExpression), \(descriptionString)"
          }
        }
      }
      
      return descriptionString
    }
  }
  
  typealias PropertyList = AnyObject
  var program: PropertyList {
    get {
      return opStack.map { $0.description }
    }
    set {
      if let opSymbols = newValue as? [String] {
        var newOpStack = [Op]()
        for opSymbol in opSymbols {
          if let op = knownOps[opSymbol] {
            newOpStack.append(op)
          } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
            newOpStack.append(.Operand(operand))
          } else {
            let variableSymbol = opSymbol
            newOpStack.append(.Variable(variableSymbol))
          }
        }
        
        opStack = newOpStack
      }
    }
  }
  
  
//  private enum BinaryOperatorPrecedence {
//    case High
//    case Low
//  }
  
  private enum Op: Printable {
    case Variable(String)
    case Operand(Double)
    case Constant(String, Double)
    case UnaryOperation(String, Double -> Double)
    case BinaryOperation(String, Int, (Double, Double) -> Double)
    
    var description: String {
      get {
        switch self {
          case .Variable(let symbol):
            return symbol
          case .Operand(let value):
            return "\(value)"
          case .Constant(let name, _):
            return name
          case .UnaryOperation(let symbol, _):
            return symbol
          case .BinaryOperation(let symbol, _, _):
            return symbol
        }
      }
    }
  }
  
  init() {
    func learnOp(op: Op) { knownOps[op.description] = op }
    
    learnOp(Op.BinaryOperation("+", 1, +))
    learnOp(Op.BinaryOperation("−", 1) { $1 - $0 })
    learnOp(Op.BinaryOperation("×", 2, *))
    learnOp(Op.BinaryOperation("÷", 2) { $1 / $0 })
    learnOp(Op.UnaryOperation("√", sqrt))
    learnOp(Op.UnaryOperation("sin", sin))
    learnOp(Op.UnaryOperation("cos", cos))
    learnOp(Op.Constant("π", M_PI))
  }
  
  
  func pushConstant(constantName: String) -> Double? {
    if let constant = knownOps[constantName] { opStack.append(constant) }
    return evaluate()
  }
  
  func pushOperand(symbol: String) -> Double? {
    opStack.append(Op.Variable(symbol))
    return evaluate()
  }
  
  func pushOperand(operand: Double) -> Double? {
    opStack.append(Op.Operand(operand))
    return evaluate()
  }
  
  func performOperation(symbol: String) -> Double? {
    if let operation = knownOps[symbol] {
      opStack.append(operation)
    }
    return evaluate()
  }

  func evaluate() -> Double? {
    let (result, remainder) = evaluate(opStack)
    return result
  }
  
  func clearOps() {
    opStack.removeAll()
  }
  
  func clearVars() {
    variableValues.removeAll()
  }
  
  func clearAll() {
    clearOps()
    clearVars()
  }
  
  private var opStack = [Op]()
  private var knownOps = [String:Op]()
  
  private func description(operands: [Op]) -> (result: String?, remainingOperands: [Op]) {
    if !operands.isEmpty {
      var remainingOperands = operands
      let lastOperand = remainingOperands.removeLast()
      
      switch(lastOperand) {
      case .Constant(let name, _):
        return (name, remainingOperands)
      case .Operand(let value):
        return ("\(value)", remainingOperands)
      case .Variable(let symbol):
        return (symbol, remainingOperands)
      case .UnaryOperation(let op, _):
        let (operand, operandRemainingOperands) = description(remainingOperands)
        if let operandDescription = operand {
          return("\(op)(\(operandDescription))", operandRemainingOperands)
        }
      case .BinaryOperation(let op, let opPrecedence, _):
        var (lastOperand, lastOperandsRemaingOps) = description(remainingOperands)
        var (firstOperand, firstOperandsRemainingOps) = description(lastOperandsRemaingOps)
        
        if firstOperand == nil { // missing operand
          (firstOperand, lastOperand) = (lastOperand, "?")
        }
        
        if precedenceLower(lastOperandsRemaingOps.last, thanPrecedence: opPrecedence) {
          firstOperand = "(\(firstOperand!))"
        }
        
        if precedenceLower(remainingOperands.last, thanPrecedence: opPrecedence) {
          lastOperand = "(\(lastOperand!))"
        }
        
        return("\(firstOperand!) \(op) \(lastOperand!)", firstOperandsRemainingOps)
      }
    }
    return (nil, operands)
  }
  
  private func precedenceLower(op: Op?, thanPrecedence: Int) -> Bool {
    if let unwrappedOp = op {
      switch(unwrappedOp) {
      case .BinaryOperation(_, let opPrecedence, _):
        return opPrecedence < thanPrecedence
      default:
        break
      }
    }
    
    return false
  }
  
  private func evaluate(operands: [Op]) -> (result: Double?, remainingOperands: [Op]) {
    if !operands.isEmpty {
      var remainingOperands = operands
      let firstOperand = remainingOperands.removeLast()

      switch(firstOperand) {
        case .Constant(_, let value):
          return (value, remainingOperands)
        case .Operand(let value):
          return (value, remainingOperands)
        case .Variable(let symbol):
          return (variableValues[symbol], remainingOperands)
        case .UnaryOperation(_, let operation):
          let operandEvaluation = evaluate(remainingOperands)
          if let operand = operandEvaluation.result {
            return (operation(operand), operandEvaluation.remainingOperands)
          }
        case .BinaryOperation(_, _, let operation):
          let op1Evaluation = evaluate(remainingOperands)
          if let operand1 = op1Evaluation.result {
            let op2Evaluation = evaluate(op1Evaluation.remainingOperands)
            if let operand2 = op2Evaluation.result {
              return (operation(operand1, operand2), op2Evaluation.remainingOperands)
            }
        }
      }
    }
    
    return (nil, operands)
  }
}
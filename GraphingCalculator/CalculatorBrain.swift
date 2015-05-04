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
      let (result, remaining) = description(opStack)
      if let descriptionString = result {
        return descriptionString
      }
      else {
        return ""
      }
    }
  }
  
  private enum Op: Printable {
    case Constant(String)
    case Operand(Double)
    case UnaryOperation(String, Double -> Double)
    case BinaryOperation(String, (Double, Double) -> Double)
    
    var description: String {
      get {
        switch self {
          case .Constant(let name):
            return name
          case .Operand(let value):
            return "\(value)"
          case .UnaryOperation(let symbol, _):
            return symbol
          case .BinaryOperation(let symbol, _):
            return symbol
        }
      }
    }
  }
  private var opStack = [Op]()
  private var knownOps = [String:Op]()
  
  init() {
    func learnOp(op: Op) { knownOps[op.description] = op }
    
    learnOp(Op.BinaryOperation("+", +))
    learnOp(Op.BinaryOperation("−") { $1 - $0 })
    learnOp(Op.BinaryOperation("×", *))
    learnOp(Op.BinaryOperation("÷") { $1 / $0 })
    learnOp(Op.UnaryOperation("√", sqrt))
    learnOp(Op.UnaryOperation("sin", sin))
    learnOp(Op.UnaryOperation("cos", cos))
  }
  
  
  func pushOperand(name: String) -> Double? {
    opStack.append(Op.Constant(name))
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
    println("\(opStack) = \(result) with \(remainder)")
    return result
  }
  
  func clear() {
    opStack.removeAll()
  }
  
  private func description(operands: [Op]) -> (result: String?, remainingOperands: [Op]) {
    if !operands.isEmpty {
      var remainingOperands = operands
      let firstOperand = remainingOperands.removeLast()
      
      switch(firstOperand) {
      case .Constant(let name):
        return (name, remainingOperands)
      case .Operand(let value):
        return ("\(value)", remainingOperands)
      case .UnaryOperation(let op, _):
        let (operand, operandRemainingOperands) = description(remainingOperands)
        if let operandDescription = operand {
          return("\(op)(\(operandDescription))", operandRemainingOperands)
        }
      case .BinaryOperation(let op, _):
        let (firstOperand, firstRemainingOperands) = description(remainingOperands)
        let (secondOperand, secondRemainingOperands) = description(firstRemainingOperands)
        
        if let firstOperandDescription = firstOperand {
          if let secondOperandDescription = secondOperand {
            return("\(firstOperandDescription) \(op) \(secondOperandDescription)", secondRemainingOperands)
          }
        }
      }
    }
    return ("", operands)
  }
  
  private func evaluate(operands: [Op]) -> (result: Double?, remainingOperands: [Op]) {
    if !operands.isEmpty {
      var remainingOperands = operands
      let firstOperand = remainingOperands.removeLast()

      switch(firstOperand) {
        case .Constant(let name):
          if let value = variableValues[name] {
            return (value, remainingOperands)
          }
        case .Operand(let value):
          return (value, remainingOperands)
        case .UnaryOperation(_, let operation):
          let operandEvaluation = evaluate(remainingOperands)
          if let operand = operandEvaluation.result {
            return (operation(operand), operandEvaluation.remainingOperands)
          }
        case .BinaryOperation(_, let operation):
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
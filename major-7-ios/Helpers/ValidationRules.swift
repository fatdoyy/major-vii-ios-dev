//
//  ValidationRule.swift
//  major-7-ios
//
//  Created by jason on 16/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Validator
import Localize_Swift

class M7ValidationRule {
    class func emailRules() -> ValidationRuleSet<String> {
        var rules = ValidationRuleSet<String>()
        
        let requiredRule = ValidationRuleRequired<String>(error: ValidationError(message: "empty"))
        let patternRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationError(message: "incorrect"))
        
        rules.add(rule: requiredRule)
        rules.add(rule: patternRule)
        
        return rules
    }
    
    class func pwRules() -> ValidationRuleSet<String> {
        var rules = ValidationRuleSet<String>()
        
        let requiredRule = ValidationRuleRequired<String>(error: ValidationError(message: "is empty"))
        let minLengthRule = ValidationRuleLength(min: 8, error: ValidationError(message: "must have minimum length of 8"))
    
        rules.add(rule: requiredRule)
        rules.add(rule: minLengthRule)
        
        return rules
    }
    
    class func pwCompareRule(pw: String) -> ValidationRuleEquality<String> {
        return ValidationRuleEquality<String>(dynamicTarget: { return pw }, error: ValidationError(message: "not the same"))
    }
    
}

struct ValidationError: Error {
    
    public let message: String
    
    public init(message m: String) {
        message = m
    }
}

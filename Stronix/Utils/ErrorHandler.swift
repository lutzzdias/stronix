//
//  ErrorHandler.swift
//  Stronix
//
//  Created by Thiago Dias on 14/04/26.
//

import SwiftUI

@Observable
class ErrorHandler {
    var message: String?
    
    func show(_ message: String) {
        self.message = message
    }
}

struct ErrorAlertModifier: ViewModifier {
    @Environment(ErrorHandler.self) var errorHandler
    
    func body(content: Content) -> some View {
        @Bindable var errorHandler = errorHandler
        
        content
            .alert("Error", isPresented: Binding(
                get: { errorHandler.message != nil },
                set: { isPresented in if !isPresented { errorHandler.message = nil } }
            )) {
                Button("OK") { errorHandler.message = nil }
            } message: {
                Text(errorHandler.message ?? "")
            }
    }
}

extension View {
    func withErrorHandler() -> some View {
        modifier(ErrorAlertModifier())
    }
}

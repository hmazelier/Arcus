//
//  Reducer.swift
//  Arcus
//
//  Created by Hadrien Mazelier on 24/09/2018.
//

import Foundation
import Arcus
import RxSwift
import RxCocoa
{% if useSwinject %}
import Swinject
{% endif %}

{{ accessLevel }}protocol {{ name }}ReducerProtocol{% if isStepsPropducer %}: StepProducer{% endif %} {
    var state: BehaviorSubject<{{ name }}.State> { get }
    var actions: PublishRelay<Action> { get }
    {% if isProcessingEventsEmitter %}
    var processingEvents: PublishRelay<ProcessingEvent> { get }
    {% endif %}
    func start()
}
    
{{ accessLevel }}final class {{ name }}Reducer: Reducer, {{ name }}ReducerProtocol {
    
    {% if useSwinject %}let resolver: Resolver{% endif %}
    
    {{ accessLevel }}init({% if useSwinject %}resolver: Resolver{% endif %}) {
        {% if useSwinject %}self.resolver = resolver{% endif %}
    }
    
    func provideInitialState() -> {{ name }}.State {
        return {{ name }}.State()
    }
    
    func produceEvent(from action: {{ name }}.Actions) -> Observable<Arcus.Event> {
        return .empty() // change this
    }
    
    func reduce(state: {{ name }}.State, mutation: {{ name }}.Mutations) -> {{ name }}.State {
        var state = state
        
        switch mutation {
            default: break // change this
        }
        
        return state
    }
}

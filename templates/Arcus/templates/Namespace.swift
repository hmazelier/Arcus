//
//  {{ name }}.swift


import Foundation
import Arcus

{{ accessLevel }}enum {{ name }} {

    {{ accessLevel }}enum Actions {

    }

    {{ accessLevel }}enum Mutations {

    }

    {% if isProcessingEventsEmitter %}
    {{ accessLevel }}enum ProcessingEvent {

    }

    {% endif %}
    {{ accessLevel }}struct State {

    }

{{ accessLevel }}extension {{ name }}.Actions: Arcus.Action {}
{{ accessLevel }}extension {{ name }}.Mutations: Arcus.Mutation {}
{{ accessLevel }}extension {{ name }}.State: Arcus.State {}
{% if isProcessingEventsEmitter %}
{{ accessLevel }}extension {{ name }}.ProcessingEvent: Arcus.ProcessingEvent {}
{% endif %}

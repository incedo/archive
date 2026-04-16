package archive.ports.eventstore

import archive.domain.intake.event.DomainEvent

interface EventStore {
    fun append(events: List<DomainEvent>)
    fun loadByTag(tag: String): List<DomainEvent>
}

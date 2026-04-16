package archive.ports.eventstore

import archive.domain.intake.event.DomainEvent

interface EventStore {
    fun append(events: List<DomainEvent>, condition: AppendCondition = AppendCondition.Any)
    fun loadByTag(tag: String): List<DomainEvent>
}

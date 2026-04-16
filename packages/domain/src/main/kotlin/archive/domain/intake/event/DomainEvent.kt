package archive.domain.intake.event

interface DomainEvent {
    val tags: Set<String>
}

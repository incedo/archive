package archive.ports.eventstore

sealed interface AppendCondition {
    data object Any : AppendCondition
    data class TagEventCount(
        val tag: String,
        val expectedCount: Long,
    ) : AppendCondition
}

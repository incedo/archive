package archive.adapters.postgres

import archive.domain.intake.event.DocumentChecksumRecorded
import archive.domain.intake.event.DocumentIngestStatusUpdated
import archive.domain.intake.event.DocumentIntakeRequested
import archive.domain.intake.event.DomainEvent
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class DomainEventJsonCodec(
    private val json: Json = Json { encodeDefaults = true },
) {
    fun eventType(event: DomainEvent): String =
        when (event) {
            is DocumentIntakeRequested -> "DocumentIntakeRequested"
            is DocumentChecksumRecorded -> "DocumentChecksumRecorded"
            is DocumentIngestStatusUpdated -> "DocumentIngestStatusUpdated"
            else -> error("Unsupported domain event type: ${event::class.qualifiedName}")
        }

    fun aggregateId(event: DomainEvent): String =
        when (event) {
            is DocumentIntakeRequested -> event.documentId
            is DocumentChecksumRecorded -> event.documentId
            is DocumentIngestStatusUpdated -> event.documentId
            else -> error("Unsupported domain event type: ${event::class.qualifiedName}")
        }

    fun encode(event: DomainEvent): String =
        when (event) {
            is DocumentIntakeRequested -> json.encodeToString(event)
            is DocumentChecksumRecorded -> json.encodeToString(event)
            is DocumentIngestStatusUpdated -> json.encodeToString(event)
            else -> error("Unsupported domain event type: ${event::class.qualifiedName}")
        }
}

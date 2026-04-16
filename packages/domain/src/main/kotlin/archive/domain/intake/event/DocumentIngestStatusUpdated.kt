package archive.domain.intake.event

import archive.domain.intake.model.DocumentId
import archive.domain.intake.model.IngestStatus
import kotlinx.serialization.Serializable

@Serializable
data class DocumentIngestStatusUpdated(
    val documentId: String,
    val status: IngestStatus,
    override val tags: Set<String>,
) : DomainEvent {
    companion object {
        fun create(documentId: DocumentId, status: IngestStatus): DocumentIngestStatusUpdated =
            DocumentIngestStatusUpdated(
                documentId = documentId.value,
                status = status,
                tags = setOf("document:${documentId.value}"),
            )
    }
}

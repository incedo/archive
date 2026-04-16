package archive.domain.intake.decision

import archive.domain.intake.event.DocumentChecksumRecorded
import archive.domain.intake.event.DocumentIngestStatusUpdated
import archive.domain.intake.event.DocumentIntakeRequested
import archive.domain.intake.event.DomainEvent
import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentMetadata
import archive.domain.intake.model.IngestStatus

data class DocumentIntakeDecisionModel(
    val documentId: String? = null,
    val status: IngestStatus? = null,
    val checksum: Checksum? = null,
    val fileName: String? = null,
    val contentType: String? = null,
    val documentTypeHint: String? = null,
    val metadata: DocumentMetadata? = null,
) {
    fun apply(event: DomainEvent): DocumentIntakeDecisionModel =
        when (event) {
            is DocumentIntakeRequested -> copy(
                documentId = event.documentId,
                fileName = event.fileName,
                contentType = event.contentType,
                documentTypeHint = event.documentTypeHint,
                metadata = event.metadata,
            )
            is DocumentChecksumRecorded -> copy(
                documentId = event.documentId,
                checksum = event.checksum,
            )
            is DocumentIngestStatusUpdated -> copy(
                documentId = event.documentId,
                status = event.status,
            )
            else -> this
        }

    fun ensureRegisterable() {
        require(documentId == null) { "document already exists" }
    }

    companion object {
        fun rehydrate(events: List<DomainEvent>): DocumentIntakeDecisionModel =
            events.fold(DocumentIntakeDecisionModel()) { state, event -> state.apply(event) }
    }
}

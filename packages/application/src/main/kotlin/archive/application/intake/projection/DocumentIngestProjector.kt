package archive.application.intake.projection

import archive.domain.intake.decision.DocumentIntakeDecisionModel
import archive.domain.intake.event.DomainEvent
import archive.ports.readmodel.DocumentIngestView

class DocumentIngestProjector {
    fun project(events: List<DomainEvent>): DocumentIngestView? =
        project(DocumentIntakeDecisionModel.rehydrate(events))

    fun project(decision: DocumentIntakeDecisionModel): DocumentIngestView? {
        val resolvedDocumentId = decision.documentId ?: return null
        val resolvedStatus = decision.status ?: return null
        val resolvedChecksum = decision.checksum ?: return null
        val resolvedFileName = decision.fileName ?: return null
        val resolvedContentType = decision.contentType ?: return null
        val resolvedMetadata = decision.metadata ?: return null

        return DocumentIngestView(
            documentId = resolvedDocumentId,
            status = resolvedStatus,
            checksum = resolvedChecksum,
            fileName = resolvedFileName,
            contentType = resolvedContentType,
            documentTypeHint = decision.documentTypeHint,
            metadata = resolvedMetadata,
        )
    }
}

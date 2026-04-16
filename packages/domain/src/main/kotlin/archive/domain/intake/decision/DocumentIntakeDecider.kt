package archive.domain.intake.decision

import archive.domain.intake.command.RegisterDocumentIntake
import archive.domain.intake.event.DocumentChecksumRecorded
import archive.domain.intake.event.DocumentIngestStatusUpdated
import archive.domain.intake.event.DocumentIntakeRequested
import archive.domain.intake.event.DomainEvent
import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentId
import archive.domain.intake.model.IngestStatus

object DocumentIntakeDecider {
    fun decideRegister(
        state: DocumentIntakeDecisionModel,
        documentId: DocumentId,
        command: RegisterDocumentIntake,
        checksum: Checksum,
    ): List<DomainEvent> {
        state.ensureRegisterable()

        return listOf(
            DocumentIntakeRequested.create(
                documentId = documentId,
                fileName = command.fileName,
                contentType = command.contentType,
                documentTypeHint = command.documentTypeHint,
                metadata = command.metadata,
            ),
            DocumentChecksumRecorded.create(documentId, checksum),
            DocumentIngestStatusUpdated.create(documentId, IngestStatus.REGISTERED),
        )
    }
}

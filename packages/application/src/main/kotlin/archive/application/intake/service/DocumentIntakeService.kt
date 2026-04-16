package archive.application.intake.service

import archive.domain.intake.command.RegisterDocumentIntake
import archive.domain.intake.decision.DocumentIntakeDecisionModel
import archive.domain.intake.event.DocumentChecksumRecorded
import archive.domain.intake.event.DocumentIngestStatusUpdated
import archive.domain.intake.event.DocumentIntakeRequested
import archive.domain.intake.model.DocumentId
import archive.domain.intake.model.IngestStatus
import archive.domain.intake.validation.DocumentIntakeValidation
import archive.ports.checksum.ChecksumService
import archive.ports.eventstore.AppendCondition
import archive.ports.eventstore.EventStore
import archive.ports.readmodel.DocumentIngestView
import archive.ports.readmodel.DocumentIngestViewRepository

class DocumentIntakeService(
    private val checksumService: ChecksumService,
    private val eventStore: EventStore,
    private val repository: DocumentIngestViewRepository,
) {
    fun register(command: RegisterDocumentIntake): DocumentIngestView {
        DocumentIntakeValidation.validate(command)

        val documentId = DocumentId.generate()
        val tag = "document:${documentId.value}"
        DocumentIntakeDecisionModel.rehydrate(eventStore.loadByTag(tag)).ensureRegisterable()
        val checksum = checksumService.calculate(command.content)
        val status = IngestStatus.REGISTERED

        val newEvents = listOf(
            DocumentIntakeRequested.create(
                documentId = documentId,
                fileName = command.fileName,
                contentType = command.contentType,
                documentTypeHint = command.documentTypeHint,
                metadata = command.metadata,
            ),
            DocumentChecksumRecorded.create(documentId, checksum),
            DocumentIngestStatusUpdated.create(documentId, status),
        )
        eventStore.append(
            events = newEvents,
            condition = AppendCondition.TagEventCount(
                tag = tag,
                expectedCount = 0,
            ),
        )

        val view = toView(
            DocumentIntakeDecisionModel.rehydrate(newEvents)
        ) ?: error("could not rebuild intake view from newly appended events")
        repository.save(view)
        return view
    }

    fun get(documentId: String): DocumentIngestView? {
        repository.findById(documentId)?.let { return it }

        val rebuilt = DocumentIntakeDecisionModel
            .rehydrate(eventStore.loadByTag("document:$documentId"))
            .let(::toView)

        if (rebuilt != null) {
            repository.save(rebuilt)
        }

        return rebuilt
    }

    private fun toView(decision: DocumentIntakeDecisionModel): DocumentIngestView? {
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

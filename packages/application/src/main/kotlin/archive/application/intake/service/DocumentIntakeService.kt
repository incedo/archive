package archive.application.intake.service

import archive.domain.intake.command.RegisterDocumentIntake
import archive.domain.intake.decision.DocumentIntakeDecisionModel
import archive.application.intake.projection.DocumentIngestProjector
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
    private val projector: DocumentIngestProjector = DocumentIngestProjector(),
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

        val view = projector.project(newEvents)
            ?: error("could not rebuild intake view from newly appended events")
        repository.save(view)
        return view
    }

    fun get(documentId: String): DocumentIngestView? {
        repository.findById(documentId)?.let { return it }

        val rebuilt = projector.project(eventStore.loadByTag("document:$documentId"))

        if (rebuilt != null) {
            repository.save(rebuilt)
        }

        return rebuilt
    }
}

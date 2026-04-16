package archive.application.intake.command

import archive.application.intake.projection.DocumentIngestProjector
import archive.domain.intake.command.RegisterDocumentIntake
import archive.domain.intake.decision.DocumentIntakeDecider
import archive.domain.intake.decision.DocumentIntakeDecisionModel
import archive.domain.intake.model.DocumentId
import archive.domain.intake.validation.DocumentIntakeValidation
import archive.ports.checksum.ChecksumService
import archive.ports.eventstore.AppendCondition
import archive.ports.eventstore.EventStore
import archive.ports.readmodel.DocumentIngestView
import archive.ports.readmodel.DocumentIngestViewRepository

class RegisterDocumentIntakeHandler(
    private val checksumService: ChecksumService,
    private val eventStore: EventStore,
    private val repository: DocumentIngestViewRepository,
    private val projector: DocumentIngestProjector = DocumentIngestProjector(),
) {
    fun handle(command: RegisterDocumentIntake): DocumentIngestView {
        DocumentIntakeValidation.validate(command)

        val documentId = DocumentId.generate()
        val tag = "document:${documentId.value}"
        val state = DocumentIntakeDecisionModel.rehydrate(eventStore.loadByTag(tag))
        val checksum = checksumService.calculate(command.content)

        val newEvents = DocumentIntakeDecider.decideRegister(
            state = state,
            documentId = documentId,
            command = command,
            checksum = checksum,
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
}

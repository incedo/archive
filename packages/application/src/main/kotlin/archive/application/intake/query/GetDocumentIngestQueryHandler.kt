package archive.application.intake.query

import archive.application.intake.projection.DocumentIngestProjector
import archive.domain.intake.decision.DocumentIntakeDecisionModel
import archive.ports.eventstore.EventStore
import archive.ports.readmodel.DocumentIngestView
import archive.ports.readmodel.DocumentIngestViewRepository

class GetDocumentIngestQueryHandler(
    private val eventStore: EventStore,
    private val repository: DocumentIngestViewRepository,
    private val projector: DocumentIngestProjector = DocumentIngestProjector(),
) {
    fun handle(documentId: String): DocumentIngestView? {
        repository.findById(documentId)?.let { return it }

        val rebuilt = projector.project(
            DocumentIntakeDecisionModel.rehydrate(eventStore.loadByTag("document:$documentId"))
        )

        if (rebuilt != null) {
            repository.save(rebuilt)
        }

        return rebuilt
    }
}

package archive.application.intake.query

import archive.application.intake.projection.DocumentIngestProjector
import archive.application.intake.result.DocumentIngestResult
import archive.application.intake.result.toResult
import archive.domain.intake.decision.DocumentIntakeDecisionModel
import archive.ports.eventstore.EventStore
import archive.ports.readmodel.DocumentIngestViewRepository

class GetDocumentIngestQueryHandler(
    private val eventStore: EventStore,
    private val repository: DocumentIngestViewRepository,
    private val projector: DocumentIngestProjector = DocumentIngestProjector(),
) {
    fun handle(query: GetDocumentIngestQuery): DocumentIngestResult? {
        val documentId = query.documentId
        repository.findById(documentId)?.let { return it.toResult() }

        val rebuilt = projector.project(
            DocumentIntakeDecisionModel.rehydrate(eventStore.loadByTag("document:$documentId"))
        )

        if (rebuilt != null) {
            repository.save(rebuilt)
        }

        return rebuilt?.toResult()
    }
}

package archive.application.intake.query

import archive.ports.readmodel.DocumentIngestView
import archive.ports.readmodel.DocumentIngestViewRepository

class ListRecentIngestionsQueryHandler(
    private val repository: DocumentIngestViewRepository,
) {
    fun handle(query: ListRecentIngestionsQuery): List<DocumentIngestView> {
        return repository.findRecent(query.limit)
    }
}

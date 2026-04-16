package archive.application.intake.query

import archive.domain.intake.event.DocumentChecksumRecorded
import archive.domain.intake.event.DocumentIngestStatusUpdated
import archive.domain.intake.event.DocumentIntakeRequested
import archive.domain.intake.event.DomainEvent
import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentMetadata
import archive.domain.intake.model.IngestStatus
import archive.ports.eventstore.AppendCondition
import archive.ports.eventstore.EventStore
import archive.ports.readmodel.DocumentIngestView
import archive.ports.readmodel.DocumentIngestViewRepository
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

class GetDocumentIngestQueryHandlerTest {
    @Test
    fun `handle rebuilds ingest view from event history when read model is missing`() {
        val checksum = Checksum("SHA-256", "rebuilt")
        val documentId = "doc-rebuild"
        val eventStore = RecordingEventStore(
            eventsByTag = mutableMapOf(
                "document:$documentId" to mutableListOf(
                    DocumentIntakeRequested(
                        documentId = documentId,
                        fileName = "rebuilt.pdf",
                        contentType = "application/pdf",
                        documentTypeHint = "invoice",
                        metadata = DocumentMetadata("scanner", "INV-1"),
                        tags = setOf("document:$documentId"),
                    ),
                    DocumentChecksumRecorded(
                        documentId = documentId,
                        checksum = checksum,
                        tags = setOf("document:$documentId"),
                    ),
                    DocumentIngestStatusUpdated(
                        documentId = documentId,
                        status = IngestStatus.REGISTERED,
                        tags = setOf("document:$documentId"),
                    ),
                )
            )
        )
        val repository = RecordingRepository()
        val handler = GetDocumentIngestQueryHandler(
            eventStore = eventStore,
            repository = repository,
        )

        val rebuilt = handler.handle(GetDocumentIngestQuery(documentId))

        assertNotNull(rebuilt)
        assertEquals(documentId, rebuilt.documentId)
        assertEquals(checksum, rebuilt.checksum)
        assertEquals(1, repository.saved.size)
    }
}

private class RecordingEventStore(
    private val eventsByTag: MutableMap<String, MutableList<DomainEvent>> = mutableMapOf(),
) : EventStore {
    override fun append(events: List<DomainEvent>, condition: AppendCondition) {
        error("append should not be called in query test")
    }

    override fun loadByTag(tag: String): List<DomainEvent> = eventsByTag[tag].orEmpty()
}

private class RecordingRepository : DocumentIngestViewRepository {
    val saved = mutableListOf<DocumentIngestView>()
    private val views = mutableMapOf<String, DocumentIngestView>()

    override fun save(view: DocumentIngestView) {
        saved += view
        views[view.documentId] = view
    }

    override fun findById(documentId: String): DocumentIngestView? = views[documentId]
}

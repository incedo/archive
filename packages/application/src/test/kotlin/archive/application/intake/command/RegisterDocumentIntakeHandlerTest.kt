package archive.application.intake.command

import archive.domain.intake.command.RegisterDocumentIntake
import archive.domain.intake.event.DocumentChecksumRecorded
import archive.domain.intake.event.DocumentIngestStatusUpdated
import archive.domain.intake.event.DocumentIntakeRequested
import archive.domain.intake.event.DomainEvent
import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentMetadata
import archive.domain.intake.model.IngestStatus
import archive.ports.checksum.ChecksumService
import archive.ports.eventstore.AppendCondition
import archive.ports.eventstore.EventStore
import archive.ports.readmodel.DocumentIngestView
import archive.ports.readmodel.DocumentIngestViewRepository
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class RegisterDocumentIntakeHandlerTest {
    @Test
    fun `handle queries event history before append`() {
        val eventStore = RecordingEventStore()
        val repository = RecordingRepository()
        val handler = RegisterDocumentIntakeHandler(
            checksumService = FixedChecksumService(),
            eventStore = eventStore,
            repository = repository,
        )

        val view = handler.handle(validCommand())

        assertEquals(1, eventStore.loadedTags.size)
        assertTrue(eventStore.loadedTags.single().startsWith("document:"))
        assertEquals(eventStore.loadedTags.single(), eventStore.appendedEvents.first().tags.single())
        assertEquals(
            AppendCondition.TagEventCount(
                tag = eventStore.loadedTags.single(),
                expectedCount = 0,
            ),
            eventStore.appendConditions.single(),
        )
        assertEquals(view, repository.saved.single())
    }
}

private fun validCommand(): RegisterDocumentIntake =
    RegisterDocumentIntake(
        fileName = "contract.pdf",
        contentType = "application/pdf",
        content = "hello".encodeToByteArray(),
        documentTypeHint = "contract",
        metadata = DocumentMetadata(
            sourceSystem = "manual-upload",
            businessKey = "CTR-1",
        ),
    )

private class FixedChecksumService : ChecksumService {
    override fun calculate(content: ByteArray): Checksum = Checksum("SHA-256", "fixed")
}

private class RecordingEventStore(
    private val eventsByTag: MutableMap<String, MutableList<DomainEvent>> = mutableMapOf(),
) : EventStore {
    val loadedTags = mutableListOf<String>()
    val appendedEvents = mutableListOf<DomainEvent>()
    val appendConditions = mutableListOf<AppendCondition>()

    override fun append(events: List<DomainEvent>, condition: AppendCondition) {
        appendConditions += condition
        appendedEvents += events
        events.forEach { event ->
            event.tags.forEach { tag ->
                eventsByTag.getOrPut(tag) { mutableListOf() }.add(event)
            }
        }
    }

    override fun loadByTag(tag: String): List<DomainEvent> {
        loadedTags += tag
        return eventsByTag[tag].orEmpty()
    }
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

package archive.app

import archive.domain.intake.event.DomainEvent
import archive.domain.intake.model.Checksum
import archive.ports.checksum.ChecksumService
import archive.ports.eventstore.EventStore
import archive.ports.readmodel.DocumentIngestView
import archive.ports.readmodel.DocumentIngestViewRepository
import java.security.MessageDigest
import java.util.concurrent.ConcurrentHashMap

class Sha256ChecksumService : ChecksumService {
    override fun calculate(content: ByteArray): Checksum {
        val digest = MessageDigest.getInstance("SHA-256")
        val bytes = digest.digest(content)
        val value = bytes.joinToString("") { "%02x".format(it) }
        return Checksum(algorithm = "SHA-256", value = value)
    }
}

class InMemoryEventStore : EventStore {
    private val events = mutableListOf<DomainEvent>()

    override fun append(events: List<DomainEvent>) {
        this.events.addAll(events)
    }

    override fun loadByTag(tag: String): List<DomainEvent> =
        events.filter { event -> tag in event.tags }
}

class InMemoryDocumentIngestViewRepository : DocumentIngestViewRepository {
    private val store = ConcurrentHashMap<String, DocumentIngestView>()

    override fun save(view: DocumentIngestView) {
        store[view.documentId] = view
    }

    override fun findById(documentId: String): DocumentIngestView? = store[documentId]
}

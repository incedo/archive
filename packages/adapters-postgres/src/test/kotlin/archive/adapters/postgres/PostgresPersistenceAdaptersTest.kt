package archive.adapters.postgres

import archive.domain.intake.event.DocumentChecksumRecorded
import archive.domain.intake.event.DocumentIngestStatusUpdated
import archive.domain.intake.event.DocumentIntakeRequested
import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentId
import archive.domain.intake.model.DocumentMetadata
import archive.domain.intake.model.IngestStatus
import archive.ports.readmodel.DocumentIngestView
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

class PostgresPersistenceAdaptersTest {
    private fun connectionFactory(databaseName: String): JdbcConnectionFactory =
        JdbcConnectionFactory(
            jdbcUrl = "jdbc:h2:mem:$databaseName;MODE=PostgreSQL;DB_CLOSE_DELAY=-1",
            username = "sa",
            password = "",
        )

    @Test
    fun `event store persists events and tags`() {
        val connectionFactory = connectionFactory("event-store")
        PostgresSchemaInitializer(connectionFactory).initialize()
        val eventStore = PostgresEventStore(connectionFactory)
        val documentId = DocumentId.generate()

        eventStore.append(
            listOf(
                DocumentIntakeRequested.create(
                    documentId = documentId,
                    fileName = "contract.pdf",
                    contentType = "application/pdf",
                    documentTypeHint = "contract",
                    metadata = DocumentMetadata(
                        sourceSystem = "scanner",
                        businessKey = "CTR-100",
                    ),
                ),
                DocumentChecksumRecorded.create(
                    documentId = documentId,
                    checksum = Checksum("SHA-256", "abc123"),
                ),
                DocumentIngestStatusUpdated.create(documentId, IngestStatus.REGISTERED),
            )
        )

        connectionFactory.open().use { connection ->
            connection.createStatement().use { statement ->
                statement.executeQuery("select count(*) from archive_events").use { rs ->
                    assertEquals(true, rs.next())
                    assertEquals(3, rs.getInt(1))
                }
                statement.executeQuery("select count(*) from archive_event_tags").use { rs ->
                    assertEquals(true, rs.next())
                    assertEquals(3, rs.getInt(1))
                }
            }
        }
    }

    @Test
    fun `read model repository stores and loads ingest view`() {
        val connectionFactory = connectionFactory("read-model")
        PostgresSchemaInitializer(connectionFactory).initialize()
        val repository = PostgresDocumentIngestViewRepository(connectionFactory)

        val view = DocumentIngestView(
            documentId = "doc-123",
            status = IngestStatus.REGISTERED,
            checksum = Checksum("SHA-256", "deadbeef"),
            fileName = "invoice.pdf",
            contentType = "application/pdf",
            documentTypeHint = "invoice",
            metadata = DocumentMetadata(
                sourceSystem = "legacy-alfresco",
                businessKey = "INV-1001",
            ),
        )

        repository.save(view)

        val stored = repository.findById("doc-123")
        assertNotNull(stored)
        assertEquals(view, stored)
    }
}

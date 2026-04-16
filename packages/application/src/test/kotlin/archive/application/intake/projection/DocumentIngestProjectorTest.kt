package archive.application.intake.projection

import archive.domain.intake.event.DocumentChecksumRecorded
import archive.domain.intake.event.DocumentIngestStatusUpdated
import archive.domain.intake.event.DocumentIntakeRequested
import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentMetadata
import archive.domain.intake.model.IngestStatus
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

class DocumentIngestProjectorTest {
    private val projector = DocumentIngestProjector()

    @Test
    fun `projects ingest view from intake events`() {
        val documentId = "doc-123"
        val projected = projector.project(
            listOf(
                DocumentIntakeRequested(
                    documentId = documentId,
                    fileName = "invoice.pdf",
                    contentType = "application/pdf",
                    documentTypeHint = "invoice",
                    metadata = DocumentMetadata(
                        sourceSystem = "scanner",
                        businessKey = "INV-1001",
                    ),
                    tags = setOf("document:$documentId"),
                ),
                DocumentChecksumRecorded(
                    documentId = documentId,
                    checksum = Checksum("SHA-256", "abc123"),
                    tags = setOf("document:$documentId"),
                ),
                DocumentIngestStatusUpdated(
                    documentId = documentId,
                    status = IngestStatus.REGISTERED,
                    tags = setOf("document:$documentId"),
                ),
            )
        )

        assertNotNull(projected)
        assertEquals(documentId, projected.documentId)
        assertEquals("invoice.pdf", projected.fileName)
        assertEquals("abc123", projected.checksum.value)
        assertEquals(IngestStatus.REGISTERED, projected.status)
    }
}

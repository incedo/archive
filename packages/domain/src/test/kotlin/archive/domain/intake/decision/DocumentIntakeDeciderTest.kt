package archive.domain.intake.decision

import archive.domain.intake.command.RegisterDocumentIntake
import archive.domain.intake.event.DocumentChecksumRecorded
import archive.domain.intake.event.DocumentIngestStatusUpdated
import archive.domain.intake.event.DocumentIntakeRequested
import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentId
import archive.domain.intake.model.DocumentMetadata
import archive.domain.intake.model.IngestStatus
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertIs

class DocumentIntakeDeciderTest {
    @Test
    fun `decide register emits intake checksum and status events`() {
        val documentId = DocumentId.generate()
        val events = DocumentIntakeDecider.decideRegister(
            state = DocumentIntakeDecisionModel(),
            documentId = documentId,
            command = validCommand(),
            checksum = Checksum("SHA-256", "abc123"),
        )

        assertEquals(3, events.size)
        assertIs<DocumentIntakeRequested>(events[0])
        assertIs<DocumentChecksumRecorded>(events[1])
        assertIs<DocumentIngestStatusUpdated>(events[2])
        assertEquals(IngestStatus.REGISTERED, (events[2] as DocumentIngestStatusUpdated).status)
    }

    @Test
    fun `decide register rejects existing document state`() {
        val existing = DocumentIntakeDecisionModel(
            documentId = "doc-1",
            status = IngestStatus.REGISTERED,
            checksum = Checksum("SHA-256", "existing"),
            fileName = "existing.pdf",
            contentType = "application/pdf",
            documentTypeHint = "contract",
            metadata = DocumentMetadata("scanner", "CTR-1"),
        )

        assertFailsWith<IllegalArgumentException> {
            DocumentIntakeDecider.decideRegister(
                state = existing,
                documentId = DocumentId.generate(),
                command = validCommand(),
                checksum = Checksum("SHA-256", "abc123"),
            )
        }
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

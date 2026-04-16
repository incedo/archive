package archive.application.intake.result

import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentMetadata
import archive.domain.intake.model.IngestStatus
import archive.ports.readmodel.DocumentIngestView

data class DocumentIngestResult(
    val documentId: String,
    val status: IngestStatus,
    val checksum: Checksum,
    val fileName: String,
    val contentType: String,
    val documentTypeHint: String?,
    val metadata: DocumentMetadata,
)

fun DocumentIngestView.toResult(): DocumentIngestResult =
    DocumentIngestResult(
        documentId = documentId,
        status = status,
        checksum = checksum,
        fileName = fileName,
        contentType = contentType,
        documentTypeHint = documentTypeHint,
        metadata = metadata,
    )

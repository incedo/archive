package archive.ports.readmodel

import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentMetadata
import archive.domain.intake.model.IngestStatus
import kotlinx.serialization.Serializable

@Serializable
data class DocumentIngestView(
    val documentId: String,
    val status: IngestStatus,
    val checksum: Checksum,
    val fileName: String,
    val contentType: String,
    val documentTypeHint: String?,
    val metadata: DocumentMetadata,
)

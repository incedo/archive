package archive.domain.intake.event

import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentId
import kotlinx.serialization.Serializable

@Serializable
data class DocumentChecksumRecorded(
    val documentId: String,
    val checksum: Checksum,
    override val tags: Set<String>,
) : DomainEvent {
    companion object {
        fun create(documentId: DocumentId, checksum: Checksum): DocumentChecksumRecorded =
            DocumentChecksumRecorded(
                documentId = documentId.value,
                checksum = checksum,
                tags = setOf("document:${documentId.value}"),
            )
    }
}

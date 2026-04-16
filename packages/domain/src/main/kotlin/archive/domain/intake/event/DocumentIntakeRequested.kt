package archive.domain.intake.event

import archive.domain.intake.model.DocumentId
import archive.domain.intake.model.DocumentMetadata
import kotlinx.serialization.Serializable

@Serializable
data class DocumentIntakeRequested(
    val documentId: String,
    val fileName: String,
    val contentType: String,
    val documentTypeHint: String?,
    val metadata: DocumentMetadata,
    override val tags: Set<String>,
) : DomainEvent {
    companion object {
        fun create(
            documentId: DocumentId,
            fileName: String,
            contentType: String,
            documentTypeHint: String?,
            metadata: DocumentMetadata,
        ): DocumentIntakeRequested = DocumentIntakeRequested(
            documentId = documentId.value,
            fileName = fileName,
            contentType = contentType,
            documentTypeHint = documentTypeHint,
            metadata = metadata,
            tags = setOf("document:${documentId.value}"),
        )
    }
}

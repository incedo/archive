package archive.adapters.api

import archive.domain.intake.model.DocumentMetadata
import kotlinx.serialization.Serializable

data class GenericMultipartIntakePayload(
    val fileName: String,
    val contentType: String,
    val content: String,
    val documentTypeHint: String?,
    val metadata: DocumentMetadata,
)

@Serializable
data class GenericDocumentIntakeResponse(
    val documentId: String,
    val status: String,
    val checksumAlgorithm: String,
    val checksumValue: String,
    val fileName: String,
    val contentType: String,
    val documentTypeHint: String? = null,
    val metadata: DocumentMetadata,
)

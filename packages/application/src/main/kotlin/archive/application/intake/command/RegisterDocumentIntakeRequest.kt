package archive.application.intake.command

import archive.domain.intake.model.DocumentMetadata

data class RegisterDocumentIntakeRequest(
    val fileName: String,
    val contentType: String,
    val content: ByteArray,
    val documentTypeHint: String?,
    val metadata: DocumentMetadata,
)

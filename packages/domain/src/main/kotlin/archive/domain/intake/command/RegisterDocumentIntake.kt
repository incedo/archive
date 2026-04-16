package archive.domain.intake.command

import archive.domain.intake.model.DocumentMetadata

data class RegisterDocumentIntake(
    val fileName: String,
    val contentType: String,
    val content: ByteArray,
    val documentTypeHint: String?,
    val metadata: DocumentMetadata,
)

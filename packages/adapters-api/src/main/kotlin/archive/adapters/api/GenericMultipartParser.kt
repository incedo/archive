package archive.adapters.api

import archive.domain.intake.model.DocumentMetadata
import io.ktor.http.content.PartData
import io.ktor.http.content.forEachPart
import io.ktor.server.request.receiveMultipart
import io.ktor.server.application.ApplicationCall
import io.ktor.utils.io.toByteArray

private data class ParsedMultipartFields(
    var fileName: String? = null,
    var contentType: String? = null,
    var content: String? = null,
    var documentTypeHint: String? = null,
    var sourceSystem: String? = null,
    var businessKey: String? = null,
)

private suspend fun parseMultipart(call: ApplicationCall): ParsedMultipartFields {
    val fields = ParsedMultipartFields()
    val multipart = call.receiveMultipart()

    multipart.forEachPart { part ->
        when (part) {
            is PartData.FileItem -> {
                fields.fileName = part.originalFileName ?: "upload.bin"
                fields.contentType = part.contentType?.toString() ?: "application/octet-stream"
                fields.content = part.provider().toByteArray().toString(Charsets.UTF_8)
            }
            is PartData.FormItem -> {
                when (part.name) {
                    "documentTypeHint" -> fields.documentTypeHint = part.value
                    "sourceSystem" -> fields.sourceSystem = part.value
                    "businessKey" -> fields.businessKey = part.value
                }
            }
            else -> {}
        }
        part.dispose()
    }

    return fields
}

private fun ParsedMultipartFields.toPayload(): GenericMultipartIntakePayload =
    GenericMultipartIntakePayload(
        fileName = requireNotNull(fileName) { "file is required" },
        contentType = requireNotNull(contentType) { "contentType is required" },
        content = requireNotNull(content) { "file content is required" },
        documentTypeHint = documentTypeHint,
        metadata = DocumentMetadata(
            sourceSystem = requireNotNull(sourceSystem) { "sourceSystem is required" },
            businessKey = requireNotNull(businessKey) { "businessKey is required" },
        ),
    )

suspend fun parseGenericMultipartIntake(call: ApplicationCall): GenericMultipartIntakePayload =
    parseMultipart(call).toPayload()

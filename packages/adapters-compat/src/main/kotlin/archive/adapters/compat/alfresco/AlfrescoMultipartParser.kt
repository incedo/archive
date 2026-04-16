package archive.adapters.compat.alfresco

import io.ktor.http.content.PartData
import io.ktor.http.content.forEachPart
import io.ktor.server.application.ApplicationCall
import io.ktor.server.request.receiveMultipart
import io.ktor.utils.io.toByteArray

private data class ParsedAlfrescoFields(
    var name: String? = null,
    var nodeType: String? = null,
    var content: String? = null,
    var sourceSystem: String? = null,
    var businessKey: String? = null,
    var contentType: String? = null,
)

private suspend fun parseMultipart(call: ApplicationCall): ParsedAlfrescoFields {
    val fields = ParsedAlfrescoFields()
    val multipart = call.receiveMultipart()

    multipart.forEachPart { part ->
        when (part) {
            is PartData.FileItem -> {
                fields.name = part.originalFileName ?: "upload.bin"
                fields.contentType = part.contentType?.toString() ?: "application/octet-stream"
                fields.content = part.provider().toByteArray().toString(Charsets.UTF_8)
            }
            is PartData.FormItem -> {
                when (part.name) {
                    "name" -> fields.name = part.value
                    "nodeType" -> fields.nodeType = part.value
                    "archive:sourceSystem" -> fields.sourceSystem = part.value
                    "archive:businessKey" -> fields.businessKey = part.value
                }
            }
            else -> {}
        }
        part.dispose()
    }

    return fields
}

private fun ParsedAlfrescoFields.toPayload(): AlfrescoMultipartIntakePayload =
    AlfrescoMultipartIntakePayload(
        name = requireNotNull(name) { "name is required" },
        nodeType = nodeType,
        content = requireNotNull(content) { "file is required" },
        sourceSystem = sourceSystem ?: "alfresco-compat",
        businessKey = businessKey ?: requireNotNull(name) { "name is required" },
        contentType = requireNotNull(contentType) { "contentType is required" },
    )

suspend fun parseAlfrescoMultipartIntake(call: ApplicationCall): AlfrescoMultipartIntakePayload =
    parseMultipart(call).toPayload()

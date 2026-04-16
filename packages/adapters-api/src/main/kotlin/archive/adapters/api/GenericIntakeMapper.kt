package archive.adapters.api

import archive.domain.intake.command.RegisterDocumentIntake
import archive.ports.readmodel.DocumentIngestView

object GenericIntakeMapper {
    fun toCommand(request: GenericMultipartIntakePayload): RegisterDocumentIntake =
        RegisterDocumentIntake(
            fileName = request.fileName,
            contentType = request.contentType,
            content = request.content,
            documentTypeHint = request.documentTypeHint,
            metadata = request.metadata,
        )

    fun toResponse(view: DocumentIngestView): GenericDocumentIntakeResponse =
        GenericDocumentIntakeResponse(
            documentId = view.documentId,
            status = view.status.name,
            checksumAlgorithm = view.checksum.algorithm,
            checksumValue = view.checksum.value,
            fileName = view.fileName,
            contentType = view.contentType,
            documentTypeHint = view.documentTypeHint,
            metadata = view.metadata,
        )
}

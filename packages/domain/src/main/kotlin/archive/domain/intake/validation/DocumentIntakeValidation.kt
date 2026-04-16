package archive.domain.intake.validation

import archive.domain.intake.command.RegisterDocumentIntake

object DocumentIntakeValidation {
    fun validate(command: RegisterDocumentIntake) {
        require(command.fileName.isNotBlank()) { "fileName is required" }
        require(command.contentType.isNotBlank()) { "contentType is required" }
        require(command.content.isNotEmpty()) { "content is required" }
    }
}

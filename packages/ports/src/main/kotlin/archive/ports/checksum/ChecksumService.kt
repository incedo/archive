package archive.ports.checksum

import archive.domain.intake.model.Checksum

interface ChecksumService {
    fun calculate(content: ByteArray): Checksum
}

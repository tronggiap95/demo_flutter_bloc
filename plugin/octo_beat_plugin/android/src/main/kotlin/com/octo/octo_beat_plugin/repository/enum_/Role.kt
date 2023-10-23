package com.octo.octo_beat_plugin.repository.enum_

enum class Role(var value: String) {
    CLINICIAN_TECHNICIAN("Clinic Technician"),
    CLINICIAN_PHYSICIAN("Clinic Physician"),
    PATIENT("patient");

    companion object {
        fun get(role: String?): Role {
            for (r in values()) {
                if (r.value == role) {
                    return r
                }
            }
            return PATIENT
        }
    }
}
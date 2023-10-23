package com.octo.octo_beat_plugin.core.device._enum

enum class DeviceStatus(var value: String) {
    READY("Ready for new study"),
    SETTING("Setting up"),
    STUDY_PROGRESS("Study is in progress"),
    STUDY_PAUSED("Study Paused"),
    STUDY_COMPLETED("Study Completed"),
    STUDY_UPLOADED("Study Uploaded"),
    STUDY_UPLOADING("Uploading study data"),
    STUDY_CREATED("Study created"),
    STUDY_ABORTED("Aborted"),
}
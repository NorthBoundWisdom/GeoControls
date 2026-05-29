if(NOT DEFINED GUIDEMO_LAUNCHER_PATH)
    message(FATAL_ERROR "GUIDEMO_LAUNCHER_PATH is required.")
endif()

if(NOT DEFINED GUIDEMO_EXECUTABLE_PATH)
    message(FATAL_ERROR "GUIDEMO_EXECUTABLE_PATH is required.")
endif()

if(APPLE)
    if(NOT DEFINED GUIDEMO_BUNDLE_PATH)
        message(FATAL_ERROR "GUIDEMO_BUNDLE_PATH is required.")
    endif()
    file(WRITE "${GUIDEMO_LAUNCHER_PATH}" "#!/bin/sh\nexec /usr/bin/open -n -W \"${GUIDEMO_BUNDLE_PATH}\" --args \"$@\"\n")
else()
    file(WRITE "${GUIDEMO_LAUNCHER_PATH}" "#!/bin/sh\nexec \"${GUIDEMO_EXECUTABLE_PATH}\" \"$@\"\n")
endif()

file(CHMOD "${GUIDEMO_LAUNCHER_PATH}"
    PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
)

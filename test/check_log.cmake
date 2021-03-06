#
# Copyright 2017, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#
#     * Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# XXX ask for a unique tempfile from cmake for LOG_OUTPUT
set(LOG_OUTPUT .log)
set(LOG_OUTPUT_FILTERED .log_filtered)

set(ENV{LD_PRELOAD} ${LIB_FILE})
set(ENV{INTERCEPT_LOG} ${LOG_OUTPUT})

execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${LOG_OUTPUT})

execute_process(COMMAND ${TEST_PROG} ${TEST_PROG_ARG}
	RESULT_VARIABLE HAD_ERROR)

set(ENV{LD_PRELOAD} "")
set(ENV{INTERCEPT_LOG} "")

if(HAD_ERROR)
	message(FATAL_ERROR "Test failed: ${HAD_ERROR}")
endif()

execute_process(COMMAND
	grep "\\<open\\>\\|\\<write\\>\\|\\<read\\>\\|\\<close\\>\\|\\<fstat\\>\\|\\<clone\\>\\|\\<wait4\\>"
	INPUT_FILE ${LOG_OUTPUT}
	OUTPUT_FILE ${LOG_OUTPUT_FILTERED})

execute_process(COMMAND echo ${MATCH_SCRIPT} -o ${LOG_OUTPUT_FILTERED} ${MATCH_FILE})
execute_process(COMMAND
	${MATCH_SCRIPT} -o ${LOG_OUTPUT_FILTERED} ${MATCH_FILE}
	RESULT_VARIABLE MATCH_ERROR)

if(MATCH_ERROR)
	message(FATAL_ERROR "Uwaga! Log does not match! ${MATCH_ERROR}")
endif()

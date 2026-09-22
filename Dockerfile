# gdb 로 메모리 버그를 디버깅하는 Linux 실습 환경.
# (macOS 는 gdb 지원이 불안정하므로, 이 컨테이너 안에서 gdb 실습을 권장)
#
# 사용:
#   docker build -t memdbg .
#   docker run --rm -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
#       -v "$PWD":/work memdbg                 # 셸 진입
#   # 컨테이너 안에서:
#   make check                    # 전 챌린지 실행 요약 (크래시 신호)
#   gdb ./build/06_null_deref     # run → bt → frame N → print 변수
#
#   PowerShell 은 "$PWD" 가 그대로 안 풀리니 ${PWD} 로 쓰세요:
#       docker run --rm -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined `
#           -v "${PWD}:/work" memdbg
#   마운트를 빼먹으면 /work 가 빈 채로 떠서 프로젝트가 안 보입니다.
#
#   세 조각이 각각 필요한 이유:
#     -v ${PWD}:/work              프로젝트를 컨테이너에 붙임
#     --cap-add=SYS_PTRACE         gdb 가 프로세스에 붙을 권한
#     --security-opt seccomp=...   기본 seccomp 가 ptrace 를 막아서
FROM ubuntu:24.04

# cmake 는 이 랩의 빌드에 쓰지 않습니다 — Makefile 프로젝트라 CMakeLists.txt 도 없어요.
# CLion 의 Docker 툴체인이 연결할 때 cmake 존재를 확인하는데, 없으면 툴체인 설정이
# 실패합니다. 그래서 넣어둡니다. 터미널에서만 쓸 거면 빼도 무방해요.
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential gcc gdb make cmake ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# gdb 시작 시 debuginfod(디버그 심볼 인터넷 자동 다운로드) 질문/지연 끄기.
# (버그는 -g 로 빌드한 우리 bug.c 안에 있어 시스템 라이브러리 심볼이 필요 없음)
RUN echo 'set debuginfod enabled off' >> /root/.gdbinit

WORKDIR /work
CMD ["/bin/bash"]

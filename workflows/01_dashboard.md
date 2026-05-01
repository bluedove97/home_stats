# Workflow 01 — 서버 대시보드

## 목표

미니서버의 `check_temperature.sh`가 10분마다 생성하는 HTML 조각들을 읽어서,
브라우저에서 바로 볼 수 있는 대시보드 페이지를 만든다.

## 입력값

서버의 `/var/www/home/ROOT/` 안에 두 파일이 있다:

| 파일 | 내용 |
|------|------|
| `data.html` | 날짜, 업타임, CPU%, 온도, 메모리, 디스크 — 맨 위에 최신 데이터가 쌓임 |
| `dockerstats.html` | Docker 컨테이너 5개의 현재 상태 (CPU, 메모리, 네트워크, 시작시간) |

## 출력물

`/var/www/home/ROOT/index.html` — 아래 두 섹션을 가진 단일 페이지:

1. **현황 패널** — 최신 시스템 지표 (항상 맨 위, 카드 형태)
2. **Docker 패널** — 컨테이너 5개의 상태 (테이블)
3. **히스토리 로그** — data.html의 과거 데이터 목록

## 기술 스택

- HTML + Tailwind CSS (CDN)
- 순수 JavaScript (fetch로 data.html / dockerstats.html 로드)
- 별도 빌드 없음 — 파일 하나로 동작

## 단계

1. `tools/check_temperature.sh` 출력 구조 분석 → 파싱 방법 확정
2. `tools/build_dashboard.sh` 작성 — index.html 생성 스크립트
3. 서버의 cron에 등록 (check_temperature.sh 직후 실행)
4. 브라우저에서 확인

## 문제가 생겼을 때

- **파싱 깨짐**: `data.html` 샘플을 `.tmp/`에 복사한 뒤 파싱 로직 검증
- **Docker 컨테이너 수 변동**: 스크립트가 고정 컬럼(14개씩)으로 파싱 중 — 컨테이너 수 바뀌면 `check_temperature.sh` 수정 필요
- **cron 등록 오류**: 미니서버에서 `crontab -l`로 현재 등록 상태 확인

## 현재 상태

- [ ] check_temperature.sh 출력 구조 분석 완료
- [ ] dashboard HTML 설계
- [ ] build_dashboard.sh 작성
- [ ] 서버 배포 및 cron 등록

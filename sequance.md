#### ② 핵심 시퀀스 흐름 (자동 자리 비움 감지, 사전 예고 및 예외 처리)

```mermaid
sequenceDiagram
    autonumber
    participant Sensor as SensorFilterUnit
    participant Timer as OccupancyTimerUnit
    participant Power as PowerActuatorUnit
    participant Comm as CommLogManagerUnit
    participant Admin as Admin Dashboard

    Note over Sensor, Timer: 현재 좌석 상태: 착석 중 (SEATED, 전원 ON)

    loop 1초 주기 센서 폴링 및 노이즈 필터링 (REQ-01, REQ-21)
        Sensor->>Sensor: readFilteredDistance()
        Sensor->>Timer: updateOccupancy(filteredDistance > 50cm)
        Timer->>Timer: absentSec++ (미감지 시간 누적)
    end

    rect rgb(255, 248, 225)
        Note over Timer, Power: 미감지 55분(3,300초) 경과 - 차단 5분 전 예고 (REQ-09)
        Timer->>Timer: currentState = PRE_WARNED
        Timer->>Power: executeActuatorCommand(BLINK_LAMP_3, NORMAL)
        Power-->>Timer: 점멸 완료 (3회)
        Timer->>Comm: sendStatusLog(deskNo, "PRE_WARNING")
        Comm->>Admin: 실시간 상태 로그 전송 (차단 예고)
    end

    alt 5분 이내 사용자 재감지 시 (차단 취소 분기)
        Sensor->>Timer: updateOccupancy(filteredDistance <= 50cm)
        Timer->>Timer: absentSec = 0, currentState = SEATED
        Timer->>Comm: sendStatusLog(deskNo, "WARNING_CANCELED")
        Comm->>Admin: 실시간 상태 로그 전송 (착석 유지)
    else 미감지 60분(3,600초) 경과 시 (자동 자리 비움 확정 - REQ-03, REQ-08)
        Sensor->>Timer: updateOccupancy(filteredDistance > 50cm)
        Timer->>Timer: currentState = AUTO_AWAY
        Timer->>Power: executeActuatorCommand(POWER_OFF, NORMAL)
        Power->>Power: SSR 릴레이(220V) 및 스탠드 조명 OFF
        Power-->>Timer: 전원 차단 완료 (TRUE)
        Timer->>Comm: saveStateToNVM(AUTO_AWAY, power=OFF)
        Comm->>Admin: sendStatusLog(deskNo, "AUTO_AWAY_POWER_OFF")
    end

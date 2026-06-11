# 🚀 온디바이스 AI 시스템 반도체설계 1기 - 다중 센서 및 타이머 통합 제어 시스템 설계

본 프로젝트는 FPGA 기반 **센서(HC-SR04, DHT11) 데이터 측정과 타이머 기능(시계, 스톱워치)을 통합 제어하는 디지털 논리 회로 시스템 설계 포트폴리오**입니다.
<div align="center">
  <img src="images/스크린샷%202026-06-04%20193015.png" width="100%" alt="Project Title Cover">
</div>
<br/>
FPGA 하드웨어 플랫폼 상에서 원시 펄스 신호를 수집하여 디지털 수치로 변환하고, UART 통신을 기반으로 직렬 데이터를 송수신하여 측정된 데이터 및 타이머 기능을 통합 제어합니다. 모듈화된 계층 구조(Top-down) 방식을 통해 제어, 통신, 데이터 처리, 디스플레이의 4단계 계층으로 전체 시스템 시나리오를 구성하였습니다.

* **교육 과정:** 온디바이스 AI 시스템 반도체설계 1기
* **참여 인원:** 전정묵
* **설계 및 검증 언어:** Verilog HDL
* **개발 환경 및 주요 툴:** RTL 기반 회로 설계 및 Simulation 검증 툴, FPGA 플랫폼

<br/>

## 📑 목차 (Table of Contents)
1. [🏗️ Project Architecture (전체 시스템 구조)](#1-️-project-architecture-전체-시스템-구조)
2. [📡 Communication Module (통신부 제어)](#2--communication-module-통신부-제어)
3. [🎛️ Control & Interface (제어 및 입력부)](#3-️-control--interface-제어-및-입력부)
4. [⏱️ Timer Datapath (데이터 처리부: 시계 및 스톱워치)](#4-️-timer-datapath-데이터-처리부-시계-및-스톱워치)
5. [🌡️ Sensor Datapath (데이터 처리부: SR04 & DHT11)](#5-️-sensor-datapath-데이터-처리부-sr04--dht11)
6. [💡 Display Control (디스플레이 출력부)](#6--display-control-디스플레이-출력부)
7. [🛠️ Troubleshooting & Debugging (결론 및 고찰)](#7-️-troubleshooting--debugging-결론-및-고찰)

<hr/>

## 1. 🏗️ Project Architecture (전체 시스템 구조)

<div align="center">
  <img src="images/스크린샷%202026-06-04%20193026.png" width="85%" alt="System Architecture">
  <p><em>Figure 1. System Hierarchy 및 최상위 계층도(Top Module) 구성</em></p>
</div>

**[시스템 블록도 상세 설명]**
전체 시스템은 **`Top_Module`**을 최상위 계층으로 두고 기능별로 **통신부(Comm), 제어부(Control), 데이터 처리부(Datapath), 디스플레이부(Display)**의 4가지 주요 계층으로 모듈화되어 있습니다. 
하위 계층 블록들의 입출력 포트를 연결하고 전역 클럭(Clock) 및 리셋(Reset) 분배 네트워크를 구축하여 모듈 간의 유기적인 연동과 타이밍 동기화를 달성하였습니다.

<br/>

## 2. 📡 Communication Module (통신부 제어)

<div align="center">
  <img src="images/스크린샷%202026-06-04%20193015.png" width="85%" alt="UART TX/RX FSM">
  <p><em>Figure 2. UART 송수신 제어부(UART_TX / UART_RX) 상태 머신 설계</em></p>
</div>

**[UART 송수신 제어 및 직렬화]**
* **동작 원리:** 내부 데이터 버스에 존재하는 병렬(Parallel) 데이터를 UART 비동기 프로토콜 규격에 맞추어 직렬(Serial) 신호로 변환 송수신하는 핵심 모듈입니다.
* **설계 기법:** 정해진 보드레이트(Baud Rate)에 맞추어 시스템 클럭을 분주하며, 수신(RX) 모듈은 하강 에지(Falling Edge) 감지 이후 오버샘플링 로직을 통해 노이즈로 인한 데이터 왜곡을 방지합니다.

<br/>

<div align="center">
  <img src="images/스크린샷%202026-06-04%20193026.png" width="85%" alt="FIFO and ASCII Sender">
  <p><em>Figure 3. 비동기 데이터 버퍼(FIFO) 및 ASCII 처리기(ASCII_Sender)</em></p>
</div>

**[비동기 버퍼 및 문자 인코딩]**
* **동작 원리:** 송수신부 간의 처리 속도 불일치로 인한 데이터 유실을 막기 위해 **FIFO(First-In-First-Out) 메모리 버퍼 큐**를 설계 및 적용하였습니다.
* **ASCII 변환 로직:** 하위의 `ASCII_Sender` 블록은 이진(Binary) 데이터를 BCD 형태로 전환한 뒤 UART 송신기를 통해 출력 가능한 ASCII 문자 배열 시퀀스로 변환합니다. `IDLE` -> `CALC_10` -> `WAIT_TX` -> `NEXT_CHAR`의 순차적인 FSM 흐름을 통제합니다.

<br/>

## 3. 🎛️ Control & Interface (제어 및 입력부)

<div align="center">
  <img src="images/스크린샷%202026-06-04%20193037.png" width="85%" alt="Debouncing Circuit">
  <p><em>Figure 4. 사용자 스위치 입력 제어 및 디바운싱(Debouncing) 회로</em></p>
</div>

**[채터링 방지 및 입력 동기화]**
* **문제 현상 필터링:** 물리적인 스위치 접점에서 발생하는 기계적 진동(Chattering) 및 노이즈 현상을 억제하기 위해 **디바운싱(Debouncing) 제어기(`Btn_avg_controller`)**를 설계하였습니다.
* **설계 기법:** D-플립플롭 체인 및 에지 검출기(Edge Trigger)를 활용하여 클럭 동기화된 상태가 일정 기간 유지될 때만 유효 신호로 판정하며, 중복된 모드 전환 현상을 원천 차단합니다.

<br/>

## 4. ⏱️ Timer Datapath (데이터 처리부: 시계 및 스톱워치)

<div align="center">
  <img src="images/스크린샷%202026-06-04%20193045.png" width="85%" alt="Timer Datapath">
  <p><em>Figure 5. 시계(Watch) 및 스톱워치(Stopwatch) 데이터패스 설계 구조</em></p>
</div>

**[타이머 연산 논리 구조]**
* **설계 방식:** 100MHz 기반의 메인 클럭을 10ms 단위 및 1초 단위 펄스로 분주(Clock Division)하여 카운터 구동 신호로 사용합니다. 멀티플렉서(MUX) 및 순차 카운터 조합 회로를 통해 밀리초, 초, 분 단위의 정밀한 누적 카운팅 로직을 구현하였습니다.

<div align="center">
  <img src="images/스크린샷%202026-06-04%20193054.png" width="85%" alt="Timer Simulation">
  <p><em>Figure 6. 타이머(Stopwatch / Watch) RTL 시뮬레이션 및 검증 파형</em></p>
</div>

* **검증 결과:** 스톱워치 모듈에 Start, Stop, Reset 신호를 인가하여 내부 플립플롭이 클럭 주기에 맞춰 정확히 누적 증가하는지 검증하였습니다. 특히, 59초에서 0초로 롤오버(Rollover)되는 오버플로우 상태의 천이 타이밍 무결성을 엄격하게 확인하였습니다.

<br/>

## 5. 🌡️ Sensor Datapath (데이터 처리부: SR04 & DHT11)

<div align="center">
  <img src="images/스크린샷%202026-06-04%20193100.png" width="85%" alt="HC-SR04 Controller">
  <p><em>Figure 7. 초음파 거리 측정 센서(HC-SR04) 제어 로직 및 FSM</em></p>
</div>

**[HC-SR04 거리 데이터 처리]**
* **동작 원리:** 규격에 맞는 트리거(Trigger) 펄스를 생성해 송출한 후, 반사되어 돌아오는 에코(Echo) 신호의 펄스 폭 사이클을 측정합니다.
* **설계 기법:** 측정된 펄스 폭을 내부 하드웨어 산술 연산(음속 340m/s 반영)을 거쳐 최종적인 물리적 거리(cm) 데이터로 도출하는 트리거-에코 기반 FSM 로직을 구축하였습니다.

<div align="center">
  <img src="images/스크린샷%202026-06-04%20193107.png" width="85%" alt="DHT11 Controller">
  <p><em>Figure 8. 온습도 데이터 획득 센서(DHT11) 1-Wire 제어 로직</em></p>
</div>

**[DHT11 온습도 데이터 처리]**
* **동작 원리:** 단일 데이터 핀(dhtio)과 Tri-state 버퍼를 활용한 **1-Wire 프로토콜 양방향(Inout) 인터페이스**를 구현하였습니다.
* **설계 기법:** 센서로부터 입력되는 40비트의 직렬 신호를 클럭 카운터로 정밀 측정하여 논리 '0'(28µs)과 '1'(70µs)을 판별합니다. 이후 시프트 레지스터 구조를 통해 병렬 데이터로 변환하고 체크섬(Checksum) 정합성을 검증합니다.

<br/>

## 6. 💡 Display Control (디스플레이 출력부)

<div align="center">
  <img src="images/스크린샷%202026-06-04%20193120.png" width="80%" alt="BCD to FND Decoder">
  <p><em>Figure 9. BCD to 7-Segment(FND) 디코더 다중화 회로</em></p>
</div>

**[BCD 투 FND 디코더 제어]**
* **동작 원리:** 데이터 처리부로부터 전달받은 BCD(Binary-Coded Decimal) 포맷 데이터를 하드웨어 7-Segment 디스플레이의 개별 LED를 구동하기 위한 8비트 패턴으로 변환합니다.
* **설계 기법:** 시스템 모드 선택 스위치 입력에 따라 현재 출력할 데이터(거리, 온도, 시간 등)를 선택적으로 화면에 스위칭하는 **다중화기(Multiplexer) 조합 논리 회로**로 구현되었습니다.

<br/>

## 7. 🛠️ Troubleshooting & Debugging (결론 및 고찰)

하드웨어 로직 합성(Synthesis) 및 모듈 통합 과정에서 발생한 두 가지 주요 타이밍 결함을 식별하고 정석적인 하드웨어 아키텍처 설계 기법으로 PPA(Power, Performance, Area)를 최적화하였습니다.

### Issue 1. ASCII_Sender Area & Timing Optimization (타이밍 클로저 확보)
<div align="center">
  <img src="images/스크린샷%202026-06-04%20193131.png" width="85%" alt="ASCII Sender Timing Optimization">
  <p><em>Figure 10. ASCII_Sender 논리 합성 후 타이밍 클로저 및 PPA 개선 디버깅</em></p>
</div>

* **문제 현상:** `ASCII_Sender` 데이터 처리 경로 내부에 나눗셈(`/`) 및 나머지(`%`) 연산자를 직접 사용함에 따라 논리 단계(Logic Depth)가 과도하게 길어짐. 이로 인해 Setup Time 위반(Worst Negative Slack -2.86ns) 현상이 발생하고 대량의 LUT 리소스가 낭비됨.
* **해결 방안:** 단일 클럭 사이클 내에서 이뤄지는 복잡한 나눗셈 로직을 제거하고, 상태 머신 상에서 여러 사이클에 걸쳐 수행되는 **순차적 뺄셈 기반 알고리즘**으로 구조를 전면 재설계함.
* **개선 결과:** Worst Negative Slack이 양수(+0.167ns)로 전환되어 타이밍 요구 조건을 충족(Timing Closure)하였으며, 합성 면적(LUT)을 대폭 절감시켜 안정적인 Area/Delay Trade-off 검증을 완료함.

### Issue 2. DHT11 Receiver Architecture Analysis (Shift Register vs MUX)
<div align="center">
  <img src="images/스크린샷%202026-06-04%20193148.png" width="85%" alt="DHT11 Shift Register vs MUX">
  <p><em>Figure 11. DHT-11 데이터 수신 구조 개선 (Shift Register vs MUX 방식 비교)</em></p>
</div>

* **분석 목적:** DHT11 센서로부터 연속 수신되는 40비트의 직렬 데이터를 내부 병렬 레지스터에 저장할 때, 데이터 할당 방식에 따른 하드웨어 면적(LUT) 및 타이밍 성능(WNS) 상관관계를 분석함.
* **접근 1 (MUX 방식):** 카운터 값에 따라 MUX를 활용하여 특정 주소 인덱스에 데이터를 직접 할당. 매 비트마다 디코딩 및 선택 논리가 필요하여 회로가 복잡해지고, 자원 소모 증가 및 지연 시간(WNS 감소)이 발생함.
* **접근 2 (Shift Register 방식):** 새로운 비트가 입력될 때마다 기존 데이터를 시프트하여 40개의 D-F/F을 직렬 연결하는 구조. 배선(Routing) 경로가 단순화되어 부가적인 제어 논리가 대폭 감소함.
* **결론 도출:** 다량의 직렬 데이터 수신 RTL 설계 시, MUX 기반 직접 지정 방식보다 **Shift Register 구조를 채택하는 것**이 데이터패스 지연을 최소화하고 자원 소모를 방지하는 실무적이고 정석적인 아키텍처임을 논리 합성을 통해 실증함.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ReadingRoomScreen(roomName: "(중)제1열람실(지하)"),
    );
  }
}

class ReadingRoomScreen extends StatefulWidget {
  final String roomName;

  const ReadingRoomScreen({super.key, required this.roomName});

  @override
  State<ReadingRoomScreen> createState() => _ReadingRoomScreenState();
}

class _ReadingRoomScreenState extends State<ReadingRoomScreen> {
  List<Map<String, dynamic>> seatPositions = [];
  Set<int> reservedSeats = {};  // 예약된 좌석 저장
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSeats();
  }

  Future<void> loadSeats() async {
    String data = await rootBundle.loadString('assets/seats.json');
    final jsonResult = json.decode(data);
    setState(() {
      seatPositions = List<Map<String, dynamic>>.from(jsonResult['seats']);
      isLoading = false;
    });
  }

  void _reserveSeat(int seatNumber) {
    if (reservedSeats.contains(seatNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$seatNumber번 좌석은 이미 예약됨')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("좌석 예약"),
        content: Text("$seatNumber번 좌석을 예약하시겠습니까?"),
        actions: [
          TextButton(
            child: const Text("취소"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("예약"),
            onPressed: () {
              setState(() {
                reservedSeats.add(seatNumber);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$seatNumber번 좌석 예약 완료')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final seatController = TextEditingController();
    final etcController = TextEditingController();
    int selectedReasonIndex = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("신고하기"),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: seatController,
                            decoration: const InputDecoration(
                              hintText: "좌석 번호 :",
                              filled: true,
                              fillColor: Colors.white70,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("신고가 전송되었습니다.")));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff88A6DE)),
                          child: const Text("전송"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...["지정된 좌석이 아닌 곳에 앉아 있습니다.", "소음을 유발합니다.", "코를 곱니다.", "기타 사항"].asMap().entries.map((entry) {
                      final index = entry.key;
                      final text = entry.value;
                      return RadioListTile(
                        title: Text(text),
                        value: index,
                        groupValue: selectedReasonIndex,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() {
                            selectedReasonIndex = val!;
                          });
                        },
                      );
                    }).toList(),
                    if (selectedReasonIndex == 3)
                      TextField(
                        controller: etcController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "기타 사유를 입력해주세요",
                          border: OutlineInputBorder(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName, style: const TextStyle(fontSize: 25)),
        centerTitle: true,
        backgroundColor: const Color(0xff88A6DE),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            InteractiveViewer(
              child: Container(
                width: 2000,
                height: 1500,
                child: Stack(
                  children: seatPositions.map((seat) {
                    int seatNumber = seat["number"];
                    bool isReserved = reservedSeats.contains(seatNumber);
                    return Positioned(
                      left: seat["x"],
                      top: seat["y"],
                      child: GestureDetector(
                        onTap: () => _reserveSeat(seatNumber),
                        child: SeatWidget(
                          seatNumber: seatNumber,
                          isReserved: isReserved,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showReportDialog(context);
                },
                backgroundColor: const Color(0xff88A6DE),
                label: const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text("신고하기", style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SeatWidget extends StatelessWidget {
  final int seatNumber;
  final bool isReserved;

  const SeatWidget({super.key, required this.seatNumber, required this.isReserved});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isReserved ? Colors.red : Colors.lightBlueAccent,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        seatNumber.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
//주파수 감소기 x
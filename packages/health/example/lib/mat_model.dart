import 'dart:math';

int get_general_state(var messageGot) {
  for (int i = 0; i < 3; i++) {
    if (messageGot[i] == []) {
      return 0;
    }
  }

  var codeReceived = model(messageGot);
  // STATUS_HIGH_BPM = 0
  // STATUS_LOW_BPM = 1
  // STATUS_JUMP_BPM = 2
  // STATUS_HIGH_SLEEP = 3
  // STATUS_LOW_SLEEP = 4
  // STATUS_LOW_STEPS = 5
  List<String> message = [];
  if (codeReceived[0] == 1) message.add("У Вас высокий пульс");
  if (codeReceived[1] == 1) message.add("У Вас низкий пульс");
  if (codeReceived[2] == 1) message.add("У Вас сильное отличие пульса");
  if (codeReceived[3] == 1) message.add("У Вас избыточный сон");
  if (codeReceived[4] == 1) message.add("У Вас недостаточный сон");
  if (codeReceived[5] == 1) message.add("У Вас недостаточное количество шагов");
  print(message);
  print((100-25* codeReceived[0]-30 * codeReceived[1]-40*codeReceived[2]-20*codeReceived[3]-40*codeReceived[4]-15*codeReceived[5]).toInt());
  int res = max(10, (100-25* codeReceived[0]-30 * codeReceived[1]-40*codeReceived[2]-20*codeReceived[3]-40*codeReceived[4]-15*codeReceived[5]).toInt());
  print(res);
  return res;
}

List<double> model(List<List<double>> messageGot) {
  List<double> pulse = messageGot[0];
  List<double> sleepTime = messageGot[1];
  List<double> steps = messageGot[2];
  double avgPulse = pulse.reduce((a, b) => a + b) / pulse.length;
  double avgSleep = sleepTime.reduce((a, b) => a + b) / sleepTime.length;
  double avgSteps = steps.reduce((a, b) => a + b) / steps.length;
  List<double> dispersionsOfPulse = [];

  // b_000000 ^ (1 << 2) = b_000100
  List<double> messageOut = [0, 0, 0, 0, 0, 0];

  if (avgPulse > 90) messageOut[0] = 1;
  if (avgPulse < 55) messageOut[1] = 1;

  if (avgSleep > 10) messageOut[3] = 1;
  if (avgSleep < 5) messageOut[4] = 1;

  if (avgSteps < 5000) messageOut[5] = 1;

  for (var i = 0; i < pulse.length; i += 10) {
    var sublist = pulse.sublist(i, min(i + 10, pulse.length));
    dispersionsOfPulse.add(_variance(sublist));
  }

  if (dispersionsOfPulse.reduce(max) >= 20) {
    messageOut[2] = 1;
  }

  dispersionsOfPulse.clear();
  return messageOut;
}

double _variance(List<double> numbers) {
  var mean = numbers.reduce((a, b) => a + b) / numbers.length;
  var variance = numbers.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / numbers.length;
  return variance;
}
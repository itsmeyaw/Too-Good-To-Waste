import 'package:json_annotation/json_annotation.dart';

part 'pickup_process.g.dart';

@JsonSerializable(explicitToJson: true)
class PickupProcess {
  @JsonKey(includeToJson: false)
  String? id;

  final String receiver;
  final String giver;
  final String sharedItemId;
  bool isActive;

  PickupProcess(
      {required this.receiver,
      required this.giver,
      required this.sharedItemId,
      this.isActive = true});

  factory PickupProcess.fromJson(Map<String, dynamic> json) =>
      _$PickupProcessFromJson(json);

  Map<String, dynamic> toJson() => _$PickupProcessToJson(this);
}

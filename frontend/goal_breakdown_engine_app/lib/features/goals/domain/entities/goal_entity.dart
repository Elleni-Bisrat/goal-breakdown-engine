import 'package:equatable/equatable.dart';

class GoalEntity extends Equatable {
  const GoalEntity({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
  });

  final String id;
  final String title;
  final String? description;
  final int duration;

  @override
  List<Object?> get props => [id, title, description, duration];
}

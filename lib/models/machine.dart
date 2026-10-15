enum MachineStatus { free, occupied, openForAlternates }

class Machine {
  const Machine({
    required this.name,
    required this.id,
    required this.status,
    required this.floor,
    required this.asset,
  });

  final String name;
  final String id;
  final MachineStatus status;
  final String floor;
  final String asset;

  bool get isOccupied => status == MachineStatus.occupied;
  bool get supportsAlternating => status == MachineStatus.openForAlternates;
}

const nearbyMachines = [
  Machine(
    name: 'Lat Pulldown',
    id: 'SR-LP-014',
    status: MachineStatus.free,
    floor: 'Floor 01',
    asset: 'assets/images/weightlifting_machine_flaticons/lat-pulldown.png',
  ),
  Machine(
    name: 'Low Row',
    id: 'SR-LR-008',
    status: MachineStatus.occupied,
    floor: 'Floor 01',
    asset: 'assets/images/weightlifting_machine_flaticons/low-row.png',
  ),
  Machine(
    name: 'Chest Press',
    id: 'SR-CP-021',
    status: MachineStatus.openForAlternates,
    floor: 'Floor 01',
    asset: 'assets/images/weightlifting_machine_flaticons/chest-press.png',
  ),
  Machine(
    name: 'Leg Press',
    id: 'SR-LG-006',
    status: MachineStatus.free,
    floor: 'Floor 02',
    asset: 'assets/images/weightlifting_machine_flaticons/leg-press.png',
  ),
];
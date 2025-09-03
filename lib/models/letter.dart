class Letter {
  int? id;
  String type; // 'Masuk' atau 'Keluar'
  String noSurat;
  String dariAtauKepada;
  String perihal;
  String tanggal;

  Letter({
    this.id,
    required this.type,
    required this.noSurat,
    required this.dariAtauKepada,
    required this.perihal,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'noSurat': noSurat,
      'dariAtauKepada': dariAtauKepada,
      'perihal': perihal,
      'tanggal': tanggal,
    };
  }

  factory Letter.fromMap(Map<String, dynamic> map) {
    return Letter(
      id: map['id'],
      type: map['type'],
      noSurat: map['noSurat'],
      dariAtauKepada: map['dariAtauKepada'],
      perihal: map['perihal'],
      tanggal: map['tanggal'],
    );
  }
}

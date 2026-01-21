class SurgeryData {
  String dateOfSurgery;
  String ageSex;
  String surgery;
  String surgeon;
  String speciality;
  String patientName;
  String specialRequest;
  String mrdNumber; // UHID

  SurgeryData({
    required this.dateOfSurgery,
    required this.ageSex,
    required this.surgery,
    required this.surgeon,
    required this.speciality,
    required this.patientName,
    required this.specialRequest,
    required this.mrdNumber,
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safestreet/models/reports.dart';

const String Reports_Collection_Ref = "reports";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _reportsRef;

  DatabaseService() {
    _reportsRef = _firestore
        .collection(Reports_Collection_Ref)
        .withConverter<Reports>(
            fromFirestore: (snapshots, _) =>
                Reports.fromJson(snapshots.data()!),
            toFirestore: (reports, _) => reports.toJson());
  }

  Stream<QuerySnapshot> getReports() {
    return _reportsRef.snapshots();
  }

  void addReport(Reports report) async {
    _reportsRef.add(report);
  }
}

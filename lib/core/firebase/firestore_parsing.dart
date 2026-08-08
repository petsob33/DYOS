import 'package:cloud_firestore/cloud_firestore.dart';

/// Maps [docs] through [fromFirestore], silently dropping documents that
/// fail to parse (e.g. a doc left over from an old schema) instead of
/// letting one bad document take down the whole list.
List<T> parseFirestoreDocs<T>(
  List<QueryDocumentSnapshot> docs,
  T Function(QueryDocumentSnapshot doc) fromFirestore,
) {
  return docs
      .map((doc) {
        try {
          return fromFirestore(doc);
        } catch (e) {
          return null;
        }
      })
      .whereType<T>()
      .toList();
}

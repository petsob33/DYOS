import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/domain/couple_model.dart';
import '../../features/auth/domain/user_model.dart';
import 'pairing_exceptions.dart';

class PairingService {
  PairingService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _auth = auth,
        _firestore = firestore,
        _functions = functions;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  User? get currentUser => _auth.currentUser;

  String generateInviteCode(String displayName) {
    // Keep only A-Z so code format matches backend validation.
    final cleaned = displayName.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final seed = cleaned.isEmpty ? 'USER' : cleaned;
    final prefix = seed.substring(0, seed.length > 4 ? 4 : seed.length);
    final normalizedPrefix = prefix.length >= 2 ? prefix : '${prefix}X';
    final random = Random();
    final number = random.nextInt(9000) + 1000;
    return '$normalizedPrefix-$number';
  }

  Future<UserModel?> findUserByInviteCode(String inviteCode) async {
    try {
      final callable = _functions.httpsCallable('getUserByInviteCode');
      final result = await callable.call({'inviteCode': inviteCode});
      final payload = result.data;
      if (payload == null) return null;
      final map = Map<String, dynamic>.from(payload as Map);
      return UserModel(
        uid: map['uid'] as String? ?? '',
        email: map['email'] as String? ?? '',
        displayName: map['displayName'] as String?,
        inviteCode: map['inviteCode'] as String?,
        coupleId: map['coupleId'] as String?,
      );
    } catch (e, st) {
      debugPrint('[PairingService] findUserByInviteCode error: $e\n$st');
      return null;
    }
  }

  Future<CoupleModel?> getCoupleData(String coupleId) async {
    try {
      final doc = await _firestore.collection('couples').doc(coupleId).get();
      if (!doc.exists) return null;
      return CoupleModel.fromFirestore(doc);
    } catch (e, st) {
      debugPrint('[PairingService] getCoupleData error (coupleId=$coupleId): $e\n$st');
      return null;
    }
  }

  Future<CoupleModel> pairUsers(String currentUserId, String partnerUserId) async {
    if (currentUserId == partnerUserId) {
      throw SelfPairingException();
    }

    final results = await Future.wait([
      _firestore.collection('users').doc(currentUserId).get(),
      _firestore.collection('users').doc(partnerUserId).get(),
    ]);

    final currentUserDoc = results[0];
    final partnerUserDoc = results[1];
    if (!currentUserDoc.exists) {
      throw UserNotFoundException();
    }
    if (!partnerUserDoc.exists) {
      throw PartnerNotFoundException();
    }

    final currentUser = UserModel.fromFirestore(currentUserDoc);
    final partnerUser = UserModel.fromFirestore(partnerUserDoc);

    if (currentUser.coupleId != null && currentUser.coupleId!.isNotEmpty) {
      throw UserAlreadyPairedException();
    }
    if (partnerUser.coupleId != null && partnerUser.coupleId!.isNotEmpty) {
      throw PartnerAlreadyPairedException();
    }

    final batch = _firestore.batch();
    final coupleId = 'couple_${DateTime.now().millisecondsSinceEpoch}';
    final coupleRef = _firestore.collection('couples').doc(coupleId);

    final statusMap = <String, CoupleStatus>{
      currentUserId: CoupleStatus(
        emoji: '😊',
        text: 'Ready to connect',
        updatedAt: DateTime.now(),
      ),
      partnerUserId: CoupleStatus(
        emoji: '😊',
        text: 'Ready to connect',
        updatedAt: DateTime.now(),
      ),
    };

    final couple = CoupleModel(
      id: coupleId,
      members: [currentUserId, partnerUserId],
      anniversaryDate: DateTime.now(),
      createdAt: DateTime.now(),
      subscriptionTier: 'free',
      subscriptionExpiry: null,
      status: statusMap,
    );

    batch.set(coupleRef, couple.toJson());
    batch.update(_firestore.collection('users').doc(currentUserId), {'coupleId': coupleId});
    batch.update(_firestore.collection('users').doc(partnerUserId), {'coupleId': coupleId});

    await batch.commit();
    return couple;
  }

  Future<PairInviteCodeResult> pairWithInviteCode(String inviteCode) async {
    debugPrint('[PairingService] pairWithInviteCode called with code: $inviteCode');

    final currentUser = _auth.currentUser;
    debugPrint('[PairingService] currentUser: ${currentUser?.uid ?? 'NULL'} (email=${currentUser?.email})');

    if (currentUser == null) {
      debugPrint('[PairingService] FAIL: currentUser is null — not authenticated');
      throw GenericPairingException('Please sign in again and retry pairing.');
    }

    final normalizedCode = inviteCode.trim().toUpperCase();
    debugPrint('[PairingService] normalizedCode: $normalizedCode');
    if (!RegExp(r'^[A-Z]{2,10}-\d{4}$').hasMatch(normalizedCode)) {
      debugPrint('[PairingService] FAIL: code format invalid');
      throw GenericPairingException('Invalid invite code format.');
    }

    try {
      debugPrint('[PairingService] refreshing ID token...');
      final token = await currentUser.getIdToken(true);
      debugPrint('[PairingService] token refreshed, length=${token?.length ?? 0}');

      try {
        final appCheckToken = await FirebaseAppCheck.instance.getToken();
        debugPrint('[PairingService] App Check token: ${appCheckToken == null ? "NULL (no token)" : "present, length=${appCheckToken.length}"}');
      } catch (appCheckError) {
        debugPrint('[PairingService] App Check getToken() threw: $appCheckError');
      }

      debugPrint('[PairingService] calling Cloud Function pairWithInviteCode...');
      final callable = _functions.httpsCallable('pairWithInviteCode');
      final result = await callable.call({'inviteCode': normalizedCode});
      debugPrint('[PairingService] function returned: ${result.data}');

      final data = Map<String, dynamic>.from(result.data as Map);
      return PairInviteCodeResult(
        coupleId: data['coupleId'] as String,
        partnerDisplayName: data['partnerDisplayName'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('[PairingService] FirebaseFunctionsException: code=${e.code} message=${e.message} details=${e.details}');
      switch (e.code) {
        case 'not-found':
          throw PartnerNotFoundException();
        case 'already-exists':
          final details = e.details as Map?;
          debugPrint('[PairingService] already-exists details: $details');
          if (details?['type'] == 'user_already_paired') {
            throw UserAlreadyPairedException();
          }
          throw PartnerAlreadyPairedException();
        case 'invalid-argument':
          if (e.message?.contains('yourself') == true) {
            throw SelfPairingException();
          }
          throw GenericPairingException(e.message ?? 'Invalid request.');
        case 'resource-exhausted':
          throw GenericPairingException('Too many attempts. Please try again later.');
        case 'unauthenticated':
          debugPrint('[PairingService] unauthenticated — token may have been invalid despite refresh');
          throw GenericPairingException('Please sign in again and retry pairing.');
        case 'failed-precondition':
          debugPrint('[PairingService] failed-precondition — likely App Check rejection');
          throw GenericPairingException('App verification failed. Please update the app and try again.');
        case 'internal':
          throw GenericPairingException(
            e.message != null && e.message!.isNotEmpty
                ? 'Server error: ${e.message}'
                : 'A server error occurred. Please try again.',
          );
        default:
          throw GenericPairingException('Unable to complete pairing (${e.code}): ${e.message ?? 'unknown error'}');
      }
    } on PairingException {
      rethrow;
    } catch (e, st) {
      debugPrint('[PairingService] unexpected error: ${e.runtimeType}: $e\n$st');
      throw GenericPairingException('Unable to complete pairing: ${e.toString()}');
    }
  }

  Future<PairInviteCodeResult> pairWithEmail(String email) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw GenericPairingException('Please sign in again and retry pairing.');
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail)) {
      throw GenericPairingException('Invalid email address.');
    }

    try {
      await currentUser.getIdToken(true);
      final callable = _functions.httpsCallable('pairWithEmail');
      final result = await callable.call({'email': normalizedEmail});
      final data = Map<String, dynamic>.from(result.data as Map);
      return PairInviteCodeResult(
        coupleId: data['coupleId'] as String,
        partnerDisplayName: data['partnerDisplayName'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      switch (e.code) {
        case 'not-found':
          throw PartnerNotFoundException();
        case 'already-exists':
          final details = e.details as Map?;
          if (details?['type'] == 'user_already_paired') throw UserAlreadyPairedException();
          throw PartnerAlreadyPairedException();
        case 'invalid-argument':
          if (e.message?.contains('yourself') == true) throw SelfPairingException();
          throw GenericPairingException(e.message ?? 'Invalid request.');
        case 'resource-exhausted':
          throw GenericPairingException('Too many attempts. Please try again later.');
        case 'unauthenticated':
          throw GenericPairingException('Please sign in again and retry pairing.');
        case 'failed-precondition':
          throw GenericPairingException('App verification failed. Please update the app and try again.');
        default:
          throw GenericPairingException('Unable to complete pairing (${e.code}): ${e.message ?? 'unknown error'}');
      }
    } on PairingException {
      rethrow;
    } catch (e) {
      throw GenericPairingException('Unable to complete pairing: ${e.toString()}');
    }
  }

  Future<bool> isUserPaired(Future<UserModel?> Function() getUserData) async {
    final userData = await getUserData();
    return userData?.coupleId != null && userData!.coupleId!.isNotEmpty;
  }

  Future<UserModel?> getPartner({
    required Future<UserModel?> Function() getUserData,
    required Future<CoupleModel?> Function(String coupleId) getCoupleData,
  }) async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final userData = await getUserData();
      if (userData?.coupleId == null || userData!.coupleId!.isEmpty) {
        return null;
      }

      final couple = await getCoupleData(userData.coupleId!);
      if (couple == null) return null;

      final partnerUid = couple.members.firstWhere(
        (uid) => uid != user.uid,
        orElse: () => '',
      );
      if (partnerUid.isEmpty) return null;

      final partnerDoc = await _firestore.collection('users').doc(partnerUid).get();
      if (!partnerDoc.exists) return null;

      return UserModel.fromFirestore(partnerDoc);
    } catch (e, st) {
      debugPrint('[PairingService] getPartner error: $e\n$st');
      return null;
    }
  }
}


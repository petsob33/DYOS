import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/auth_service.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';
import '../domain/couple_model.dart';

part 'auth_providers.g.dart';

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

@riverpod
Stream<User?> auth(AuthRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
}

@riverpod
Stream<UserModel?> user(UserRef ref) {
  final firebaseUser = ref.watch(authStateProvider).valueOrNull;
  if (firebaseUser == null) {
    return Stream.value(null);
  }
  final userRepository = ref.read(userRepositoryProvider);
  return userRepository.streamUser(firebaseUser.uid);
}

@riverpod
Stream<bool?> isUserPaired(IsUserPairedRef ref) {
  return ref.watch(userProvider.stream).map((user) {
    if (user == null) return null;
    return user.coupleId != null && user.coupleId!.isNotEmpty;
  });
}

@riverpod
Stream<CoupleModel?> currentCouple(CurrentCoupleRef ref) {
  // Use AsyncValue directly so we always get the current user value,
  // even if it was emitted before this provider was first built.
  // .stream is a broadcast stream and doesn't replay past emissions —
  // using switchMap on it causes a stuck-loading bug on login.
  final coupleId = ref.watch(userProvider).valueOrNull?.coupleId;
  if (coupleId == null || coupleId.isEmpty) {
    return Stream.value(null);
  }
  return FirebaseFirestore.instance
      .collection('couples')
      .doc(coupleId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    try {
      return CoupleModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error parsing couple data: $e');
      return null;
    }
  });
}

@riverpod
Stream<UserModel?> currentUserData(CurrentUserDataRef ref) {
  // Rebuild from auth state directly rather than re-wrapping userProvider.stream,
  // which is a broadcast stream that doesn't replay already-emitted values.
  final firebaseUser = ref.watch(authStateProvider).valueOrNull;
  if (firebaseUser == null) return Stream.value(null);
  return ref.read(userRepositoryProvider).streamUser(firebaseUser.uid);
}

@riverpod
Stream<UserModel?> partner(PartnerRef ref) {
  final couple = ref.watch(currentCoupleProvider).valueOrNull;
  if (couple == null) return Stream.value(null);
  final firebaseUser = ref.watch(currentUserProvider);
  if (firebaseUser == null) return Stream.value(null);
  final partnerUid = couple.members.firstWhere(
    (uid) => uid != firebaseUser.uid,
    orElse: () => '',
  );
  if (partnerUid.isEmpty) return Stream.value(null);
  return ref.read(userRepositoryProvider).streamUser(partnerUid);
}

@riverpod
Stream<CoupleModel?> couple(CoupleRef ref) {
  // Read the AsyncValue directly rather than re-wrapping currentCoupleProvider.stream,
  // which is a broadcast stream that doesn't replay an already-emitted value to a
  // late subscriber - see the comment on currentCouple above. Without this, XP
  // (and anything else built on this provider) could get stuck showing 0 until
  // the couple document happened to receive another write.
  return Stream.value(ref.watch(currentCoupleProvider).valueOrNull);
}

@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) {
  return SharedPreferences.getInstance();
}

@riverpod
Future<bool> hasSeenTutorial(HasSeenTutorialRef ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getBool('has_seen_tutorial') ?? false;
}

final pairingConfirmedCoupleIdProvider = StateProvider<String?>((ref) => null);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
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
  return ref.watch(userProvider.stream).switchMap((user) {
    if (user?.coupleId == null || user!.coupleId!.isEmpty) {
      return Stream.value(null);
    }
    final firestore = FirebaseFirestore.instance;
    return firestore
        .collection('couples')
        .doc(user.coupleId!)
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
  });
}

@riverpod
Stream<UserModel?> currentUserData(CurrentUserDataRef ref) {
  return ref.watch(userProvider.stream);
}

@riverpod
Stream<UserModel?> partner(PartnerRef ref) {
  return ref.watch(currentCoupleProvider.stream).switchMap((couple) {
    if (couple == null) {
      return Stream.value(null);
    }
    final firebaseUser = ref.watch(currentUserProvider);
    if (firebaseUser == null) {
      return Stream.value(null);
    }
    final partnerUid = couple.members.firstWhere(
      (uid) => uid != firebaseUser.uid,
      orElse: () => '',
    );
    if (partnerUid.isEmpty) {
      return Stream.value(null);
    }
    final userRepository = ref.read(userRepositoryProvider);
    return userRepository.streamUser(partnerUid);
  });
}

@riverpod
Stream<CoupleModel?> couple(CoupleRef ref) {
  return ref.watch(currentCoupleProvider.stream);
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

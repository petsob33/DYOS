import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
Future<bool?> isUserPaired(IsUserPairedRef ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);

  final user = firebaseService.currentUser;
  if (user == null) {
    return null;
  }

  try {
    final isPaired = await firebaseService.isUserPaired();
    return isPaired;
  } catch (e) {
    return false;
  }
}

@riverpod
Future<CoupleModel?> currentCouple(CurrentCoupleRef ref) async {
  // Depend on the currentUserData provider to get the user's data
  final userData = await ref.watch(currentUserDataProvider.future);
  
  if (userData?.coupleId == null || userData!.coupleId!.isEmpty) {
    return null;
  }
  
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.getCoupleData(userData.coupleId!);
}

@riverpod
Stream<UserModel?> partner(PartnerRef ref) async* {
  final coupleAsync = ref.watch(coupleProvider);

  final couple = coupleAsync.valueOrNull;
  if (couple == null) {
    yield null;
    return;
  }

  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield null;
    return;
  }

  final partnerUid = couple.members.firstWhere(
    (uid) => uid != user.uid,
    orElse: () => '',
  );

  if (partnerUid.isEmpty) {
    yield null;
    return;
  }

  final userRepository = ref.watch(userRepositoryProvider);
  yield await userRepository.getUserById(partnerUid);
}

@riverpod
Future<UserModel?> currentUserData(CurrentUserDataRef ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.getUserData();
}

@riverpod
Stream<UserModel?> user(UserRef ref) {
  return ref.watch(authStateProvider.stream).asyncExpand((firebaseUser) {
    if (firebaseUser == null) {
      return Stream<UserModel?>.value(null);
    }
    
    final userRepository = ref.read(userRepositoryProvider);
    return userRepository.streamUser(firebaseUser.uid);
  });
}

@riverpod
Stream<CoupleModel?> couple(CoupleRef ref) {
  return ref.watch(userProvider).when(
    data: (user) {
      if (user?.coupleId == null || user!.coupleId!.isEmpty) {
        return Stream<CoupleModel?>.value(null);
      }
      
      final firestore = FirebaseFirestore.instance;
      return firestore
          .collection('couples')
          .doc(user.coupleId!)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          debugPrint('Couple document ${user.coupleId} does not exist');
          return null;
        }
        try {
          final couple = CoupleModel.fromFirestore(doc);
          debugPrint('Successfully loaded couple ${couple.id} with ${couple.members.length} members');
          return couple;
        } catch (e, stackTrace) {
          debugPrint('Error loading couple data from stream for coupleId ${user.coupleId}: $e');
          debugPrint('Stack trace: $stackTrace');
          debugPrint('Document exists: ${doc.exists}, data: ${doc.data()}');
          return null;
        }
      });
    },
    loading: () => Stream<CoupleModel?>.value(null),
    error: (error, stackTrace) {
      debugPrint('Error in userProvider: $error');
      return Stream<CoupleModel?>.value(null);
    },
  );
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

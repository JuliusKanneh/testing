import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/core/failure.dart';
import 'package:twitter_clone/core/providers.dart';
import 'package:twitter_clone/core/type_def.dart';

abstract class IAuthAPI {
  FutureEither<User> signUp({
    required String email,
    required String password,
  });

  FutureEither<Session> login({
    required String email,
    required String password,
  });

  Future<User?> currentUserAccount();
}

///provides an instance of the AuthAPI in read-only mode
final authAPIProvider = Provider((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AuthAPI(account: account);
});

class AuthAPI implements IAuthAPI {
  final Account _account;
  AuthAPI({required Account account}) : _account = account;

  @override
  Future<User?> currentUserAccount() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  FutureEither<User> signUp(
      {required String email, required String password}) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return right(user);
    } on AppwriteException catch (e, stacktrace) {
      return left(
        Failure(e.message ?? 'Some expected error occured.', stacktrace),
      );
    } catch (e, stacktrace) {
      return left(Failure(e.toString(), stacktrace));
    }
  }

  @override
  FutureEither<Session> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _account.createEmailSession(
        email: email,
        password: password,
      );
      return right(session);
    } on AppwriteException catch (e, stacktrace) {
      return left(
        Failure(e.message ?? 'Some expected error occured.', stacktrace),
      );
    } catch (e, stacktrace) {
      return left(Failure(e.toString(), stacktrace));
    }
  }
}

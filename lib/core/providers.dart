import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';

final appwriteClientProvider = Provider((ref) {
  Client client = Client();
  client
      .setEndpoint(AppwriteConstants.endpoint)
      .setProject(AppwriteConstants.projectId)
      .setSelfSigned(status: true);
  return client;
});

///ref is used to interact with other providers
final appwriteAccountProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

final appwriteDatabaseProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

final appwriteStorageprovider = Provider((ref) {
  return Storage(ref.watch(appwriteClientProvider));
});

///Note on when to create a provider: whenever what u want to provide is a dependency. 
///This helps with testing.
class SecurityService {
  // final LocalAuthentication auth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    return false; // Stub for Web
  }

  Future<bool> authenticate() async {
    print("DEBUG: SecurityService.authenticate called - Bypassing");
    // Security temporarily disabled for debugging/web compatibility
    return true;
  }
}

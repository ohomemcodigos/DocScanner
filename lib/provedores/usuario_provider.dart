import 'package:flutter/material.dart';

class UsuarioProvider extends ChangeNotifier {
  bool _isLogado = false;
  bool _carregando = false;
  
  String? _nome;
  String? _email;
  String? _fotoUrl;

  bool get isLogado => _isLogado;
  bool get carregando => _carregando;
  String? get nome => _nome;
  String? get email => _email;
  String? get fotoUrl => _fotoUrl;

  Future<void> loginComGoogle() async {
    _carregando = true;
    notifyListeners();

    try {
      // =========================================================
      // CÓDIGO REAL FUTURO DO GOOGLE SIGN-IN:
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // _nome = googleUser.displayName;
      // _email = googleUser.email;
      // _fotoUrl = googleUser.photoUrl;
      // =========================================================

      await Future.delayed(const Duration(seconds: 2));

      // Para testes
      _nome = "Usuário de Teste";
      _email = "usuario@docscanner.app";
      _fotoUrl = null; 
      _isLogado = true;

    } catch (e) {
      debugPrint("Erro no login: $e");
      _isLogado = false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> fazerLogout() async {
    _carregando = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    // No futuro: await GoogleSignIn().signOut();
    _isLogado = false;
    _nome = null;
    _email = null;
    _fotoUrl = null;
    
    _carregando = false;
    notifyListeners();
  }
}
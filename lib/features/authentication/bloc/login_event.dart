abstract class LoginEvent {
  const LoginEvent();
}

class LoginEmailChanged extends LoginEvent {
  final String email;
  const LoginEmailChanged(this.email);
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  const LoginPasswordChanged(this.password);
}

class LoginShowPasswordToggled extends LoginEvent {
  const LoginShowPasswordToggled();
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

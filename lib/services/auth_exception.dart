//login exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordFoundAuthException implements Exception {}

//register exceptions

class WeakPasswordFoundAuthException implements Exception {}

class EmailLAreadyInUserAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//Generic exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

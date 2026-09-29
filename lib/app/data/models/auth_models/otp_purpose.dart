/// `purpose` sent to the verify/resend OTP endpoints.
enum OtpPurpose {
  register('REGISTER'),
  forgotPassword('FORGOT_PASSWORD');

  const OtpPurpose(this.value);

  final String value;
}

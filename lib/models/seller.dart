class Seller {
  final String id;
  final String sellerName;
  final String email;
  final String businessName;
  final String businessAddress;
  final String phone;
  final String gstNumber;
  final String aadharNumber;
  final String selfieImage;
  final String aadharFrontImage;
  final String aadharBackImage;
  final String gstCertificateImage;
  // Use a string status so it can express more states (Pending, Approved, Rejected, etc.)
  final String approvalStatus;

  Seller({
    required this.id,
    required this.sellerName,
    required this.email,
    required this.businessName,
    required this.businessAddress,
    required this.phone,
    required this.gstNumber,
    required this.aadharNumber,
    required this.selfieImage,
    required this.aadharFrontImage,
    required this.aadharBackImage,
    required this.gstCertificateImage,
    this.approvalStatus = 'Pending',
  });

  // Convenience boolean for existing code that checks approval
  bool get isApproved => approvalStatus.toLowerCase() == 'approved';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerName': sellerName,
      'email': email,
      'businessName': businessName,
      'businessAddress': businessAddress,
      'phone': phone,
      'gstNumber': gstNumber,
      'aadharNumber': aadharNumber,
      'selfieImage': selfieImage,
      'aadharFrontImage': aadharFrontImage,
      'aadharBackImage': aadharBackImage,
      'gstCertificateImage': gstCertificateImage,
      // Use ApprovalStatus field in Firestore as requested
      'ApprovalStatus': approvalStatus,
    };
  }

  factory Seller.fromMap(Map<String, dynamic> map) {
    // Support both new 'ApprovalStatus' string and older boolean 'isApproved'
    String resolvedStatus = 'Pending';
    if (map.containsKey('ApprovalStatus') && map['ApprovalStatus'] != null) {
      resolvedStatus = (map['ApprovalStatus'] as String).toString();
    } else if (map.containsKey('isApproved')) {
      // older documents may have a boolean
      final val = map['isApproved'];
      if (val is bool) {
        resolvedStatus = val ? 'Approved' : 'Pending';
      }
    }

    return Seller(
      id: map['id'] ?? '',
      sellerName: map['sellerName'] ?? '',
      email: map['email'] ?? '',
      businessName: map['businessName'] ?? '',
      businessAddress: map['businessAddress'] ?? '',
      phone: map['phone'] ?? '',
      gstNumber: map['gstNumber'] ?? '',
      aadharNumber: map['aadharNumber'] ?? '',
      selfieImage: map['selfieImage'] ?? '',
      aadharFrontImage: map['aadharFrontImage'] ?? '',
      aadharBackImage: map['aadharBackImage'] ?? '',
      gstCertificateImage: map['gstCertificateImage'] ?? '',
      approvalStatus: resolvedStatus,
    );
  }
}

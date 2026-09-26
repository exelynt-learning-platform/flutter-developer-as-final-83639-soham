class Employee {
  const Employee({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.country,
    required this.state,
    required this.district,
    this.avatar,
  });
  final String? id;
  final String name, email, mobile, country, state, district;
  final String? avatar;

  String get displayAvatar => (avatar != null && avatar!.trim().isNotEmpty)
      ? avatar!
      : 'https://i.pravatar.cc/150?u=${id ?? email}';

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id']?.toString(),
    name: '${json['name'] ?? ''}',
    email: '${json['email'] ?? ''}',
    mobile: '${json['mobile'] ?? json['phone'] ?? ''}',
    country: '${json['country'] ?? ''}',
    state: '${json['state'] ?? ''}',
    district: '${json['district'] ?? ''}',
    avatar: json['avatar']?.toString() ??
        json['photo']?.toString() ??
        json['image']?.toString(),
  );
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'mobile': mobile,
    'country': country,
    'state': state,
    'district': district,
    if (avatar != null) 'avatar': avatar,
  };
  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? country,
    String? state,
    String? district,
    String? avatar,
  }) => Employee(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    mobile: mobile ?? this.mobile,
    country: country ?? this.country,
    state: state ?? this.state,
    district: district ?? this.district,
    avatar: avatar ?? this.avatar,
  );
}

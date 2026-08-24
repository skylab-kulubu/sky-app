import 'package:flutter_test/flutter_test.dart';
import 'package:sky_app/features/auth/data/models/user.dart';

void main() {
  group('User', () {
    test('fromJwt parses payload correctly', () {
      final jwtPayload = {
        'sub': '12345',
        'name': 'Test User',
        'given_name': 'Test',
        'family_name': 'User',
        'email': 'test@example.com',
        'preferred_username': 'testuser',
        'university': 'YTU',
        'department': 'CENG',
        'sky_number': 'SKY-001',
        'email_verified': true,
        'realm_access': {
          'roles': ['MOBILAB', 'default-roles']
        }
      };

      final user = User.fromJwt(jwtPayload);

      expect(user.id, '12345');
      expect(user.name, 'Test User');
      expect(user.givenName, 'Test');
      expect(user.familyName, 'User');
      expect(user.email, 'test@example.com');
      expect(user.preferredUsername, 'testuser');
      expect(user.university, 'YTU');
      expect(user.department, 'CENG');
      expect(user.skyNumber, 'SKY-001');
      expect(user.emailVerified, isTrue);
      expect(user.realmRoles, contains('MOBILAB'));
      expect(user.realmRoles, contains('default-roles'));

      // Fields not in JWT should be defaults
      expect(user.schoolEmail, isEmpty);
      expect(user.faculty, isEmpty);
      expect(user.profilePictureUrl, isEmpty);
      expect(user.linkedin, isEmpty);
      expect(user.ldapUser, isFalse);
    });

    test('fromJson parses profile API data correctly', () {
      final apiData = {
        'id': '12345',
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@example.com',
        'username': 'testuser',
        'university': 'YTU',
        'department': 'CENG',
        'skyNumber': 'SKY-001',
        'schoolEmail': 'test@std.yildiz.edu.tr',
        'faculty': 'EE',
        'profilePictureUrl': 'https://example.com/pic.jpg',
        'linkedin': 'https://linkedin.com/in/testuser',
        'ldapUser': true,
      };

      final user = User.fromJson(apiData);

      expect(user.id, '12345');
      expect(user.name, 'Test User');
      expect(user.givenName, 'Test');
      expect(user.familyName, 'User');
      expect(user.email, 'test@example.com');
      expect(user.preferredUsername, 'testuser');
      expect(user.university, 'YTU');
      expect(user.department, 'CENG');
      expect(user.skyNumber, 'SKY-001');
      
      expect(user.schoolEmail, 'test@std.yildiz.edu.tr');
      expect(user.faculty, 'EE');
      expect(user.profilePictureUrl, 'https://example.com/pic.jpg');
      expect(user.linkedin, 'https://linkedin.com/in/testuser');
      expect(user.ldapUser, isTrue);

      // Roles and emailVerified are not provided by API
      expect(user.emailVerified, isFalse);
      expect(user.realmRoles, isEmpty);
    });

    test('mergeWith combines JWT and API data correctly', () {
      final jwtUser = User(
        id: '12345',
        name: 'Jwt Name',
        givenName: 'JwtGiven',
        familyName: 'JwtFamily',
        email: 'jwt@example.com',
        preferredUsername: 'jwtuser',
        university: 'JwtUni',
        department: 'JwtDept',
        skyNumber: 'JWT-SKY',
        emailVerified: true,
        realmRoles: ['MOBILAB'],
      );

      final profileUser = User(
        id: '67890', // Should override
        name: 'Profile Name',
        givenName: 'ProfileGiven',
        familyName: 'ProfileFamily',
        email: 'profile@example.com',
        preferredUsername: 'profileuser',
        university: 'ProfileUni',
        department: 'ProfileDept',
        skyNumber: 'PROFILE-SKY',
        emailVerified: false, // Should NOT override (API doesn't have it)
        realmRoles: [], // Should NOT override
        schoolEmail: 'school@std.edu',
        faculty: 'Faculty',
        profilePictureUrl: 'url',
        linkedin: 'linkedin_url',
        ldapUser: true,
      );

      final merged = jwtUser.mergeWith(profileUser);

      // API (profile) wins for shared fields
      expect(merged.id, '67890');
      expect(merged.name, 'Profile Name');
      expect(merged.givenName, 'ProfileGiven');
      expect(merged.familyName, 'ProfileFamily');
      expect(merged.email, 'profile@example.com');
      expect(merged.preferredUsername, 'profileuser');
      expect(merged.university, 'ProfileUni');
      expect(merged.department, 'ProfileDept');
      expect(merged.skyNumber, 'PROFILE-SKY');

      // API specific fields are applied
      expect(merged.schoolEmail, 'school@std.edu');
      expect(merged.faculty, 'Faculty');
      expect(merged.profilePictureUrl, 'url');
      expect(merged.linkedin, 'linkedin_url');
      expect(merged.ldapUser, isTrue);

      // JWT retains its specific fields
      expect(merged.emailVerified, isTrue);
      expect(merged.realmRoles, ['MOBILAB']);
    });

    test('mergeWith does not override with empty strings from profile', () {
      final jwtUser = User(
        id: '12345',
        name: 'Jwt Name',
        givenName: 'JwtGiven',
        familyName: 'JwtFamily',
        email: 'jwt@example.com',
        preferredUsername: 'jwtuser',
        university: 'JwtUni',
        department: 'JwtDept',
        skyNumber: 'JWT-SKY',
        emailVerified: true,
        realmRoles: ['MOBILAB'],
      );

      final emptyProfileUser = User(
        id: '',
        name: ' ', // Whitespace should be ignored by trim()
        givenName: '',
        familyName: '',
        email: '',
        preferredUsername: '',
        university: '',
        department: '',
        skyNumber: '',
        emailVerified: false,
        realmRoles: const [],
      );

      final merged = jwtUser.mergeWith(emptyProfileUser);

      // JWT values should be preserved because profile fields are empty
      expect(merged.id, '12345');
      expect(merged.name, 'Jwt Name');
      expect(merged.givenName, 'JwtGiven');
      expect(merged.familyName, 'JwtFamily');
      expect(merged.email, 'jwt@example.com');
      expect(merged.preferredUsername, 'jwtuser');
      expect(merged.university, 'JwtUni');
      expect(merged.department, 'JwtDept');
      expect(merged.skyNumber, 'JWT-SKY');
      expect(merged.emailVerified, isTrue);
      expect(merged.realmRoles, ['MOBILAB']);
    });
  });
}

const String updateProfileMutation = r'''
mutation updateProfile($input: UpdateProfileInput!) {
        updateProfile(input: $input) {
            isSuccess
            message
        }
    }
''';

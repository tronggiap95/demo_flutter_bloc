const String meQuery = r'''
query me {
    me {
        _id
        firstName
        lastName
        contact {
          phone1
        }
        isProfileCompleted
    }
}
''';

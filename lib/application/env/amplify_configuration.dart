const amplifyconfig = '''{
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "analytics": {
        "plugins": {
            "awsPinpointAnalyticsPlugin": {
                "pinpointAnalytics": {
                    "appId": "5912d37b32da4e478bb919d9c8034442",
                    "region": "ap-southeast-1"
                },
                "pinpointTargeting": {
                    "region": "ap-southeast-1"
                }
            }
        }
    },
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "PinpointAnalytics": {
                    "Default": {
                        "AppId": "5912d37b32da4e478bb919d9c8034442",
                        "Region": "ap-southeast-1"
                    }
                },
                "PinpointTargeting": {
                    "Default": {
                        "Region": "ap-southeast-1"
                    }
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "ap-southeast-1:7842c5ee-5afd-4f49-b7f8-af8609039825",
                            "Region": "ap-southeast-1"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "ap-southeast-1_XzX8xtfQF",
                        "AppClientId": "5b0nm7049nme7attkgn40jldem",
                        "Region": "ap-southeast-1"
                    }
                },
                "Auth": {
                    "Default": {
                        "OAuth": {
                            "WebDomain": "ecg-auth-alpha-alpha.auth.ap-southeast-1.amazoncognito.com",
                            "AppClientId": "5b0nm7049nme7attkgn40jldem",
                            "SignInRedirectURI": "octo360://",
                            "SignOutRedirectURI": "octo360://",
                            "Scopes": [
                                "aws.cognito.signin.user.admin",
                                "email",
                                "openid",
                                "phone",
                                "profile"
                            ]
                        },
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": [
                            "EMAIL"
                        ],
                        "signupAttributes": [],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": [],
                        "verificationMechanisms": [
                            "EMAIL"
                        ]
                    }
                },
                "S3TransferUtility": {
                    "Default": {
                        "Bucket": "itr-ecg-user-files82047-alpha",
                        "Region": "ap-southeast-1"
                    }
                }
            }
        }
    },
    "storage": {
        "plugins": {
            "awsS3StoragePlugin": {
                "bucket": "itr-ecg-user-files82047-alpha",
                "region": "ap-southeast-1",
                "defaultAccessLevel": "guest"
            }
        }
    }
}''';

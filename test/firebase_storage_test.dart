// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_common.dart';

void main() {
  initializeMethodChannel();
  final String storageBucket = 'gs://fake-storage-bucket-url.com';
  FirebaseApp app;
  FirebaseStorage storage;

  group('FirebaseStorage', () {
    setUpAll(() async {
      app = await Firebase.initializeApp(
        name: 'testApp',
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        ),
      );
      storage = FirebaseStorage(app: app, storageBucket: storageBucket);
    });

    group('getMaxDownloadRetryTimeMillis', () {
      final List<MethodCall> log = <MethodCall>[];

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return 1000;
        });
      });
      FirebaseStorage.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return 1000;
      });

      test('invokes correct method', () async {
        await storage.getMaxDownloadRetryTimeMillis();

        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseStorage#getMaxDownloadRetryTime',
            arguments: <String, String>{
              'app': 'testApp',
              'bucket': 'gs://fake-storage-bucket-url.com',
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        expect(await storage.getMaxDownloadRetryTimeMillis(), 1000);
      });
    });

    group('getMaxUploadRetryTimeMillis', () {
      final List<MethodCall> log = <MethodCall>[];

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return 2000;
        });
      });

      test('invokes correct method', () async {
        await storage.getMaxUploadRetryTimeMillis();

        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseStorage#getMaxUploadRetryTime',
            arguments: <String, String>{
              'app': 'testApp',
              'bucket': 'gs://fake-storage-bucket-url.com',
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        expect(await storage.getMaxUploadRetryTimeMillis(), 2000);
      });
    });

    group('getMaxOperationRetryTimeMillis', () {
      final List<MethodCall> log = <MethodCall>[];

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return 3000;
        });
      });

      test('invokes correct method', () async {
        await storage.getMaxOperationRetryTimeMillis();

        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseStorage#getMaxOperationRetryTime',
            arguments: <String, String>{
              'app': 'testApp',
              'bucket': 'gs://fake-storage-bucket-url.com',
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        expect(await storage.getMaxOperationRetryTimeMillis(), 3000);
      });
    });

    group('setMaxDownloadRetryTimeMillis', () {
      final List<MethodCall> log = <MethodCall>[];

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
        });
      });

      test('invokes correct method', () async {
        await storage.setMaxDownloadRetryTimeMillis(1000);

        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseStorage#setMaxDownloadRetryTime',
            arguments: <String, dynamic>{
              'app': 'testApp',
              'bucket': 'gs://fake-storage-bucket-url.com',
              'time': 1000,
            },
          ),
        ]);
      });
    });

    group('setMaxUploadRetryTimeMillis', () {
      final List<MethodCall> log = <MethodCall>[];

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
        });
      });

      test('invokes correct method', () async {
        await storage.setMaxUploadRetryTimeMillis(2000);

        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseStorage#setMaxUploadRetryTime',
            arguments: <String, dynamic>{
              'app': 'testApp',
              'bucket': 'gs://fake-storage-bucket-url.com',
              'time': 2000,
            },
          ),
        ]);
      });
    });

    group('setMaxOperationRetryTimeMillis', () {
      final List<MethodCall> log = <MethodCall>[];

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
        });
      });

      test('invokes correct method', () async {
        await storage.setMaxOperationRetryTimeMillis(3000);

        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseStorage#setMaxOperationRetryTime',
            arguments: <String, dynamic>{
              'app': 'testApp',
              'bucket': 'gs://fake-storage-bucket-url.com',
              'time': 3000,
            },
          ),
        ]);
      });
    });

    group('getReferenceFromUrl', () {
      final List<MethodCall> log = <MethodCall>[];

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return 'foo';
        });
      });

      test('invokes correct method', () async {
        final String url =
            'https://firebasestorage.googleapis.com/v0/b/fake-21c50.appspot.com/o/';
        final StorageReference reference =
            await storage.getReferenceFromUrl(url);
        expect(reference.path, 'foo');
        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseStorage#getReferenceFromUrl',
            arguments: <String, dynamic>{
              'app': 'testApp',
              'bucket': 'gs://fake-storage-bucket-url.com',
              'fullUrl': url,
            },
          ),
        ]);
      });
    });

    group('StorageReference', () {
      group('getData', () {
        final List<MethodCall> log = <MethodCall>[];

        StorageReference ref;

        setUp(() {
          FirebaseStorage.channel
              .setMockMethodCallHandler((MethodCall methodCall) {
            log.add(methodCall);
            return Future<Uint8List>.value(
                Uint8List.fromList(<int>[1, 2, 3, 4]));
          });
          ref =
              storage.ref().child('avatars').child('large').child('image.jpg');
        });

        test('invokes correct method', () async {
          await ref.getData(10);

          expect(log, <Matcher>[
            isMethodCall(
              'StorageReference#getData',
              arguments: <String, dynamic>{
                'app': 'testApp',
                'bucket': 'gs://fake-storage-bucket-url.com',
                'maxSize': 10,
                'path': 'avatars/large/image.jpg',
              },
            ),
          ]);
        });

        test('returns correct result', () async {
          expect(await ref.getData(10),
              equals(Uint8List.fromList(<int>[1, 2, 3, 4])));
        });
      });

      group('getMetadata', () {
        final List<MethodCall> log = <MethodCall>[];

        StorageReference ref;

        setUp(() {
          FirebaseStorage.channel
              .setMockMethodCallHandler((MethodCall methodCall) async {
            log.add(methodCall);
            return <String, String>{'name': 'image.jpg'};
          });
          ref =
              storage.ref().child('avatars').child('large').child('image.jpg');
        });

        test('invokes correct method', () async {
          await ref.getMetadata();

          expect(log, <Matcher>[
            isMethodCall(
              'StorageReference#getMetadata',
              arguments: <String, dynamic>{
                'app': 'testApp',
                'bucket': 'gs://fake-storage-bucket-url.com',
                'path': 'avatars/large/image.jpg',
              },
            ),
          ]);
        });

        test('returns correct result', () async {
          expect((await ref.getMetadata()).name, 'image.jpg');
        });
      });

      group('updateMetadata', () {
        final List<MethodCall> log = <MethodCall>[];

        StorageReference ref;

        setUp(() {
          FirebaseStorage.channel
              .setMockMethodCallHandler((MethodCall methodCall) async {
            log.add(methodCall);
            switch (methodCall.method) {
              case 'StorageReference#getMetadata':
                return <String, String>{
                  'name': 'image.jpg',
                };
              case 'StorageReference#updateMetadata':
                return <String, dynamic>{
                  'name': 'image.jpg',
                  'contentLanguage': 'en',
                  'customMetadata': <String, String>{'activity': 'test'},
                };
              default:
                return null;
            }
          });
          ref =
              storage.ref().child('avatars').child('large').child('image.jpg');
        });

        test('invokes correct method', () async {
          await ref.updateMetadata(StorageMetadata(
            contentLanguage: 'en',
            customMetadata: <String, String>{'activity': 'test'},
          ));

          expect(log, <Matcher>[
            isMethodCall(
              'StorageReference#updateMetadata',
              arguments: <String, dynamic>{
                'app': 'testApp',
                'bucket': 'gs://fake-storage-bucket-url.com',
                'path': 'avatars/large/image.jpg',
                'metadata': <String, dynamic>{
                  'cacheControl': null,
                  'contentDisposition': null,
                  'contentLanguage': 'en',
                  'contentType': null,
                  'contentEncoding': null,
                  'customMetadata': <String, String>{'activity': 'test'},
                },
              },
            ),
          ]);
        });

        test('returns correct result', () async {
          expect((await ref.getMetadata()).contentLanguage, null);
          expect(
              (await ref.updateMetadata(StorageMetadata(contentLanguage: 'en')))
                  .contentLanguage,
              'en');
        });
      });

      group('getDownloadUrl', () {
        final List<MethodCall> log = <MethodCall>[];

        StorageReference ref;

        setUp(() {
          FirebaseStorage.channel
              .setMockMethodCallHandler((MethodCall methodCall) async {
            log.add(methodCall);
            return 'https://path/to/file';
          });
          ref =
              storage.ref().child('avatars').child('large').child('image.jpg');
        });

        test('invokes correct method', () async {
          await ref.getDownloadURL();

          expect(log, <Matcher>[
            isMethodCall(
              'StorageReference#getDownloadUrl',
              arguments: <String, dynamic>{
                'app': 'testApp',
                'bucket': 'gs://fake-storage-bucket-url.com',
                'path': 'avatars/large/image.jpg',
              },
            ),
          ]);
        });

        test('returns correct result', () async {
          expect(await ref.getDownloadURL(), 'https://path/to/file');
        });
      });

      group('delete', () {
        final List<MethodCall> log = <MethodCall>[];

        StorageReference ref;

        setUp(() {
          FirebaseStorage.channel
              .setMockMethodCallHandler((MethodCall methodCall) async {
            log.add(methodCall);
            return null;
          });
          ref = storage.ref().child('image.jpg');
        });

        test('invokes correct method', () async {
          await ref.delete();

          expect(
            log,
            <Matcher>[
              isMethodCall(
                'StorageReference#delete',
                arguments: <String, dynamic>{
                  'app': 'testApp',
                  'bucket': 'gs://fake-storage-bucket-url.com',
                  'path': 'image.jpg',
                },
              ),
            ],
          );
        });
      });

      group('getBucket', () {
        final List<MethodCall> log = <MethodCall>[];

        StorageReference ref;

        setUp(() {
          FirebaseStorage.channel
              .setMockMethodCallHandler((MethodCall methodCall) async {
            log.add(methodCall);
            return 'foo';
          });
          ref =
              storage.ref().child('avatars').child('large').child('image.jpg');
        });

        test('invokes correct method', () async {
          await ref.getBucket();

          expect(log, <Matcher>[
            isMethodCall(
              'StorageReference#getBucket',
              arguments: <String, dynamic>{
                'app': 'testApp',
                'bucket': 'gs://fake-storage-bucket-url.com',
                'path': 'avatars/large/image.jpg',
              },
            ),
          ]);
        });

        test('returns correct result', () async {
          expect(await ref.getBucket(), 'foo');
        });
      });

      group('getName', () {
        final List<MethodCall> log = <MethodCall>[];

        StorageReference ref;

        setUp(() {
          FirebaseStorage.channel
              .setMockMethodCallHandler((MethodCall methodCall) async {
            log.add(methodCall);
            return 'image.jpg';
          });
          ref =
              storage.ref().child('avatars').child('large').child('image.jpg');
        });

        test('invokes correct method', () async {
          await ref.getName();

          expect(log, <Matcher>[
            isMethodCall(
              'StorageReference#getName',
              arguments: <String, dynamic>{
                'app': 'testApp',
                'bucket': 'gs://fake-storage-bucket-url.com',
                'path': 'avatars/large/image.jpg',
              },
            ),
          ]);
        });

        test('returns correct result', () async {
          expect(await ref.getName(), 'image.jpg');
        });
      });
    });

    group('getPath', () {
      final List<MethodCall> log = <MethodCall>[];

      StorageReference ref;

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return 'avatars/large/image.jpg';
        });
        ref = storage.ref().child('avatars').child('large').child('image.jpg');
      });

      test('invokes correct method', () async {
        await ref.getPath();

        expect(log, <Matcher>[
          isMethodCall(
            'StorageReference#getPath',
            arguments: <String, dynamic>{
              'app': 'testApp',
              'bucket': 'gs://fake-storage-bucket-url.com',
              'path': 'avatars/large/image.jpg',
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        expect(await ref.getPath(), 'avatars/large/image.jpg');
      });
    });

    group('writeToFile', () {
      final List<MethodCall> log = <MethodCall>[];

      StorageReference ref;
      String exceptionCode;

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          if (methodCall.arguments['path'].contains('_bad')) {
            throw PlatformException(code: "42");
          } else {
            return 4711;
          }
        });
      });

      test('invokes correct method', () async {
        ref = storage.ref().child('image.jpg');
        final StorageFileDownloadTask task = ref.writeToFile(File('image.jpg'));
        await task.future;

        expect(log, <Matcher>[
          isMethodCall(
            'StorageReference#writeToFile',
            arguments: <String, dynamic>{
              'app': 'testApp',
              'bucket': 'gs://fake-storage-bucket-url.com',
              'filePath': File('image.jpg').absolute.path,
              'path': 'image.jpg',
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        ref = storage.ref().child('image.jpg');
        final StorageFileDownloadTask task = ref.writeToFile(File('image.jpg'));
        final FileDownloadTaskSnapshot snapshot = await task.future;
        expect(snapshot.totalByteCount, 4711);
      });

      test('propagates exception', () async {
        ref = storage.ref().child('image_bad.jpg');
        final StorageFileDownloadTask task = ref.writeToFile(File('image.jpg'));
        try {
          await task.future;
        } on PlatformException catch (e) {
          exceptionCode = e.code;
        }

        expect(exceptionCode, equals('42'));
      });
    });
  });
}

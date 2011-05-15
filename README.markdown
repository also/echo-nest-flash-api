echo-nest-flash-api
===================

An ActionScript 3 interface for the the Echo Nest API.

http://github.com/also/echo-nest-flash-api

Getting the source
==================

You’ll need to clone the source from github:

    git clone git://github.com/also/echo-nest-flash-api.git

Including in your project
=========================

Add both `echo-nest-flash-api/src` to your classpath. Your Flash, Flex, or mxmlc documentation tells you how to do this.

Using the API
=============

echo-nest-flash-api implements a small subset of the [Echo Nest v4 API track methods][1].

Upload
------

    var fileReference:FileReference;

    private function chooseFile():void {
      fileReference = new FileReference();
      fileReference.addEventListener(Event.SELECT, function(e:Event):void {
        uploadFile();
      });
      fileReference.browse();
    }

    private function uploadFile():void {
      trackApi.uploadFileReference({track: fileReference}, {
        onResponse: function(track:Object):void {
          trace('id: ' + track.id + ', md5: ' + track.md5);  // id: TRMVA0211BC6E08329, md5: 2f45abacba9e9d2312afa63a8df10d23
        },
        onEchoNestError: function(error:EchoNestError):void {
          trace(error.code + ': ' + error.description);
        }
      });
    }

License
=======

Copyright 2009-2011 Ryan Berdeen. All rights reserved.
Distributed under the terms of the MIT License.
See accompanying file LICENSE.txt

 [1]: http://developer.echonest.com/docs/v4/track.html

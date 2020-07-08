import 'package:flutter/material.dart';

import '../controller/story_controller.dart';
import 'story_image.dart';
import 'story_video.dart';
import 'story_view.dart';

/// This is a representation of a story item (or page).
class StoryItem {
  /// Specifies how long the page should be displayed. It should be a reasonable
  /// amount of time greater than 0 milliseconds.
  final Duration duration;

  /// Has this page been shown already? This is used to indicate that the page
  /// has been displayed. If some pages are supposed to be skipped in a story,
  /// mark them as shown `shown = true`.
  ///
  /// However, during initialization of the story view, all pages after the
  /// last unshown page will have their `shown` attribute altered to false. This
  /// is because the next item to be displayed is taken by the last unshown
  /// story item.
  bool shown;

  /// The page content
  final Widget view;

  StoryItem(
    this.view, {
    this.duration,
    this.shown = false,
  }) : assert(duration != null, "[duration] should not be null");

  /// Short hand to create text-only page.
  ///
  /// [title] is the text to be displayed on [backgroundColor]. The text color
  /// alternates between [Colors.black] and [Colors.white] depending on the
  /// calculated contrast. This is to ensure readability of text.
  ///
  /// Works for inline and full-page stories. See [StoryView.inline] for more on
  /// what inline/full-page means.
  static StoryItem text({
    @required String title,
    @required Color backgroundColor,
    TextStyle textStyle,
    bool shown = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    Duration duration,
  }) {
    double contrast = ContrastHelper.contrast([
      backgroundColor.red,
      backgroundColor.green,
      backgroundColor.blue,
    ], [
      255,
      255,
      255
    ] /** white text */);

    return StoryItem(
      Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Center(
          child: Text(
            title,
            style: textStyle?.copyWith(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                ) ??
                TextStyle(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        //color: backgroundColor,
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
    );
  }

  /// Factory constructor for page images. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageImage({
    @required String url,
    @required StoryController controller,
    BoxFit imageFit = BoxFit.fitWidth,
    String caption,
    bool shown = false,
    Map<String, dynamic> requestHeaders,
    Duration duration,
  }) {
    return StoryItem(
      Container(
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            StoryImage.url(
              url,
              controller: controller,
              fit: imageFit,
              requestHeaders: requestHeaders,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    bottom: 24,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  color: caption != null ? Colors.black54 : Colors.transparent,
                  child: caption != null
                      ? Text(
                          caption,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : SizedBox(),
                ),
              ),
            )
          ],
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
    );
  }

  /// Shorthand for creating inline image. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.inlineImage({
    @required String url,
    @required Text caption,
    @required StoryController controller,
    BoxFit imageFit = BoxFit.cover,
    Map<String, dynamic> requestHeaders,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration duration,
  }) {
    return StoryItem(
      ClipRRect(
        child: Container(
          color: Colors.grey[100],
          child: Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                StoryImage.url(
                  url,
                  controller: controller,
                  fit: imageFit,
                  requestHeaders: requestHeaders,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      child: caption == null ? SizedBox() : caption,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(roundedTop ? 8 : 0),
          bottom: Radius.circular(roundedBottom ? 8 : 0),
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
    );
  }

  /// Shorthand for creating page video. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageVideo(
    String url, {
    @required StoryController controller,
    Duration duration,
    BoxFit imageFit = BoxFit.fitWidth,
    String caption,
    bool shown = false,
    Map<String, dynamic> requestHeaders,
  }) {
    return StoryItem(
        Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              StoryVideo.url(
                url,
                controller: controller,
                requestHeaders: requestHeaders,
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 24),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    color:
                        caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: TextStyle(fontSize: 15, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        : SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        shown: shown,
        duration: duration ?? Duration(seconds: 10));
  }

  /// Shorthand for creating a story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.pageProviderImage(
    ImageProvider image, {
    BoxFit imageFit = BoxFit.fitWidth,
    String caption,
    bool shown = false,
    Duration duration,
  }) {
    assert(imageFit != null, "[imageFit] should not be null");
    return StoryItem(
        Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Center(
                child: Image(
                  image: image,
                  height: double.infinity,
                  width: double.infinity,
                  fit: imageFit,
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                      bottom: 24,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    color:
                        caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        shown: shown,
        duration: duration ?? Duration(seconds: 3));
  }

  /// Shorthand for creating an inline story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.inlineProviderImage(
    ImageProvider image, {
    Text caption,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration duration,
  }) {
    return StoryItem(
      Container(
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(roundedTop ? 8 : 0),
              bottom: Radius.circular(roundedBottom ? 8 : 0),
            ),
            image: DecorationImage(
              image: image,
              fit: BoxFit.cover,
            )),
        child: Container(
          margin: EdgeInsets.only(
            bottom: 16,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              child: caption == null ? SizedBox() : caption,
              width: double.infinity,
            ),
          ),
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
    );
  }
}


## 更新说明

突然间这两个月这个东西好像很多人有需求，甚至还有直接找到我微信加我的。

现在这个代码其实能实现得功能很有限。

更多的拓展可以有：

1. 自定义view在画中画上。 

2. 隐藏系统的播放按钮、快进、进度条、拍照或者拍摄视频时，怎么才不会暗屏。横屏，正方形，竖屏。

3. 拍摄视频30s左右后，代码不会停止运行。旋转悬浮窗。

预览：

<video id="video" controls="" preload="none">
      <source id="mp4" src="https://picture-transmission.iplus-studio.top/uPic/RPReplay_Final1648698303.MP4" type="video/mp4">
      <p>Your user agent does not support the HTML5 Video element.</p>
</video>

### Floating-Clock App

> Use `AVPictureInPictureController` It can hover over other apps.  Time display will not be affected by users


if you use iphone, `AVPictureInPictureController` require iOS14 

If you're going to run it in an simulator, the iPad's simulator supports picture-in-picture, but the iPhone doesn't

### 中文说明
[知乎跳转连接](https://zhuanlan.zhihu.com/p/356483705)


### 1. PreView

![demo.gif](Resource/demo.gif)



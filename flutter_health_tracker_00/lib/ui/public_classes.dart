// Description: Public Classes
// Code
// Put public class that are used a lot, in this file for easier access

////////////////////////////
// Normalize Persian Numbers
String normalizeNumber(String input) {
  const persianNums = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const englishNums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  for (var i = 0; i < persianNums.length; i++) {
    input = input.replaceAll(persianNums[i], englishNums[i]);
  }
  return input;
}

/////////////////////////////
// Persianize English Numbers
String persianizeNumber(String input) {
  const persianNums = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const englishNums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  for (var i = 0; i < persianNums.length; i++) {
    input = input.replaceAll(englishNums[i], persianNums[i]);
  }
  return input;
}

//* New Functions for Future
// FittedBox() to fit the text on the screen
// Wrap() to wrap elements
// SnackBarBehavior.floating for floating snackbar (visualy better)
// LayoutBuilder() for bigger screens
// LongPressDraggable() well, drag anything anywhere
// SelectableText() the text can be selected
// ShaderMask() for gradient text
// ListView for Lazyloading the widgets (instead of SignleChildScrollView)
// .adaptive for Android iOS adaptation of the widgets

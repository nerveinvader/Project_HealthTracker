// Description: Public Classes
// Code
// Put public class that are used a lot, in this file for easier access

////////////////////////////
// Normalize Persian Numbers
String normalizeNumber(String input) {
  const persianNums = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
  const englishNums = ['0','1','2','3','4','5','6','7','8','9'];
  for (var i = 0; i < persianNums.length; i++) {
    input = input.replaceAll(persianNums[i], englishNums[i]);
  }
  return input;
}

/////////////////////////////
// Persianize English Numbers
String persianizeNumber(String input) {
  const persianNums = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
  const englishNums = ['0','1','2','3','4','5','6','7','8','9'];
  for (var i = 0; i < persianNums.length; i++) {
    input = input.replaceAll(englishNums[i], persianNums[i]);
  }
  return input;
}

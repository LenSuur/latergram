class DateHelper {
  static bool isDecember() {
    return true;
    // return DateTime.now().month == 12;
  }

  static int currentYear() {
    return DateTime.now().year;
  }
}
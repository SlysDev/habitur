int hashDate(DateTime date) {
// format date as string with specific format
  String formattedDate = formatDate(date, [yyyy, '-', mm, '-', dd]);

  // convert string to integer using hash function
  int hash = formattedDate.hashCode;

  return hash;
}

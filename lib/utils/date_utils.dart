import 'package:intl/intl.dart';

class DateUtilsCustom {
  static String formatFecha(DateTime date) {
    final formatter = DateFormat("EEEE, d 'de' MMMM 'de' y", 'es_CL');
    String fecha = formatter.format(date);

    // Dividir en palabras
    List<String> palabras = fecha.split(' ');

    // Capitalizar el día (posición 0) y el mes (posición 3)
    palabras[0] = palabras[0][0].toUpperCase() + palabras[0].substring(1);
    palabras[3] = palabras[3][0].toUpperCase() + palabras[3].substring(1);

    return palabras.join(' ');
  }
}

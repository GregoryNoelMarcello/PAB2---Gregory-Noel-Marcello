
import "package:firebase_database/firebase_database.dart";

class GoldService {
  final DatabaseReference database=FirebaseDatabase.instance.ref('harga_emas',);


Stream<DatabaseEvent> getPriceList(){
  return database.onValue;
}
}

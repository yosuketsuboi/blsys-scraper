import 'dart:html';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  BlsysScraperClient client = new BlsysScraperClient();
  client.updateAll();
  
  querySelector('#title a').onClick.listen((e) {
    client.updateAll();
    e.preventDefault();
  });
}

class BlsysScraperClient {
  
  static const SERVER_URL = 'http://192.168.56.5/blsys-scraper/scraper.php';
  
  List<Map> _patrolList = [{'dsmk': '634', 'dk' : 'jq_1f2_e2-jq_1f2_e5-jq_1f2_8u39op'}, {'dsmk': '589', 'dk' : 'id_1c1_nqu30c-id_1c1_nqu30g'}, {'dsmk': '611', 'dk' : 'j3_1dk_av'}];

  void updateAll() {
    for (Map map in _patrolList) {
      var queryString = _buildQueryParameter(map);
      _update(queryString);
    }
  }
  
  void _update(String queryString) {
    var url = SERVER_URL;
    if (queryString.length > 0) {
      url += '?' + queryString; 
    }
    SHA1 sha1 = new SHA1();
    sha1.add(UTF8.encode(queryString));
    var id = CryptoUtils.bytesToHex(sha1.close());
    
    HttpRequest.getString(url).then((resText) {
      var map = JSON.decode(resText);
      Element updatedUnit = querySelector('#unit-template').clone(true);
      updatedUnit.querySelector('.bus-stop span').text = map['bus_stop'];
      updatedUnit.querySelector('.bus-stop a').onClick.listen((e) {
        _update(queryString);
        e.preventDefault();
      });
      updatedUnit.querySelector('.modified').text = map['modified'];
      TableElement table = updatedUnit.querySelector('.table');
      for (var r in map['results']) {
        table.addRow();
        table.rows.last.addCell().text = r['scheduled']; 
        table.rows.last.addCell().text = r['actual'];
        table.rows.last.addCell().text = r['destination'];
        table.rows.last.addCell().text = r['text'];
      }
      updatedUnit.setAttribute('style', '');

      Element contents = querySelector('#contents');
      updatedUnit.setAttribute('id', 'I' + id);
      Element unit = contents.querySelector('#I' + id);
      if (unit == null) {
        contents.children.add(updatedUnit);
      } else {
        unit.replaceWith(updatedUnit);
      }
    });
  }
  
  String _buildQueryParameter(Map paramMap) {
    var queryString = '';
    for (var key in paramMap.keys) {
      if (queryString.length > 0) {
        queryString += '&';
      }
      queryString += key + '=' + paramMap[key];
    }
    return queryString;
  }

}

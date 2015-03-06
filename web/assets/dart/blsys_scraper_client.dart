import 'dart:html';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  BlsysScraperClient client = new BlsysScraperClient();
  client.updateAll();
  
  querySelector('#logo-container').onClick.listen((e) {
    client.changeDirection();
    e.preventDefault();
  });
  
  querySelector('#refresh').onClick.listen((e) {
    client.updateAll();
    e.preventDefault();
  });
  
  querySelector('#refresh-m').onClick.listen((e) {
    client.updateAll();
    e.preventDefault();
  });
  
  querySelector('#transfer').onClick.listen((e) {
    client.changeDirection();
    e.preventDefault();
  });
  
  querySelector('#transfer-m').onClick.listen((e) {
    client.changeDirection();
    e.preventDefault();
  });
}

class BlsysScraperClient {

  static const SERVER_URL = 'scraper.php';
  
  List<List<Map>> _patrolList = [
                                  [{'dsmk': '634', 'dk' : 'jq_1f2_e2-jq_1f2_e5-jq_1f2_8u39op'}, {'dsmk': '589', 'dk' : 'id_1c1_nqu30c-id_1c1_nqu30g'}, {'dsmk': '611', 'dk' : 'j3_1dk_av'}],
                                  [{'dsmk': '539', 'dk' : 'gr_17a_1q8-gr_17a_nqu30b-gr_17a_nqu30h'}, {'dsmk': '539', 'dk' : 'gr_17b_as-gr_17b_8u39sk'}, {'dsmk': '732', 'dk' : 'ms_1qe_e2-ms_1qe_e4-ms_1qe_8u39oo'}]
                                ];
  
  int index = 0;
  
  void refresh() {
    Node n;
    while ((n = querySelector('#contents').firstChild) != null) {
      n.remove(); 
    }
    updateAll();
  }
  
  void changeDirection() {
    if (index == 0) {
      querySelector('#lt').style.display = 'inline';
      querySelector('#gt').style.display = 'none';
      index = 1;
    } else {
      querySelector('#gt').style.display = 'inline';
      querySelector('#lt').style.display = 'none';
      index = 0;
    }
    refresh();
  }

  void updateAll() {
    for (Map map in _patrolList[index]) {
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

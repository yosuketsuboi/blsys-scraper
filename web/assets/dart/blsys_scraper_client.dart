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
    // start refresh animation
    querySelector('#refresh .mdi-navigation-refresh').classes.add('loading');
    
    Node n;
    while ((n = querySelector('#content .row').firstChild) != null) {
      n.remove(); 
    }
    updateAll();

    // stop refresh animation
    querySelector('#refresh .mdi-navigation-refresh').classes.remove('loading');
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
    
    Element updatedUnit = querySelector('#unit-template').clone(true);
    // start reload animation
    _toggleCardSymbol(updatedUnit, true);
    
    updatedUnit.setAttribute('id', 'I' + id);
    Element timetableRow = querySelector('#content .row');
    Element unit = timetableRow.querySelector('#I' + id);
    if (unit == null) {
      timetableRow.children.add(updatedUnit);
    } else {
      unit.replaceWith(updatedUnit);
    }
    
    HttpRequest.getString(url).then((resText) {
      var map = JSON.decode(resText);
      updatedUnit.querySelector('.bus-stop span').text = map['bus_stop'];
      // TODO card refresh
//      updatedUnit.querySelector('.modified a').onClick.listen((e) {
//        _update(queryString);
//        e.preventDefault();
//      });
      updatedUnit.querySelector('.modified span').text = map['modified'];
      TableElement table = updatedUnit.querySelector('.table');
      for (Map<String, String> r in map['results']) {
        table.addRow();
        table.rows.last.addCell().appendText(r['scheduled']); 
        table.rows.last.addCell().appendText(r['actual']);
        table.rows.last.addCell().appendHtml(r['destination']
            .replaceFirst('【', '[')
            .replaceFirst('】', ']<br>'));
        table.rows.last.addCell().appendHtml(r['text']
            .replaceFirst('まもなく', 'まもなく<br>')
            .replaceFirst('遅れ', '<br>遅れ')
            .replaceFirst('です。', '')
            .replaceFirst('します。', ''));
      }
      updatedUnit.setAttribute('style', '');
      // stop reload animation
      _toggleCardSymbol(updatedUnit, false);
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
  
  void _toggleCardSymbol(Element unit, bool loading) {
    if (loading) {
      unit.querySelector('.mdi-action-autorenew').classes.add('loading');
      unit.querySelector('.mdi-action-autorenew').style.display = 'inline';
      unit.querySelector('.mdi-maps-place').style.display = 'none';
    } else {
      unit.querySelector('.mdi-maps-place').style.display = 'inline';
      unit.querySelector('.mdi-action-autorenew').style.display = 'none';
      unit.querySelector('.mdi-action-autorenew').classes.remove('loading');
    }
  }

}

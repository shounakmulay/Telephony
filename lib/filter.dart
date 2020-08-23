part of 'telephony.dart';

abstract class Filter<T, K> {
  T and(K column);

  T or(K column);

  String get selection;

  List<String> get selectionArgs;
}

class SmsFilter implements Filter<SmsFilterStatement, SmsColumn> {
  final String _filter;
  final List<String> _filterArgs;

  SmsFilter._(this._filter, this._filterArgs);

  static SmsFilterStatement where(SmsColumn column) =>
      SmsFilterStatement._(column._columnName);

  SmsFilterStatement and(SmsColumn column) {
    return _addCombineOperator(column, " AND");
  }

  @override
  SmsFilterStatement or(SmsColumn column) {
    return _addCombineOperator(column, " OR");
  }

  SmsFilterStatement _addCombineOperator(SmsColumn column, String operator) {
    return SmsFilterStatement._withPreviousFilter("$_filter $operator",
        column._name, List.from(_filterArgs, growable: true));
  }

  @visibleForTesting
  @override
  String get selection => _filter;

  @visibleForTesting
  @override
  List<String> get selectionArgs => _filterArgs;
}

class ConversationFilter
    extends Filter<ConversationFilterStatement, ConversationColumn> {
  final String _filter;
  final List<String> _filterArgs;

  ConversationFilter._(this._filter, this._filterArgs);

  static ConversationFilterStatement where(ConversationColumn column) =>
      ConversationFilterStatement._(column._columnName);

  @override
  ConversationFilterStatement and(ConversationColumn column) {
    return _addCombineOperator(column, " AND");
  }

  @override
  ConversationFilterStatement or(ConversationColumn column) {
    return _addCombineOperator(column, " OR");
  }

  ConversationFilterStatement _addCombineOperator(
      ConversationColumn column, String operator) {
    return ConversationFilterStatement._withPreviousFilter("$_filter $operator",
        column._name, List.from(_filterArgs, growable: true));
  }

  @override
  String get selection => _filter;

  @override
  List<String> get selectionArgs => _filterArgs;
}

abstract class FilterStatement<T extends Filter, K> {
  String _column;
  String _previousFilter;
  List<String> _previousFilterArgs;

  FilterStatement._(this._column);

  FilterStatement._withPreviousFilter(
      String previousFilter, String column, List<String> previousFilterArgs)
      : _previousFilter = previousFilter,
        _column = column,
        _previousFilterArgs = previousFilterArgs;

  T equals(String equalTo) {
    return _createFilter(equalTo, "=");
  }

  T greaterThan(String value) {
    return _createFilter(value, ">");
  }

  T lessThan(String value) {
    return _createFilter(value, "<");
  }

  T greaterThanOrEqualTo(String value) {
    return _createFilter(value, ">=");
  }

  T lessThanOrEqualTo(String value) {
    return _createFilter(value, "<=");
  }

  T notEqualTo(String value) {
    return _createFilter(value, "!=");
  }

  T like(String value) {
    return _createFilter(value, "LIKE");
  }

  T inValues(List<String> values) {
    final String filterValues = values.join(",");
    return _createFilter("($filterValues)", "IN");
  }

  T between(String from, String to) {
    final String filterValue = "$from AND $to";
    return _createFilter(filterValue, "BETWEEN");
  }

  K get not {
    _previousFilter += " NOT";
    return this as K;
  }

  T _createFilter(String value, String operator);
}

class SmsFilterStatement
    extends FilterStatement<SmsFilter, SmsFilterStatement> {
  SmsFilterStatement._(String column) : super._(column);

  SmsFilterStatement._withPreviousFilter(
      String previousFilter, String column, List<String> previousFilterArgs)
      : super._withPreviousFilter(previousFilter, column, previousFilterArgs);

  @override
  SmsFilter _createFilter(String value, String operator) {
    if (_previousFilter != null) {
      return SmsFilter._("$_previousFilter $_column $operator ?",
          _previousFilterArgs..add(value));
    } else {
      return SmsFilter._("$_column $operator ?", [value]);
    }
  }
}

class ConversationFilterStatement
    extends FilterStatement<ConversationFilter, ConversationFilterStatement> {
  ConversationFilterStatement._(String column) : super._(column);

  ConversationFilterStatement._withPreviousFilter(
      String previousFilter, String column, List<String> previousFilterArgs)
      : super._withPreviousFilter(previousFilter, column, previousFilterArgs);

  @override
  ConversationFilter _createFilter(String value, String operator) {
    if (_previousFilter != null) {
      return ConversationFilter._("$_previousFilter $_column $operator ?",
          _previousFilterArgs..add(value));
    } else {
      return ConversationFilter._("$_column $operator ?", [value]);
    }
  }
}

class OrderBy {
  final _TelephonyColumn _column;
  Sort _sort = Sort.DESC;

  OrderBy(this._column, {Sort sort}) {
    if (sort != null) {
      _sort = sort;
    }
  }

  String get _value => "${_column._name} ${_sort.value}";
}

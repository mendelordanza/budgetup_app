// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_rate_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCurrencyRateEntityCollection on Isar {
  IsarCollection<CurrencyRateEntity> get currencyRateEntitys =>
      this.collection();
}

const CurrencyRateEntitySchema = CollectionSchema(
  name: r'CurrencyRateEntity',
  id: 2913455070641601179,
  properties: {
    r'country': PropertySchema(
      id: 0,
      name: r'country',
      type: IsarType.string,
    ),
    r'rate': PropertySchema(
      id: 1,
      name: r'rate',
      type: IsarType.double,
    )
  },
  estimateSize: _currencyRateEntityEstimateSize,
  serialize: _currencyRateEntitySerialize,
  deserialize: _currencyRateEntityDeserialize,
  deserializeProp: _currencyRateEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _currencyRateEntityGetId,
  getLinks: _currencyRateEntityGetLinks,
  attach: _currencyRateEntityAttach,
  version: '3.1.0+1',
);

int _currencyRateEntityEstimateSize(
  CurrencyRateEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.country;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _currencyRateEntitySerialize(
  CurrencyRateEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.country);
  writer.writeDouble(offsets[1], object.rate);
}

CurrencyRateEntity _currencyRateEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CurrencyRateEntity();
  object.country = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.rate = reader.readDoubleOrNull(offsets[1]);
  return object;
}

P _currencyRateEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _currencyRateEntityGetId(CurrencyRateEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _currencyRateEntityGetLinks(
    CurrencyRateEntity object) {
  return [];
}

void _currencyRateEntityAttach(
    IsarCollection<dynamic> col, Id id, CurrencyRateEntity object) {
  object.id = id;
}

extension CurrencyRateEntityQueryWhereSort
    on QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QWhere> {
  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CurrencyRateEntityQueryWhere
    on QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QWhereClause> {
  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CurrencyRateEntityQueryFilter
    on QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QFilterCondition> {
  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'country',
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'country',
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'country',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'country',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'country',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      countryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'country',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      rateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rate',
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      rateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rate',
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      rateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      rateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      rateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterFilterCondition>
      rateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension CurrencyRateEntityQueryObject
    on QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QFilterCondition> {}

extension CurrencyRateEntityQueryLinks
    on QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QFilterCondition> {}

extension CurrencyRateEntityQuerySortBy
    on QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QSortBy> {
  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterSortBy>
      sortByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterSortBy>
      sortByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterSortBy>
      sortByRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rate', Sort.asc);
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterSortBy>
      sortByRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rate', Sort.desc);
    });
  }
}

extension CurrencyRateEntityQuerySortThenBy
    on QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QSortThenBy> {
  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterSortBy>
      thenByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterSortBy>
      thenByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterSortBy>
      thenByRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rate', Sort.asc);
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QAfterSortBy>
      thenByRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rate', Sort.desc);
    });
  }
}

extension CurrencyRateEntityQueryWhereDistinct
    on QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QDistinct> {
  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QDistinct>
      distinctByCountry({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'country', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QDistinct>
      distinctByRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rate');
    });
  }
}

extension CurrencyRateEntityQueryProperty
    on QueryBuilder<CurrencyRateEntity, CurrencyRateEntity, QQueryProperty> {
  QueryBuilder<CurrencyRateEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CurrencyRateEntity, String?, QQueryOperations>
      countryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'country');
    });
  }

  QueryBuilder<CurrencyRateEntity, double?, QQueryOperations> rateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rate');
    });
  }
}

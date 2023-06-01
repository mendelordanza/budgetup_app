// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_category_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExpenseCategoryEntityCollection on Isar {
  IsarCollection<ExpenseCategoryEntity> get expenseCategoryEntitys =>
      this.collection();
}

const ExpenseCategoryEntitySchema = CollectionSchema(
  name: r'ExpenseCategoryEntity',
  id: -3424045433436558555,
  properties: {
    r'budget': PropertySchema(
      id: 0,
      name: r'budget',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'icon': PropertySchema(
      id: 2,
      name: r'icon',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 3,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _expenseCategoryEntityEstimateSize,
  serialize: _expenseCategoryEntitySerialize,
  deserialize: _expenseCategoryEntityDeserialize,
  deserializeProp: _expenseCategoryEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'expenseTransactions': LinkSchema(
      id: 5887699109041738118,
      name: r'expenseTransactions',
      target: r'ExpenseTxnEntity',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _expenseCategoryEntityGetId,
  getLinks: _expenseCategoryEntityGetLinks,
  attach: _expenseCategoryEntityAttach,
  version: '3.1.0+1',
);

int _expenseCategoryEntityEstimateSize(
  ExpenseCategoryEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.icon;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _expenseCategoryEntitySerialize(
  ExpenseCategoryEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.budget);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.icon);
  writer.writeString(offsets[3], object.title);
  writer.writeDateTime(offsets[4], object.updatedAt);
}

ExpenseCategoryEntity _expenseCategoryEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExpenseCategoryEntity();
  object.budget = reader.readDoubleOrNull(offsets[0]);
  object.createdAt = reader.readDateTimeOrNull(offsets[1]);
  object.icon = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.title = reader.readStringOrNull(offsets[3]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[4]);
  return object;
}

P _expenseCategoryEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _expenseCategoryEntityGetId(ExpenseCategoryEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _expenseCategoryEntityGetLinks(
    ExpenseCategoryEntity object) {
  return [object.expenseTransactions];
}

void _expenseCategoryEntityAttach(
    IsarCollection<dynamic> col, Id id, ExpenseCategoryEntity object) {
  object.id = id;
  object.expenseTransactions.attach(
      col, col.isar.collection<ExpenseTxnEntity>(), r'expenseTransactions', id);
}

extension ExpenseCategoryEntityQueryWhereSort
    on QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QWhere> {
  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExpenseCategoryEntityQueryWhere on QueryBuilder<ExpenseCategoryEntity,
    ExpenseCategoryEntity, QWhereClause> {
  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterWhereClause>
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

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterWhereClause>
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

extension ExpenseCategoryEntityQueryFilter on QueryBuilder<
    ExpenseCategoryEntity, ExpenseCategoryEntity, QFilterCondition> {
  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> budgetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'budget',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> budgetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'budget',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> budgetEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> budgetGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'budget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> budgetLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'budget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> budgetBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'budget',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> iconIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'icon',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> iconIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'icon',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> iconEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> iconGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> iconLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> iconBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'icon',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> iconStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> iconEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
          QAfterFilterCondition>
      iconContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
          QAfterFilterCondition>
      iconMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'icon',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> iconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> iconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ExpenseCategoryEntityQueryObject on QueryBuilder<
    ExpenseCategoryEntity, ExpenseCategoryEntity, QFilterCondition> {}

extension ExpenseCategoryEntityQueryLinks on QueryBuilder<ExpenseCategoryEntity,
    ExpenseCategoryEntity, QFilterCondition> {
  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
          QAfterFilterCondition>
      expenseTransactions(FilterQuery<ExpenseTxnEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'expenseTransactions');
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> expenseTransactionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'expenseTransactions', length, true, length, true);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> expenseTransactionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'expenseTransactions', 0, true, 0, true);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> expenseTransactionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'expenseTransactions', 0, false, 999999, true);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> expenseTransactionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'expenseTransactions', 0, true, length, include);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> expenseTransactionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'expenseTransactions', length, include, 999999, true);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity,
      QAfterFilterCondition> expenseTransactionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'expenseTransactions', lower, includeLower, upper, includeUpper);
    });
  }
}

extension ExpenseCategoryEntityQuerySortBy
    on QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QSortBy> {
  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      sortByBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      sortByBudgetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.desc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      sortByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      sortByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ExpenseCategoryEntityQuerySortThenBy
    on QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QSortThenBy> {
  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByBudgetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.desc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ExpenseCategoryEntityQueryWhereDistinct
    on QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QDistinct> {
  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QDistinct>
      distinctByBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budget');
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QDistinct>
      distinctByIcon({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'icon', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpenseCategoryEntity, ExpenseCategoryEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ExpenseCategoryEntityQueryProperty on QueryBuilder<
    ExpenseCategoryEntity, ExpenseCategoryEntity, QQueryProperty> {
  QueryBuilder<ExpenseCategoryEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExpenseCategoryEntity, double?, QQueryOperations>
      budgetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budget');
    });
  }

  QueryBuilder<ExpenseCategoryEntity, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ExpenseCategoryEntity, String?, QQueryOperations>
      iconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'icon');
    });
  }

  QueryBuilder<ExpenseCategoryEntity, String?, QQueryOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ExpenseCategoryEntity, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

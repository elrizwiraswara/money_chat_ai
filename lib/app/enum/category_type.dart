enum CategoryType {
  expenses,
  income;

  static CategoryType fromValue(String? name) {
    if (name == CategoryType.expenses.name) {
      return CategoryType.expenses;
    }

    if (name == CategoryType.income.name) {
      return CategoryType.income;
    }

    return CategoryType.expenses;
  }
}

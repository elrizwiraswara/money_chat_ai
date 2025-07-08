enum CommandType {
  addExpense('/addex'),
  addIncome('/addin'),
  edit('/edit'),
  delete('/del'),
  recap('/recap'),
  help('/help'),
  invalid(''),
  noCommand('');

  const CommandType(this.command);
  final String command;

  static CommandType fromString(String command) {
    for (final type in CommandType.values) {
      if (type.command == command.toLowerCase()) {
        return type;
      }
    }
    return CommandType.invalid;
  }

  static List<CommandType> getValidCommands() {
    return CommandType.values
        .where(
          (type) =>
              type != CommandType.invalid && type != CommandType.noCommand,
        )
        .toList();
  }
}

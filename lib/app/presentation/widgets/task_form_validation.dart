class TaskFormValidation {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    return null;
  }

  static String? validateDueDate(DateTime? value) {
    if (value == null) {
      return 'Due date is required';
    }
    if (value.isBefore(DateTime.now())) {
      return 'Due date cannot be in the past';
    }
    return null;
  }
}

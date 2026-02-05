class Validators {
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s\.]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  // Phone number validation (Indian format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.replaceAll(RegExp(r'\s'), ''))) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  // PAN card validation
  static String? validatePAN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN number is required';
    }
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value.toUpperCase())) {
      return 'Enter a valid PAN (e.g., ABCDE1234F)';
    }
    return null;
  }

  // Aadhar card validation
  static String? validateAadhar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhar number is required';
    }
    String cleaned = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{12}$').hasMatch(cleaned)) {
      return 'Enter a valid 12-digit Aadhar number';
    }
    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    int? age = int.tryParse(value);
    if (age == null) {
      return 'Enter a valid number';
    }
    if (age < 22 || age > 70) {
      return 'Age must be between 22 and 70';
    }
    return null;
  }

  // ORCID validation
  static String? validateORCID(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (!RegExp(r'^\d{4}-\d{4}-\d{4}-\d{3}[\dX]$').hasMatch(value)) {
      return 'Enter valid ORCID (e.g., 0000-0002-1825-0097)';
    }
    return null;
  }

  // Year validation
  static String? validateYear(String? value, {bool required = true}) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }
    if (value == null || value.trim().isEmpty) {
      return 'Year is required';
    }
    int? year = int.tryParse(value);
    if (year == null) {
      return 'Enter a valid year';
    }
    int currentYear = DateTime.now().year;
    if (year < 1950 || year > currentYear + 5) {
      return 'Enter a valid year';
    }
    return null;
  }

  // Years of experience validation
  static String? validateYearsOfExperience(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Years of experience is required';
    }
    int? years = int.tryParse(value);
    if (years == null) {
      return 'Enter a valid number';
    }
    if (years < 0 || years > 50) {
      return 'Years must be between 0 and 50';
    }
    return null;
  }

  // Institution name validation
  static String? validateInstitution(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Institution name is required';
    }
    if (value.trim().length < 3) {
      return 'Institution name must be at least 3 characters';
    }
    return null;
  }

  // Course name validation
  static String? validateCourse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Course name is required';
    }
    if (value.trim().length < 2) {
      return 'Course name must be at least 2 characters';
    }
    return null;
  }

  // Duration validation
  static String? validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Duration is required';
    }
    int? duration = int.tryParse(value);
    if (duration == null) {
      return 'Enter a valid number';
    }
    if (duration < 1 || duration > 10) {
      return 'Duration must be between 1 and 10 years';
    }
    return null;
  }

  // Date validation (DD/MM/YYYY format)
  static String? validateDate(String? value, {bool required = true}) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }
    if (value == null || value.trim().isEmpty) {
      return 'Date is required';
    }
    try {
      List<String> parts = value.split('/');
      if (parts.length != 3) {
        return 'Use DD/MM/YYYY format';
      }
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      
      DateTime date = DateTime(year, month, day);
      if (date.isAfter(DateTime.now())) {
        return 'Date cannot be in the future';
      }
      return null;
    } catch (e) {
      return 'Enter a valid date (DD/MM/YYYY)';
    }
  }

  // Check if joining date is after birth date
  static String? validateJoiningDate(String? joiningDate, String? birthDate) {
    if (joiningDate == null || joiningDate.trim().isEmpty) {
      return 'Date of joining is required';
    }
    if (birthDate == null || birthDate.trim().isEmpty) {
      return null; // Can't validate if birth date is not provided
    }
    
    try {
      DateTime doj = _parseDate(joiningDate);
      DateTime dob = _parseDate(birthDate);
      
      if (doj.isBefore(dob)) {
        return 'Joining date must be after birth date';
      }
      
      int age = doj.year - dob.year;
      if (age < 18) {
        return 'Must be at least 18 years old at joining';
      }
      
      return null;
    } catch (e) {
      return 'Enter valid dates';
    }
  }

  // Helper to parse DD/MM/YYYY format
  static DateTime _parseDate(String date) {
    List<String> parts = date.split('/');
    return DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[1]), // month
      int.parse(parts[0]), // day
    );
  }

  // Validate that end year is after start year
  static String? validateEndYear(String? endYear, String? startYear) {
    if (endYear == null || endYear.trim().isEmpty) {
      return 'End year is required';
    }
    if (startYear == null || startYear.trim().isEmpty) {
      return null;
    }
    
    int? end = int.tryParse(endYear);
    int? start = int.tryParse(startYear);
    
    if (end == null || start == null) {
      return 'Enter valid years';
    }
    
    if (end < start) {
      return 'End year must be after start year';
    }
    
    return null;
  }

  // Designation validation
  static String? validateDesignation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Designation is required';
    }
    return null;
  }

  // Department validation
  static String? validateDepartment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Department is required';
    }
    return null;
  }
}

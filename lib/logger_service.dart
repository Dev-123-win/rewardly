import 'package:logger/logger.dart';

/// A singleton service for logging messages throughout the application.
/// It uses the `logger` package for enhanced, colorful, and structured logging.
class LoggerService {
  // Private constructor to prevent direct instantiation.
  LoggerService._();

  // The single instance of the LoggerService.
  static final LoggerService _instance = LoggerService._();

  // Factory constructor to return the singleton instance.
  factory LoggerService() => _instance;

  // Configures the logger with a PrettyPrinter for readable output.
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed in the log.
      errorMethodCount: 8, // Number of method calls if a stacktrace is provided.
      lineLength: 120, // The width of the log output.
      colors: true, // Enables colorful log messages for better readability.
      printEmojis: true, // Prints an emoji for each log message type.
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Includes a timestamp with each log message.
    ),
  );

  /// Logs a debug message.
  /// Use for detailed information helpful in debugging.
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an informational message.
  /// Use for general application flow and significant events.
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  /// Use for potentially harmful situations or unexpected events.
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  /// Use for errors that prevent normal operation but might be recoverable.
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a fatal error message.
  /// Use for critical errors that cause the application to crash or become unusable.
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

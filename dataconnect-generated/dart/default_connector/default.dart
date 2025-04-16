library;

class DefaultConnector {
  static const String region = 'us-central1';
  static const String connectorName = 'default';
  static const String projectName = 'mmanage';

  DefaultConnector();

  static DefaultConnector get instance {
    return DefaultConnector();
  }

  // Add any other methods or properties you need for your connector
}


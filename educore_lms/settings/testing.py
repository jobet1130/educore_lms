# Testing settings
from .base import *

# Override settings for testing
DEBUG = True

# Use in-memory database for faster tests
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}

# Override with environment variable if provided
if "DATABASE_URL" in os.environ:
    DATABASES = {"default": dj_database_url.config(default=config("DATABASE_URL"))}


# Disable migrations for faster tests
class DisableMigrations:
    def __contains__(self, item):
        return True

    def __getitem__(self, item):
        return None


# Uncomment the line below to disable migrations in tests
# MIGRATION_MODULES = DisableMigrations()

# Test-specific settings
PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.MD5PasswordHasher",  # Faster for tests
]

# Disable logging during tests
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "handlers": {
        "null": {
            "class": "logging.NullHandler",
        },
    },
    "root": {
        "handlers": ["null"],
    },
}

# Email backend for testing
EMAIL_BACKEND = "django.core.mail.backends.locmem.EmailBackend"

# Cache settings for testing
CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
    }
}

# Static files settings for testing
STATIC_URL = "/static/"
STATICFILES_STORAGE = "django.contrib.staticfiles.storage.StaticFilesStorage"

# Media files settings for testing
MEDIA_URL = "/media/"
MEDIA_ROOT = os.path.join(BASE_DIR, "test_media")

# Security settings for testing
SECRET_KEY = config(
    "SECRET_KEY",
    default="test-secret-key-not-for-production",
)
ALLOWED_HOSTS = ["localhost", "127.0.0.1", "testserver"]

# Test runner settings
TEST_RUNNER = "django.test.runner.DiscoverRunner"

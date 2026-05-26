.PHONY: release build clean

# Usage: make release version=X.Y.Z
# Tags the current commit as vX.Y.Z and pushes it. A GitHub Actions workflow
# (.github/workflows/release.yml) then builds sdist+wheel and uploads to PyPI
# via Trusted Publishing.
release:
	@if [ -z "$(version)" ]; then \
		echo "ERROR: version is required. Usage: make release version=X.Y.Z"; \
		exit 1; \
	fi
	@echo "$(version)" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+([abrc.+-].*)?$$' || { \
		echo "ERROR: version '$(version)' is not a PEP 440 release (expected X.Y.Z)"; \
		exit 1; \
	}
	@if ! git diff-index --quiet HEAD --; then \
		echo "ERROR: working tree has uncommitted changes"; \
		git status --short; \
		exit 1; \
	fi
	@branch=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$branch" != "master" ]; then \
		echo "ERROR: must release from master (currently on $$branch)"; \
		exit 1; \
	fi
	@git fetch --tags origin
	@if git rev-parse "v$(version)" >/dev/null 2>&1; then \
		echo "ERROR: tag v$(version) already exists"; \
		exit 1; \
	fi
	@echo "Tagging v$(version) and pushing to origin..."
	git tag -a "v$(version)" -m "Release v$(version)"
	git push origin "v$(version)"
	@echo "Done. Watch the release workflow: https://github.com/Acellera/propka/actions"

build:
	python -m pip install --upgrade build
	python -m build

clean:
	rm -rf build dist *.egg-info

SHELL := powershell.exe
.SHELLFLAGS := -NoProfile -Command

-include .env

WEB_PORT ?= 5008
WEB_DEVICE ?= chrome

.PHONY: help get run run-web analyze test format format-check check clean doctor outdated upgrade build-web

help:
	@Write-Host "Available commands:"
	@Write-Host "  make get           Install Flutter dependencies"
	@Write-Host "  make run           Run the app on the default selected device"
	@Write-Host "  make run-web       Run the app on Chrome with a stable web port"
	@Write-Host "  make analyze       Run static analysis"
	@Write-Host "  make test          Run all tests"
	@Write-Host "  make format        Format Dart files"
	@Write-Host "  make format-check  Check Dart formatting without changing files"
	@Write-Host "  make check         Run format-check, analyze, and test"
	@Write-Host "  make clean         Clean generated Flutter build outputs"
	@Write-Host "  make doctor        Check Flutter toolchain health"
	@Write-Host "  make outdated      Show outdated dependencies"
	@Write-Host "  make upgrade       Upgrade dependencies within constraints"
	@Write-Host "  make build-web     Build release web output"

get:
	flutter pub get

run:
	flutter run

run-web:
	flutter run -d $(WEB_DEVICE) --web-port $(WEB_PORT)

analyze:
	flutter analyze

test:
	flutter test

format:
	dart format .

format-check:
	dart format --set-exit-if-changed .

check: format-check analyze test

clean:
	flutter clean

doctor:
	flutter doctor -v

outdated:
	flutter pub outdated

upgrade:
	flutter pub upgrade

build-web:
	flutter build web

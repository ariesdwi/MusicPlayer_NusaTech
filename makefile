
.DEFAULT_GOAL := project

export APP_NAME = MusicPlayer_Nusatech
export BUNDLE_IDENTIFIER = com.innocv.ilovexcodegen

project:
	xcodegen -s project.yml
	open MusicPlayer_Nusatech.xcodeproj

resources:
	mkdir -p "sources/resources/Supporting Files/Generated"
	swiftgen config run --config swiftgen.yml

clean:
	rm -rf *.xcodeproj

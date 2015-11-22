PROJECT=helloworld
VERSION=0.0.1
DEBVERSION=0taotao1
DEBARCH=amd64
REPO=https://github.com/taotao/$(PROJECT).git

PROJECT_SRC_DIR=$(PROJECT)
PROJECT_BUILD_DIR=$(PROJECT)-$(VERSION)

ARCHIVE=$(PROJECT)-$(VERSION).tar.gz
ORIG_ARCHIVE=$(PROJECT)_$(VERSION).orig.tar.gz

.PHONY: all clean deb $(PROJECT_SRC_DIR)/$(ARCHIVE) $(ORIG_ARCHIVE) upload

all: deb

clean:
	rm -rf \
		$(PROJECT_SRC_DIR) \
		$(PROJECT_BUILD_DIR) \
		$(PROJECT)-*.tar.gz \
		$(PROJECT)_*.tar.gz \
		$(PROJECT)_*.build \
		$(PROJECT)_*.changes \
		$(PROJECT)_*.dsc \
		$(PROJECT)_*.deb

$(PROJECT_SRC_DIR)/$(ARCHIVE):
	rm -rf $(PROJECT_SRC_DIR)
	git clone $(REPO) $(PROJECT_SRC_DIR)
	cd $(PROJECT_SRC_DIR) && autoreconf --install && ./configure && make dist

$(ORIG_ARCHIVE): $(PROJECT_SRC_DIR)/$(ARCHIVE)
	cp $< $@

deb: $(ORIG_ARCHIVE)
	pwd
	tar zxvf $(ORIG_ARCHIVE)
	cp -r debian/ $(PROJECT_BUILD_DIR)
	cd $(PROJECT_BUILD_DIR) && debuild -us -uc

upload:
	@curl --fail -X PUT -T $(PROJECT)_$(VERSION)-$(DEBVERSION)_$(DEBARCH).deb -utaotao:$(bintray) "https://api.bintray.com/content/taotao/deb/$(PROJECT)/$(VERSION)/$(PROJECT)_$(VERSION)-$(DEBVERSION)_$(DEBARCH).deb;deb_distribution=unstable;deb_component=main;deb_architecture=amd64"
	@echo "Upload OK..."
	@curl --fail -X POST -utaotao:$(bintray) "https://api.bintray.com/content/taotao/deb/$(PROJECT)/$(VERSION)/publish"
	@echo "Publish OK..."

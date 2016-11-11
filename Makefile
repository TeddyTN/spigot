INFO_FILE     = .info.json
INFO_FILE_TMP = $(INFO_FILE).tmp
INFO_URL      = https://hub.spigotmc.org/versions/

JAVA = java

TOOLS_JAR              = BuildTools.jar
TOOLS_VERSION_FILE     = .tools
TOOLS_VERSION_FILE_TMP = $(TOOLS_VERSION_FILE).tmp

VERSION          = latest
VERSION_FILE     = .version
VERSION_FILE_TMP = $(VERSION_FILE).tmp

SPIGOT_JAR = spigot-$(VERSION).jar
SPIGOT_LOG = spigot-$(VERSION).log

GARBARGE = $(INFO_FILE) $(TOOLS_VERSION_FILE) $(VERSION_FILE) $(SPIGOT_JAR) $(SPIGOT_LOG)

all: $(SPIGOT_JAR)

clean:
	rm -f $(GARBARGE)

$(INFO_FILE):
	curl -LSs -o "$(INFO_FILE_TMP)" "$(INFO_URL)$(VERSION).json"
	cmp "$(INFO_FILE_TMP)" "$@" 2>/dev/null || mv "$(INFO_FILE_TMP)" "$@" && rm -f "$(INFO_FILE_TMP)"

$(SPIGOT_JAR): $(TOOLS_JAR) $(VERSION_FILE)
	java -jar "$(TOOLS_JAR)" --rev "$$(cat $(VERSION_FILE))" | tee $(SPIGOT_LOG)
	mv $$(grep -i 'saved as spigot-.*\.jar' $(SPIGOT_LOG) | grep -o 'spigot-.*\.jar') $@

$(TOOLS_VERSION_FILE): $(INFO_FILE)
	sed -n -e 's/.*"toolsVersion":[[:space:]]*\([[:digit:]]*\).*/\1/p' $< >$(TOOLS_VERSION_FILE_TMP)
	cmp "$(TOOLS_VERSION_FILE_TMP)" "$@" 2>/dev/null || mv "$(TOOLS_VERSION_FILE_TMP)" "$@" && rm -f "$(TOOLS_VERSION_FILE_TMP)"

$(TOOLS_JAR): $(TOOLS_VERSION_FILE)
	curl -LSs -o "$@" "https://hub.spigotmc.org/jenkins/job/BuildTools/$$(cat $<)/artifact/target/BuildTools.jar"

$(VERSION_FILE): $(INFO_FILE)
	sed -n -e 's/.*"name":[[:space:]]*"\([^"]*\)".*/\1/p' $< > $(VERSION_FILE_TMP)
	cmp "$(VERSION_FILE_TMP)" "$@" 2>/dev/null || mv "$(VERSION_FILE_TMP)" "$@" && rm -f "$(VERSION_FILE_TMP)"

.PHONY: $(INFO_FILE) all clean

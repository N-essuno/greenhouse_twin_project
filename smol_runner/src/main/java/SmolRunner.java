import no.uio.microobject.main.Settings;
import no.uio.microobject.runtime.REPL;
import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.HashMap;

public class SmolRunner {

    public static void main(String[] args) {
        org.apache.jena.query.ARQ.init();
        Settings settings = getSettings();

        REPL repl = new REPL(settings);

        repl.command("verbose", "true");

        repl.command("read",
            "src/main/resources/test_java_runner.smol");

        repl.command("auto", "");
        repl.command("dump", "out.ttl");
    }

    @NotNull
    private static Settings getSettings() {
        boolean verbose = true;
        boolean materialize = false;
        String kgOutput = "src/main/kg_output/";
        String greenhouseAssetModel = "src/main/resources/greenhouse.ttl";
        String domainPrefix = "http://www.semanticweb.org/gianl/ontologies/2023/1/sirius-greenhouse#";
        String progPrefix = "https://github.com/Edkamb/SemanticObjects/Program#";
        String runPrefix = "https://github.com/Edkamb/SemanticObjects/Run" + System.currentTimeMillis() + "#";
        String langPrefix = "https://github.com/Edkamb/SemanticObjects#";
        HashMap<String, String> extraPrefixes = new HashMap<>();
        boolean useQueryType = false;

        String assetModel = getAssetModel(greenhouseAssetModel);

        return new Settings(
            verbose,
            materialize,
            kgOutput,
            assetModel,
            domainPrefix,
            progPrefix,
            runPrefix,
            langPrefix,
            extraPrefixes,
            useQueryType
        );
    }

    private static String getAssetModel(String assetModel) {
        // Read the asset model from the file
        try {
            return Files.readString(new File(assetModel).toPath());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}

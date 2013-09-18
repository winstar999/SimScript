/*
* generated by Xtext
*/
package nl.dslmeinte.simscript.structure.ui.contentassist.antlr;

import java.util.Collection;
import java.util.Map;
import java.util.HashMap;

import org.antlr.runtime.RecognitionException;
import org.eclipse.xtext.AbstractElement;
import org.eclipse.xtext.ui.editor.contentassist.antlr.AbstractContentAssistParser;
import org.eclipse.xtext.ui.editor.contentassist.antlr.FollowElement;
import org.eclipse.xtext.ui.editor.contentassist.antlr.internal.AbstractInternalContentAssistParser;

import com.google.inject.Inject;

import nl.dslmeinte.simscript.structure.services.SimStructureDslGrammarAccess;

public class SimStructureDslParser extends AbstractContentAssistParser {
	
	@Inject
	private SimStructureDslGrammarAccess grammarAccess;
	
	private Map<AbstractElement, String> nameMappings;
	
	@Override
	protected nl.dslmeinte.simscript.structure.ui.contentassist.antlr.internal.InternalSimStructureDslParser createParser() {
		nl.dslmeinte.simscript.structure.ui.contentassist.antlr.internal.InternalSimStructureDslParser result = new nl.dslmeinte.simscript.structure.ui.contentassist.antlr.internal.InternalSimStructureDslParser(null);
		result.setGrammarAccess(grammarAccess);
		return result;
	}
	
	@Override
	protected String getRuleName(AbstractElement element) {
		if (nameMappings == null) {
			nameMappings = new HashMap<AbstractElement, String>() {
				private static final long serialVersionUID = 1L;
				{
					put(grammarAccess.getDefinedTypeAccess().getAlternatives(), "rule__DefinedType__Alternatives");
					put(grammarAccess.getEnumerationNameAccess().getAlternatives(), "rule__EnumerationName__Alternatives");
					put(grammarAccess.getTypeLiteralAccess().getAlternatives(), "rule__TypeLiteral__Alternatives");
					put(grammarAccess.getSyntheticTypeLiteralAccess().getAlternatives(), "rule__SyntheticTypeLiteral__Alternatives");
					put(grammarAccess.getBuiltinTypesAccess().getAlternatives(), "rule__BuiltinTypes__Alternatives");
					put(grammarAccess.getStructureDefinitionAccess().getGroup(), "rule__StructureDefinition__Group__0");
					put(grammarAccess.getFeatureAccess().getGroup(), "rule__Feature__Group__0");
					put(grammarAccess.getEnumerationDefinitionAccess().getGroup(), "rule__EnumerationDefinition__Group__0");
					put(grammarAccess.getEnumerationLiteralAccess().getGroup(), "rule__EnumerationLiteral__Group__0");
					put(grammarAccess.getListTypeLiteralAccess().getGroup(), "rule__ListTypeLiteral__Group__0");
					put(grammarAccess.getSyntheticTypeLiteralAccess().getGroup_0(), "rule__SyntheticTypeLiteral__Group_0__0");
					put(grammarAccess.getSyntheticTypeLiteralAccess().getGroup_1(), "rule__SyntheticTypeLiteral__Group_1__0");
					put(grammarAccess.getSyntheticTypeLiteralAccess().getGroup_2(), "rule__SyntheticTypeLiteral__Group_2__0");
					put(grammarAccess.getStructureModelAccess().getTypeDefinitionsAssignment(), "rule__StructureModel__TypeDefinitionsAssignment");
					put(grammarAccess.getStructureDefinitionAccess().getNameAssignment_1(), "rule__StructureDefinition__NameAssignment_1");
					put(grammarAccess.getStructureDefinitionAccess().getPersistentAssignment_2(), "rule__StructureDefinition__PersistentAssignment_2");
					put(grammarAccess.getStructureDefinitionAccess().getFeaturesAssignment_4(), "rule__StructureDefinition__FeaturesAssignment_4");
					put(grammarAccess.getFeatureAccess().getNameAssignment_0(), "rule__Feature__NameAssignment_0");
					put(grammarAccess.getFeatureAccess().getOptionalAssignment_1(), "rule__Feature__OptionalAssignment_1");
					put(grammarAccess.getFeatureAccess().getTypeAssignment_3(), "rule__Feature__TypeAssignment_3");
					put(grammarAccess.getEnumerationDefinitionAccess().getNameAssignment_1(), "rule__EnumerationDefinition__NameAssignment_1");
					put(grammarAccess.getEnumerationDefinitionAccess().getLiteralsAssignment_3(), "rule__EnumerationDefinition__LiteralsAssignment_3");
					put(grammarAccess.getEnumerationLiteralAccess().getNameAssignment_0(), "rule__EnumerationLiteral__NameAssignment_0");
					put(grammarAccess.getEnumerationLiteralAccess().getDisplayNameAssignment_2(), "rule__EnumerationLiteral__DisplayNameAssignment_2");
					put(grammarAccess.getBuiltinTypeLiteralAccess().getBuiltinAssignment(), "rule__BuiltinTypeLiteral__BuiltinAssignment");
					put(grammarAccess.getDefinedTypeLiteralAccess().getTypeAssignment(), "rule__DefinedTypeLiteral__TypeAssignment");
					put(grammarAccess.getListTypeLiteralAccess().getItemTypeAssignment_1(), "rule__ListTypeLiteral__ItemTypeAssignment_1");
				}
			};
		}
		return nameMappings.get(element);
	}
	
	@Override
	protected Collection<FollowElement> getFollowElements(AbstractInternalContentAssistParser parser) {
		try {
			nl.dslmeinte.simscript.structure.ui.contentassist.antlr.internal.InternalSimStructureDslParser typedParser = (nl.dslmeinte.simscript.structure.ui.contentassist.antlr.internal.InternalSimStructureDslParser) parser;
			typedParser.entryRuleStructureModel();
			return typedParser.getFollowElements();
		} catch(RecognitionException ex) {
			throw new RuntimeException(ex);
		}		
	}
	
	@Override
	protected String[] getInitialHiddenTokens() {
		return new String[] { "RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT" };
	}
	
	public SimStructureDslGrammarAccess getGrammarAccess() {
		return this.grammarAccess;
	}
	
	public void setGrammarAccess(SimStructureDslGrammarAccess grammarAccess) {
		this.grammarAccess = grammarAccess;
	}
}
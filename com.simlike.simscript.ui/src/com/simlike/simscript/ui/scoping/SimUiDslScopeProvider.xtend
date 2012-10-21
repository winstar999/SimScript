package com.simlike.simscript.ui.scoping

import com.google.inject.Inject
import com.simlike.simscript.structure.scoping.SimStructureDslScopeProvider
import com.simlike.simscript.structure.types.TypeExtensions
import com.simlike.simscript.ui.extensions.ExpressionExtensions
import com.simlike.simscript.ui.extensions.MethodExtensions
import com.simlike.simscript.ui.extensions.StatementExtensions
import com.simlike.simscript.ui.extensions.StructuralExtensions
import com.simlike.simscript.ui.extensions.ViewableExtensions
import com.simlike.simscript.ui.simUiDsl.BuiltinFunctionExpression
import com.simlike.simscript.ui.simUiDsl.DefinedViewable
import com.simlike.simscript.ui.simUiDsl.EnumerationLiteralExpression
import com.simlike.simscript.ui.simUiDsl.FeatureAccessExpression
import com.simlike.simscript.ui.simUiDsl.ForStatement
import com.simlike.simscript.ui.simUiDsl.GotoModuleStatement
import com.simlike.simscript.ui.simUiDsl.ListElement
import com.simlike.simscript.ui.simUiDsl.ListRemoveStatement
import com.simlike.simscript.ui.simUiDsl.MethodCallExpression
import com.simlike.simscript.ui.simUiDsl.MethodDefinition
import com.simlike.simscript.ui.simUiDsl.Statement
import com.simlike.simscript.ui.simUiDsl.StructureCreationExpression
import com.simlike.simscript.ui.simUiDsl.TableRowsInvocation
import com.simlike.simscript.ui.simUiDsl.UiModule
import com.simlike.simscript.ui.simUiDsl.ViewableCallSite
import com.simlike.simscript.ui.types.TypeCalculator
import com.simlike.simscript.util.XtextUtil
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.IScope

import static org.eclipse.xtext.scoping.Scopes.*

/**
 * This class takes care of custom <em>scoping</em>, i.e. compiling a list of
 * possible targets for certain cross-references. The actual target is chosen
 * through name-based matching - and, as in Highlander: there can be only one.
 * <p>
 * The specification for the scoping can be found in the grammar and the
 * implementation functions appear in that same order.
 * 
 * @author Meinte Boersma
 */
public class SimUiDslScopeProvider extends SimStructureDslScopeProvider {

	@Inject extension TypeExtensions
	@Inject extension TypeCalculator
	@Inject extension MethodExtensions
	@Inject extension StructuralExtensions
	@Inject extension ViewableExtensions
	@Inject extension StatementExtensions
	@Inject extension ExpressionExtensions

	@Inject extension XtextUtil


	/*
	 * +------------+
	 * | structural |
	 * +------------+
	 */

	def IScope scope_Argument_parameter(ViewableCallSite it, EReference eRef) {
		scopeFor(it.viewable.parameters)
	}

	def IScope scope_Argument_parameter(TableRowsInvocation it, EReference eRef) {
		scopeFor(it.definition.parameters)
	}

	def IScope scope_Argument_parameter(MethodCallExpression it, EReference eRef) {
		scopeFor(it.method.definition.parameters)
	}
	
	def IScope scope_PrincipalArgument_principal(GotoModuleStatement it, EReference eRef) {
		scopeFor(newArrayList(authOption.principal))
	}

	def IScope scope_CredentialArgument_credential(GotoModuleStatement it, EReference eRef) {
		scopeFor(newArrayList(authOption.credential))
	}

	/*
	 * +----------+
	 * | elements |
	 * +----------+
	 */

	/*
	 * +------------+
	 * | statements |
	 * +------------+
	 */

	def IScope scope_ShowModalStatement_viewable(UiModule it, EReference eRef) {
		scopeFor(viewables.filter[component])
	}

	def IScope scope_Argument_parameter(GotoModuleStatement it, EReference eRef) {
	    scopeFor(targetModule.firstScreen.parameters)
	}

	def IScope scope_GotoScreenStatement_viewable(UiModule it, EReference eRef) {
		scopeFor(viewables.filter[screen])
	}
	
	def IScope scope_ListRemoveStatement_feature(ListRemoveStatement it, EReference eRef) {
        scopeFor(listExpr.type.listItemType.structure.features)
    }


	/*
	 * +-------------+
	 * | expressions |
	 * +-------------+
	 */

    def IScope scope_BuiltinFunctionExpression_sortFeature(BuiltinFunctionExpression it, EReference eRef) {
        scopeFor(argument.type.listItemType.structure.features)
    }

	def IScope scope_EnumerationLiteralExpression_literal(EnumerationLiteralExpression it, EReference eRef) {
		scopeFor(enumeration.literals)
	}

	def IScope scope_FeatureAccessExpression_feature(FeatureAccessExpression it, EReference eRef) {
		if( previous.type == null ) {
//			println("[DEBUG] scope_FeatureAccessExpression_feature returns empty scope <== previous.type == null")
			IScope::NULLSCOPE
		} else {
			scopeFor(previous.type.features)
		}
	}

	def IScope scope_FeatureAssignment_feature(StructureCreationExpression it, EReference eRef) {
		scopeFor(it.structure.features)
	}

	def IScope scope_Referable(ListElement it, EReference eRef) {
		val listVariables = newArrayList(it.indexVariable, it.valueVariable)
		val containingListElement = eContainer.containerHaving(typeof(ListElement))
		if( containingListElement != null ) {
			scopeFor(listVariables, scope_Referable(containingListElement, eRef))
		} else {
			scopeFor(listVariables, scope_Referable(containerHaving(typeof(DefinedViewable)), eRef))
		}
	}
	
	def IScope scope_Referable(ForStatement it, EReference eRef) {
        val listVariables = newArrayList(it.indexVariable, it.valueVariable)
        val containingListElement = eContainer.containerHaving(typeof(ForStatement))
        if( containingListElement != null ) {
            scopeFor(listVariables, scope_Referable(containingListElement, eRef))
        } else {
            scopeFor(listVariables, scope_Referable(containerHaving(typeof(Statement)), eRef))
        }
    }

	def IScope scope_Referable(DefinedViewable it, EReference eRef) {
		scopeFor(parameters + values + localMethodDefinitions.map[method], scopeFor(containingModule.topLevelMethods))
	}

	def IScope scope_Referable(MethodDefinition it, EReference eRef) {
		if( method.topLevel ) {
			scopeFor(parameters, scopeFor(containingModule.topLevelMethods))
		} else {
			scopeFor(parameters, scope_Referable(containerHaving(typeof(DefinedViewable)), eRef))
		}
	}

	def IScope scope_Referable(Statement it, EReference eRef) {
		val containingMethod = containerHaving(typeof(MethodDefinition))
		if( containingMethod != null ) {
			scopeFor(precedingLocalValues, scope_Referable(containingMethod, eRef))
		} else {
			super.getScope(it.eContainer, eRef)
		}
	}


	/*
	 * +---------------------+
	 * | debugging functions |
	 * +---------------------+
	 */

	override getScope(EObject eObject, EReference eRef) {
		// hook for debugging:
//		logScopeComputation(it, eRef)
		super.getScope(eObject, eRef)
	}

}

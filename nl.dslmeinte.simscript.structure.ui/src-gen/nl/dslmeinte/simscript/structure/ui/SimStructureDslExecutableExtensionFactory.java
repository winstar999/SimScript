/*
 * generated by Xtext
 */
package nl.dslmeinte.simscript.structure.ui;

import org.eclipse.xtext.ui.guice.AbstractGuiceAwareExecutableExtensionFactory;
import org.osgi.framework.Bundle;

import com.google.inject.Injector;

import nl.dslmeinte.simscript.structure.ui.internal.SimStructureDslActivator;

/**
 * This class was generated. Customizations should only happen in a newly
 * introduced subclass. 
 */
public class SimStructureDslExecutableExtensionFactory extends AbstractGuiceAwareExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return SimStructureDslActivator.getInstance().getBundle();
	}
	
	@Override
	protected Injector getInjector() {
		return SimStructureDslActivator.getInstance().getInjector(SimStructureDslActivator.NL_DSLMEINTE_SIMSCRIPT_STRUCTURE_SIMSTRUCTUREDSL);
	}
	
}
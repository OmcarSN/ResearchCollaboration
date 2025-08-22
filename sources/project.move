module MyModule::ResearchCollaboration {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

    /// Struct representing a research collaboration project
    struct ResearchProject has store, key {
        funding_pool: u64,           // Total funding available for the project
        target_funding: u64,         // Target funding amount needed
        collaborators: vector<address>, // List of researcher addresses
        is_active: bool,             // Project status
    }

    /// Function to initialize a new research project
    public fun create_research_project(
        lead_researcher: &signer, 
        target_funding: u64
    ) {
        let project = ResearchProject {
            funding_pool: 0,
            target_funding,
            collaborators: vector::empty<address>(),
            is_active: true,
        };
        move_to(lead_researcher, project);
    }

    /// Function to join as a collaborator and contribute funding
    public fun join_collaboration(
        collaborator: &signer, 
        project_lead: address, 
        contribution: u64
    ) acquires ResearchProject {
        let project = borrow_global_mut<ResearchProject>(project_lead);
        
        // Ensure project is still active
        assert!(project.is_active, 1);
        
        // Transfer contribution from collaborator to project lead
        let funds = coin::withdraw<AptosCoin>(collaborator, contribution);
        coin::deposit<AptosCoin>(project_lead, funds);
        
        // Update project state
        project.funding_pool = project.funding_pool + contribution;
        let collaborator_addr = signer::address_of(collaborator);
        
        // Add collaborator if not already in the list
        if (!vector::contains(&project.collaborators, &collaborator_addr)) {
            vector::push_back(&mut project.collaborators, collaborator_addr);
        };
        
        // Mark project as funded if target is reached
        if (project.funding_pool >= project.target_funding) {
            project.is_active = false;
        };
    }
}
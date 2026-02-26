/datum/species/human/unit_test_mutant_spy
	var/handle_body_calls = 0
	var/handle_mutant_bodyparts_calls = 0
	var/list/handle_body_block_recursive_args = list()
	var/list/handle_mutant_block_recursive_args = list()

/datum/species/human/unit_test_mutant_spy/proc/reset_spy()
	handle_body_calls = 0
	handle_mutant_bodyparts_calls = 0
	handle_body_block_recursive_args.Cut()
	handle_mutant_block_recursive_args.Cut()

/datum/species/human/unit_test_mutant_spy/handle_body(mob/living/carbon/human/H, block_recursive_calls = FALSE)
	handle_body_calls++
	handle_body_block_recursive_args += block_recursive_calls
	return ..()

/datum/species/human/unit_test_mutant_spy/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour, block_recursive_calls = FALSE)
	handle_mutant_bodyparts_calls++
	handle_mutant_block_recursive_args += block_recursive_calls
	return

/datum/unit_test/mutant_update_batching_base
/datum/unit_test/mutant_update_batching_base/Run()
	return

/datum/unit_test/mutant_update_batching_base/proc/allocate_spy_human()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
	if(!H?.dna)
		TEST_FAIL("Allocated human did not have DNA.")
		return null

	H.set_species(/datum/species/human/unit_test_mutant_spy, FALSE)
	var/datum/species/human/unit_test_mutant_spy/S = H.dna.species
	if(!S)
		TEST_FAIL("Failed to install spy species.")
		return null

	S.reset_spy()
	H.block_mutant_updates = FALSE
	return H

/datum/unit_test/mutant_update_batching_base/proc/get_spy_species(mob/living/carbon/human/H)
	return H?.dna?.species

/datum/unit_test/mutant_update_block_flag_direct
	parent_type = /datum/unit_test/mutant_update_batching_base

/datum/unit_test/mutant_update_block_flag_direct/Run()
	var/mob/living/carbon/human/H = allocate_spy_human()
	TEST_ASSERT_NOTNULL(H, "Failed to allocate spy human.")
	var/datum/species/human/unit_test_mutant_spy/S = get_spy_species(H)
	TEST_ASSERT_NOTNULL(S, "Spy species missing after allocation.")

	H.block_mutant_updates = TRUE
	H.update_mutant_bodyparts()
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 0, "Blocked update_mutant_bodyparts() should not call species handler.")

	H.block_mutant_updates = FALSE
	H.update_mutant_bodyparts()
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 1, "Unblocked update_mutant_bodyparts() should call species handler once.")
	TEST_ASSERT_EQUAL(S.handle_mutant_block_recursive_args[1], FALSE, "Default block_recursive_calls should forward as FALSE.")

/datum/unit_test/mutant_update_direct_forwards_recursive_arg
	parent_type = /datum/unit_test/mutant_update_batching_base

/datum/unit_test/mutant_update_direct_forwards_recursive_arg/Run()
	var/mob/living/carbon/human/H = allocate_spy_human()
	TEST_ASSERT_NOTNULL(H, "Failed to allocate spy human.")
	var/datum/species/human/unit_test_mutant_spy/S = get_spy_species(H)
	TEST_ASSERT_NOTNULL(S, "Spy species missing after allocation.")

	H.update_mutant_bodyparts(TRUE)
	H.update_mutant_bodyparts(FALSE)

	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 2, "Direct mutant updates should call species handler per invocation when unblocked.")
	TEST_ASSERT_EQUAL(S.handle_mutant_block_recursive_args[1], TRUE, "TRUE block_recursive_calls should be forwarded.")
	TEST_ASSERT_EQUAL(S.handle_mutant_block_recursive_args[2], FALSE, "FALSE block_recursive_calls should be forwarded.")

/datum/unit_test/mutant_update_block_flag_handle_body
	parent_type = /datum/unit_test/mutant_update_batching_base

/datum/unit_test/mutant_update_block_flag_handle_body/Run()
	var/mob/living/carbon/human/H = allocate_spy_human()
	TEST_ASSERT_NOTNULL(H, "Failed to allocate spy human.")
	var/datum/species/human/unit_test_mutant_spy/S = get_spy_species(H)
	TEST_ASSERT_NOTNULL(S, "Spy species missing after allocation.")

	H.block_mutant_updates = TRUE
	S.handle_body(H)
	TEST_ASSERT_EQUAL(S.handle_body_calls, 1, "handle_body() should still run when mutant batching is blocked.")
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 0, "Species.handle_body() should respect H.block_mutant_updates.")

	H.block_mutant_updates = FALSE
	S.handle_body(H)
	TEST_ASSERT_EQUAL(S.handle_body_calls, 2, "Second handle_body() call should be recorded.")
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 1, "Species.handle_body() should call mutant handler when unblocked.")

/datum/unit_test/mutant_update_handle_body_forwards_recursive_arg
	parent_type = /datum/unit_test/mutant_update_batching_base

/datum/unit_test/mutant_update_handle_body_forwards_recursive_arg/Run()
	var/mob/living/carbon/human/H = allocate_spy_human()
	TEST_ASSERT_NOTNULL(H, "Failed to allocate spy human.")
	var/datum/species/human/unit_test_mutant_spy/S = get_spy_species(H)
	TEST_ASSERT_NOTNULL(S, "Spy species missing after allocation.")

	S.handle_body(H, TRUE)
	S.handle_body(H, FALSE)

	TEST_ASSERT_EQUAL(S.handle_body_calls, 2, "Spy handle_body() should record both invocations.")
	TEST_ASSERT_EQUAL(S.handle_body_block_recursive_args[1], TRUE, "handle_body(TRUE) should record TRUE.")
	TEST_ASSERT_EQUAL(S.handle_body_block_recursive_args[2], FALSE, "handle_body(FALSE) should record FALSE.")
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 2, "Unblocked handle_body() should call mutant handler each time.")
	TEST_ASSERT_EQUAL(S.handle_mutant_block_recursive_args[1], TRUE, "handle_body(TRUE) should forward recursive flag to mutant handler.")
	TEST_ASSERT_EQUAL(S.handle_mutant_block_recursive_args[2], FALSE, "handle_body(FALSE) should forward recursive flag to mutant handler.")

/datum/unit_test/mutant_update_update_body_path_respects_block
	parent_type = /datum/unit_test/mutant_update_batching_base

/datum/unit_test/mutant_update_update_body_path_respects_block/Run()
	var/mob/living/carbon/human/H = allocate_spy_human()
	TEST_ASSERT_NOTNULL(H, "Failed to allocate spy human.")
	var/datum/species/human/unit_test_mutant_spy/S = get_spy_species(H)
	TEST_ASSERT_NOTNULL(S, "Spy species missing after allocation.")

	H.block_mutant_updates = TRUE
	H.update_body(FALSE, TRUE)
	TEST_ASSERT_EQUAL(S.handle_body_calls, 1, "update_body() should call species.handle_body().")
	TEST_ASSERT_EQUAL(S.handle_body_block_recursive_args[1], TRUE, "update_body(..., TRUE) should forward recursive arg to handle_body().")
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 0, "Blocked update_body() should suppress mutant handler.")

	H.block_mutant_updates = FALSE
	H.update_body(FALSE, FALSE)
	TEST_ASSERT_EQUAL(S.handle_body_calls, 2, "Second update_body() call should be recorded.")
	TEST_ASSERT_EQUAL(S.handle_body_block_recursive_args[2], FALSE, "update_body(..., FALSE) should forward recursive arg to handle_body().")
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 1, "Unblocked update_body() should allow mutant handler.")
	TEST_ASSERT_EQUAL(S.handle_mutant_block_recursive_args[1], FALSE, "Unblocked update_body(..., FALSE) should forward recursive arg to mutant handler.")

/datum/unit_test/mutant_update_batch_regenerate_icons
	parent_type = /datum/unit_test/mutant_update_batching_base

/datum/unit_test/mutant_update_batch_regenerate_icons/Run()
	var/mob/living/carbon/human/H = allocate_spy_human()
	TEST_ASSERT_NOTNULL(H, "Failed to allocate spy human.")
	var/datum/species/human/unit_test_mutant_spy/S = get_spy_species(H)
	TEST_ASSERT_NOTNULL(S, "Spy species missing after allocation.")

	H.block_mutant_updates = FALSE
	H.regenerate_icons()

	TEST_ASSERT(!H.block_mutant_updates, "regenerate_icons() left block_mutant_updates enabled after a successful run.")
	TEST_ASSERT(S.handle_body_calls >= 1, "regenerate_icons() should pass through update_body()/species.handle_body().")
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 1, "regenerate_icons() should batch intermediate mutant updates into one final call.")
	TEST_ASSERT_EQUAL(S.handle_mutant_block_recursive_args[1], FALSE, "Default regenerate_icons() should forward FALSE recursive flag on final mutant update.")

/datum/unit_test/mutant_update_batch_regenerate_icons_forwards_recursive_arg
	parent_type = /datum/unit_test/mutant_update_batching_base

/datum/unit_test/mutant_update_batch_regenerate_icons_forwards_recursive_arg/Run()
	var/mob/living/carbon/human/H = allocate_spy_human()
	TEST_ASSERT_NOTNULL(H, "Failed to allocate spy human.")
	var/datum/species/human/unit_test_mutant_spy/S = get_spy_species(H)
	TEST_ASSERT_NOTNULL(S, "Spy species missing after allocation.")

	H.regenerate_icons(TRUE)

	TEST_ASSERT(!H.block_mutant_updates, "regenerate_icons(TRUE) should restore block_mutant_updates after completion.")
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 1, "regenerate_icons(TRUE) should still batch to one final mutant handler call.")
	TEST_ASSERT_EQUAL(S.handle_mutant_block_recursive_args[1], TRUE, "regenerate_icons(TRUE) should forward TRUE recursive flag to final mutant handler call.")

/datum/unit_test/mutant_update_batch_regenerate_icons_repeatability
	parent_type = /datum/unit_test/mutant_update_batching_base

/datum/unit_test/mutant_update_batch_regenerate_icons_repeatability/Run()
	var/mob/living/carbon/human/H = allocate_spy_human()
	TEST_ASSERT_NOTNULL(H, "Failed to allocate spy human.")
	var/datum/species/human/unit_test_mutant_spy/S = get_spy_species(H)
	TEST_ASSERT_NOTNULL(S, "Spy species missing after allocation.")

	H.regenerate_icons(FALSE)
	TEST_ASSERT(!H.block_mutant_updates, "First regenerate_icons() should not leave block enabled.")
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 1, "First regenerate_icons() should produce one mutant handler call.")

	H.regenerate_icons(TRUE)
	TEST_ASSERT(!H.block_mutant_updates, "Second regenerate_icons() should not leave block enabled.")
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 2, "Second regenerate_icons() should add exactly one more mutant handler call.")
	TEST_ASSERT_EQUAL(S.handle_mutant_block_recursive_args[1], FALSE, "First regenerate_icons(FALSE) should record FALSE.")
	TEST_ASSERT_EQUAL(S.handle_mutant_block_recursive_args[2], TRUE, "Second regenerate_icons(TRUE) should record TRUE.")

/datum/unit_test/mutant_update_batch_regenerate_icons_preblocked_state
	parent_type = /datum/unit_test/mutant_update_batching_base

/datum/unit_test/mutant_update_batch_regenerate_icons_preblocked_state/Run()
	var/mob/living/carbon/human/H = allocate_spy_human()
	TEST_ASSERT_NOTNULL(H, "Failed to allocate spy human.")
	var/datum/species/human/unit_test_mutant_spy/S = get_spy_species(H)
	TEST_ASSERT_NOTNULL(S, "Spy species missing after allocation.")

	H.block_mutant_updates = TRUE
	H.regenerate_icons()

	TEST_ASSERT(!H.block_mutant_updates, "regenerate_icons() should normalize block flag back to FALSE after successful completion, even if pre-set.")
	TEST_ASSERT_EQUAL(S.handle_mutant_bodyparts_calls, 1, "Pre-set block flag should not suppress the final batched mutant update.")

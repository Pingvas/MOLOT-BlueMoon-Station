/datum/unit_test/runechat_line_estimation_base
/datum/unit_test/runechat_line_estimation_base/Run()
	return

/datum/unit_test/runechat_line_estimation_base/proc/prefix_char_penalty(prefix_count)
	prefix_count = max(0, round(prefix_count))
	var/prefix_px = prefix_count * (CHAT_MESSAGE_ICON_SIZE + 1)
	return CEILING(prefix_px / CHAT_MESSAGE_AVG_CHAR_WIDTH, 1)

/datum/unit_test/runechat_line_estimation_base/proc/first_line_capacity(prefix_count)
	return max(1, CHAT_MESSAGE_CHARS_PER_LINE - prefix_char_penalty(prefix_count))

/datum/unit_test/runechat_line_estimation_base/proc/expected_line_count(message_char_len, prefix_count)
	message_char_len = max(0, round(message_char_len))
	var/first_line_chars = first_line_capacity(prefix_count)

	if(message_char_len <= first_line_chars)
		return 1

	var/remaining_chars = message_char_len - first_line_chars
	return 1 + CEILING(remaining_chars / CHAT_MESSAGE_CHARS_PER_LINE, 1)

/datum/unit_test/runechat_line_estimation_base/proc/max_chars_for_line_count(prefix_count, line_count)
	line_count = max(1, round(line_count))
	var/first_line_chars = first_line_capacity(prefix_count)
	if(line_count == 1)
		return first_line_chars
	return first_line_chars + CHAT_MESSAGE_CHARS_PER_LINE * (line_count - 1)

/datum/unit_test/runechat_line_estimation_boundaries
	parent_type = /datum/unit_test/runechat_line_estimation_base

/datum/unit_test/runechat_line_estimation_boundaries/Run()
	var/chars_per_line = CHAT_MESSAGE_CHARS_PER_LINE

	TEST_ASSERT_EQUAL(calculate_runechat_line_count(0, 0), 1, "Empty messages should still occupy one line.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(1, 0), 1, "Single-char message should occupy one line.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(chars_per_line - 1, 0), 1, "Below width boundary should be one line.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(chars_per_line, 0), 1, "Exact width boundary should be one line.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(chars_per_line + 1, 0), 2, "One char over boundary must wrap.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(chars_per_line * 2, 0), 2, "Exact two-line capacity should be two lines.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(chars_per_line * 2 + 1, 0), 3, "Two lines + 1 char must be three lines.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(chars_per_line * 10, 0), 10, "Large exact multiples should remain exact.")

/datum/unit_test/runechat_line_estimation_prefix_boundaries
	parent_type = /datum/unit_test/runechat_line_estimation_base

/datum/unit_test/runechat_line_estimation_prefix_boundaries/Run()
	for(var/prefix_count in 0 to 8)
		var/first_line_chars = first_line_capacity(prefix_count)
		var/prefix_penalty = prefix_char_penalty(prefix_count)

		TEST_ASSERT(first_line_chars >= 1, "First-line capacity should never drop below 1 (prefix_count=[prefix_count]).")
		TEST_ASSERT(prefix_penalty >= 0, "Prefix penalty should never be negative (prefix_count=[prefix_count]).")

		TEST_ASSERT_EQUAL(calculate_runechat_line_count(first_line_chars, prefix_count), 1, \
			"Exact prefixed first-line fit should not wrap (prefix_count=[prefix_count]).")
		TEST_ASSERT_EQUAL(calculate_runechat_line_count(first_line_chars + 1, prefix_count), 2, \
			"First extra char after prefixed first-line capacity should wrap (prefix_count=[prefix_count]).")

		var/max_two_lines = max_chars_for_line_count(prefix_count, 2)
		TEST_ASSERT_EQUAL(calculate_runechat_line_count(max_two_lines, prefix_count), 2, \
			"Exact two-line prefixed capacity should be two lines (prefix_count=[prefix_count]).")
		TEST_ASSERT_EQUAL(calculate_runechat_line_count(max_two_lines + 1, prefix_count), 3, \
			"Two-line prefixed capacity +1 should wrap to three lines (prefix_count=[prefix_count]).")

/datum/unit_test/runechat_line_estimation_heavy_prefix_clamp
	parent_type = /datum/unit_test/runechat_line_estimation_base

/datum/unit_test/runechat_line_estimation_heavy_prefix_clamp/Run()
	var/heavy_prefixes = CHAT_MESSAGE_CHARS_PER_LINE * 4
	TEST_ASSERT_EQUAL(first_line_capacity(heavy_prefixes), 1, "Heavy prefixes should clamp first-line capacity to one.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(1, heavy_prefixes), 1, "One char should still fit when first-line capacity is clamped.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(2, heavy_prefixes), 2, "Second char must wrap when capacity is clamped to one.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(2 + CHAT_MESSAGE_CHARS_PER_LINE, heavy_prefixes), 3, "Subsequent lines should still use normal capacity.")

/datum/unit_test/runechat_line_estimation_input_sanitization
	parent_type = /datum/unit_test/runechat_line_estimation_base

/datum/unit_test/runechat_line_estimation_input_sanitization/Run()
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(-5, -3), 1, "Negative inputs should be clamped safely.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(5.7, 0), calculate_runechat_line_count(round(5.7), 0), "Helper should round message length like internal code.")
	TEST_ASSERT_EQUAL(calculate_runechat_line_count(20, 1.6), calculate_runechat_line_count(20, round(1.6)), "Helper should round prefix count like internal code.")

/datum/unit_test/runechat_line_estimation_oracle_matrix
	parent_type = /datum/unit_test/runechat_line_estimation_base

/datum/unit_test/runechat_line_estimation_oracle_matrix/Run()
	for(var/prefix_count in 0 to 20)
		for(var/message_char_len in 0 to 512)
			var/expected = expected_line_count(message_char_len, prefix_count)
			var/actual = calculate_runechat_line_count(message_char_len, prefix_count)
			TEST_ASSERT_EQUAL(actual, expected, "Mismatch for len=[message_char_len], prefixes=[prefix_count].")

/datum/unit_test/runechat_line_estimation_monotonic_length
	parent_type = /datum/unit_test/runechat_line_estimation_base

/datum/unit_test/runechat_line_estimation_monotonic_length/Run()
	for(var/prefix_count in 0 to 20)
		var/prev = 0
		for(var/message_char_len in 0 to 512)
			var/current = calculate_runechat_line_count(message_char_len, prefix_count)
			TEST_ASSERT(current >= prev, "Line count decreased when length increased (prefixes=[prefix_count], len=[message_char_len], prev=[prev], current=[current]).")
			TEST_ASSERT(current - prev <= 1, "Line count jumped by more than one for +1 char (prefixes=[prefix_count], len=[message_char_len], prev=[prev], current=[current]).")
			prev = current

/datum/unit_test/runechat_line_estimation_monotonic_prefixes
	parent_type = /datum/unit_test/runechat_line_estimation_base

/datum/unit_test/runechat_line_estimation_monotonic_prefixes/Run()
	for(var/message_char_len in 0 to 512)
		var/prev = 0
		for(var/prefix_count in 0 to 20)
			var/current = calculate_runechat_line_count(message_char_len, prefix_count)
			TEST_ASSERT(current >= prev, "Line count decreased when prefixes increased (len=[message_char_len], prefixes=[prefix_count], prev=[prev], current=[current]).")
			prev = current

/datum/unit_test/runechat_line_estimation_capacity_inversion
	parent_type = /datum/unit_test/runechat_line_estimation_base

/datum/unit_test/runechat_line_estimation_capacity_inversion/Run()
	for(var/prefix_count in 0 to 20)
		for(var/line_count in 1 to 12)
			var/max_for_lines = max_chars_for_line_count(prefix_count, line_count)
			TEST_ASSERT_EQUAL(calculate_runechat_line_count(max_for_lines, prefix_count), line_count, \
				"Exact capacity should map to requested line count (prefixes=[prefix_count], lines=[line_count]).")
			TEST_ASSERT_EQUAL(calculate_runechat_line_count(max_for_lines + 1, prefix_count), line_count + 1, \
				"Capacity +1 should require one more line (prefixes=[prefix_count], lines=[line_count]).")

/datum/unit_test/runechat_line_estimation_large_values
	parent_type = /datum/unit_test/runechat_line_estimation_base

/datum/unit_test/runechat_line_estimation_large_values/Run()
	var/list/cases = list(
		list("len" = 1000, "prefixes" = 0),
		list("len" = 1000, "prefixes" = 8),
		list("len" = 4096, "prefixes" = 0),
		list("len" = 4096, "prefixes" = 20),
		list("len" = 20000, "prefixes" = 50),
	)

	for(var/case in cases)
		var/list/c = case
		var/msg_len = c["len"]
		var/prefixes = c["prefixes"]
		var/expected = expected_line_count(msg_len, prefixes)
		var/actual = calculate_runechat_line_count(msg_len, prefixes)
		TEST_ASSERT(actual >= 1, "Large-value estimate should stay positive (len=[msg_len], prefixes=[prefixes]).")
		TEST_ASSERT_EQUAL(actual, expected, "Large-value estimate mismatch (len=[msg_len], prefixes=[prefixes]).")

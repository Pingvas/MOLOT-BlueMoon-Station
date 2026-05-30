/// Renders a headshot preview tag. `link` must be pre-sanitized (it is interpolated directly into an HTML attribute).
/proc/headshot_preview_html(link, width = 140, height = 140)
	if(!link)
		return ""
	var/static/video_regex = regex("\\.(webm|mp4)", "i")
	if(findtext(link, video_regex))
		return "<video src='[link]' autoplay loop muted playsinline style='border: 1px solid black; object-fit: contain;' width='[width]' height='[height]'></video>"
	return "<img src='[link]' style='border: 1px solid black; object-fit: contain;' width='[width]' height='[height]'>"

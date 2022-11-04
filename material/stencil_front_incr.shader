shader_type spatial;
render_mode unshaded, depth_test_disable;

stencil front {
	test always;
	pass incr;
}
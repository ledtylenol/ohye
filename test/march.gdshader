shader_type canvas_item;
uniform vec3 ro = vec3(0, 0, -3);
uniform float zoom = 0.2;
uniform float thres = 0.001;
uniform float smoothing = 2.0;
float sdSphere(vec3 p, float s) {
	return length(p) - s;
}
float sdBox(vec3 p, vec3 l) {
	vec3 q = abs(p) - l;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y,q.z)), 0.0);
}
float smin(float a, float b, float k) {
	float h =max(k - abs(a-b), 0.0) / k;
	return min(a, b) - h*h*h*k*(1.0 / 6.0);
}
float map(vec3 p) {
	vec3 spherePos = vec3(sin(TIME) * 3., 0, 0);
	float sphere = sdSphere(p - spherePos, 1.);

	float box = sdBox(p, vec3(.75));

	float ground = p.y - .75;
	return smin(ground, smin(sphere, box, smoothing), smoothing / 2.0);
}



void fragment() {
	vec2 res = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = (FRAGCOORD.xy * 2.0 - res.xy) / res.y;
	COLOR.rg = uv;
	uv.y = 1.0 - uv.y;

	//vec3 rd = normalize(vec3(uv, 1));
	//vec3 col = vec3(0);
	//float t = 0.0;
	//
	//for (int i=0; i < 80; i++) {
	//vec3 p = ro + rd * t;
	//
	//float d = map(p);
	//t += d;
	//
	//if (d < thres || t > 100.) break;
	//}
	 //col = vec3(t * zoom);
	//COLOR = vec4(col, 1.0);

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

signal = Signal(35e9,4,"dp-qpsk",2^18);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%pulse shaping to avoid ISI%%%%%%%%%%%%
param.span = 6;
param.sps = 4;
param.roll_off = 1;
param.plot=false;

w = Wave(param);
w.prop(signal)
w.spec(signal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%fiber and span%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param_span.alpha = 0.2;
param_span.D = 17;
param_span.S = 0;
param_span.gamma = 1.2;
param_span.fiber_type = 0;
param_span.lambda = 1550;
param_span.default=false;
span1 = Span(param_span);
span2 = Span(param_span);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%span1,span2 make up a fiber%%%%%%%%%%%%%%%%%
param_fiber.spans = [span1,span2];
param_fiber.is_edfa = false;

fiber = Fiber(param_fiber);

signal.set_signal_power(-2,'dbm'); %%%%%%%%%%%%%set the optical power%%%%%
fiber.prop(signal);%%%signal pass the fiber

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

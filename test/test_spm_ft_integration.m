function test_spm_ft_integration

% TEST test_spm_ft_integration
% TEST ft_prepare_layout ft_prepare_headmodel ft_compute_leadfield ft_prepare_vol_sens

load test_SPM_ft_integration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Layouts

cfg = [];
cfg.elec   = elec;
cfg.rotate = 0;
cfg.showcallinfo = 'no';
lay = ft_prepare_layout(cfg);

cfg = [];
cfg.grad   = grad;
cfg.showcallinfo = 'no';
lay = ft_prepare_layout(cfg);

cfg = [];
cfg.style = '3d';
cfg.rotate = 0;
cfg.grad = grad;
cfg.showcallinfo = 'no';
lay = ft_prepare_layout(cfg);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Coregistration
ft_transform_sens(M1, elec1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Forward models

figure;
cfg              = [];
cfg.feedback     = 'yes';
cfg.showcallinfo = 'no';
cfg.headshape(1) = tess_scalp;
cfg.headshape(2) = tess_oskull;
cfg.headshape(3) = tess_iskull;

% determine the convex hull of the brain, to determine the support points
pnt  = tess_ctx.pnt;
tric = convhulln(pnt);
sel  = unique(tric(:));

% create a triangulation for only the support points
cfg.headshape(4).pnt = pnt(sel, :);
cfg.headshape(4).tri = convhulln(pnt(sel, :));

cfg.method = 'concentricspheres';
vol  = ft_prepare_headmodel(cfg);

clf
ft_plot_vol(vol, 'edgecolor', [0 0 0], 'facealpha', 0);
hold on
ft_plot_sens(elec, 'style', '*b');
clf

[vol, sens] = ft_prepare_vol_sens(vol, elec);
ft_compute_leadfield([30 30 30], sens, vol);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EEG BEMCP

vol = [];
vol.cond   = [0.3300 0.0041 0.3300];
vol.source = 1; % index of source compartment
vol.skin   = 3; % index of skin surface
% brain
vol.bnd(1) = tess_iskull;
% skull
vol.bnd(2) = tess_oskull;
% skin
vol.bnd(3) = tess_scalp;

% create the BEM system matrix
cfg = [];
cfg.method = 'bemcp';
cfg.showcallinfo = 'no';
vol = ft_prepare_headmodel(cfg, vol);

clf
ft_plot_vol(vol, 'edgecolor', [0 0 0], 'facealpha', 0);
hold on
ft_plot_sens(elec, 'style', '*b');
clf

[vol, sens] = ft_prepare_vol_sens(vol, elec);
ft_compute_leadfield([30 30 30], sens, vol);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MEG single sphere

cfg                        = [];
cfg.feedback               = 'yes';
cfg.showcallinfo           = 'no';
cfg.grad                   = grad;
cfg.headshape              = tess_scalp;
cfg.method                 = 'nolte';
vol                        = ft_prepare_headmodel(cfg);

clf
ft_plot_vol(vol, 'edgecolor', [0 0 0], 'facealpha', 0);
hold on
ft_plot_sens(grad, 'style', '*b');
clf

[vol, sens] = ft_prepare_vol_sens(vol, grad);
ft_compute_leadfield([30 30 30], sens, vol);
%% MEG local spheres
cfg                        = [];
cfg.feedback               = 'yes';
cfg.showcallinfo           = 'no';
cfg.grad                   = grad;
cfg.headshape              = tess_scalp;
cfg.radius                 = 85;
cfg.maxradius              = 200;
cfg.method                 = 'localspheres';
vol  = ft_prepare_headmodel(cfg);

clf
ft_plot_vol(vol, 'edgecolor', [0 0 0], 'facealpha', 0);
hold on
ft_plot_sens(grad, 'style', '*b');
clf

[vol, sens] = ft_prepare_vol_sens(vol, grad);
ft_compute_leadfield([30 30 30], sens, vol);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MEG single shell

vol = [];
vol.bnd = tess_iskull;
vol.type = 'singleshell';
vol = ft_convert_units(vol, 'mm');

clf
ft_plot_vol(vol, 'edgecolor', [0 0 0], 'facealpha', 0);
hold on
ft_plot_sens(grad, 'style', '*b');
clf

[vol, sens] = ft_prepare_vol_sens(vol, grad);
ft_compute_leadfield([30 30 30], sens, vol);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test for uniform frequency axis in the output of mtmconvol
[spectrum,ntaper,freqoi,timeoi] = ft_specest_mtmconvol(randn(1, 1651), linspace(-0.5000, 1, 1651), ...
    'taper', 'sine', 'timeoi',  -0.3:0.05:0.75, 'freqoi', 1:48,...
    'timwin', repmat(0.4, 1, 48), 'tapsmofrq', 2*ones(1, 48), 'verbose', 0);
assert(length(unique(diff(freqoi)))==1)
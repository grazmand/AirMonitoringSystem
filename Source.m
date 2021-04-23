classdef Source  < matlab.mixin.SetGet
    properties  (SetAccess=private, GetAccess=public)
        name string
        type string
        time TimeT
        frequency {mustBePositive}
        x double
        y double
        fem RectangularDomainFemModel
        
        shapes double {mustBeInRange(shapes,0,1)}
        elementBelonged {mustBePositive}
        elementNodeIndexes {mustBePositive}
        source_wave_form double
    end
    
    methods
        function source(obj, vals)
            props={'name','type','time','frequency','x','y','fem'};
            obj.set(props,vals)
            %% setting
            obj.set_source_wave_form()
            obj.set_source_shapes()
        end
        %% check methods
        function checkCinematicModel(obj)
            if ~isempty(obj.cm)
                if min(obj.cm.state(1,:))<0 || max(obj.cm.state(1,:))>obj.afemm.range || min(obj.cm.state(3,:))>0 || max(obj.cm.state(3,:))<obj.afemm.depth
                    error('cinematic is not allowed')
                end
            end
        end
        
        function checkSourcePosition(obj)
            if obj.sourceRange<0 || obj.sourceRange>obj.afemm.range || obj.sourceDepth>0 || obj.sourceDepth<obj.afemm.depth
                error('check the source position')
            end
        end
        
        function checkFrequency(obj)
            minF = 4*obj.frequency;
            if (1/obj.time.dt.value)<minF
                error('frequency is not consistent with nyquist theorem')
            end
        end
        
        function checkElementLength(obj)
            wavelength = obj.afemm.soundSpeed/obj.frequency;
            if obj.afemm.elementLength > wavelength/obj.bound
                fprintf('max element length is %0.001d m\n', wavelength/obj.bound)
                error('choose a lower elementLength')
            end
        end
        
        function set_source_wave_form(obj)
            if ismember('impulsive',obj.wave_form_type)
                omega=2*pi*obj.frequency;
                peak=1.5;
                dt=obj.time.dt.value;
                time_steps=obj.time.time_steps;
                wf=(1-omega^2/2*((time_steps *dt)-peak).^2 ).* exp(-omega^2*((obj.time.time_steps*dt)-peak).^2/4);
                obj.source_wave_form=wf;
            elseif ismember('rect_pulse_train',obj.wave_form_type)
                % https://it.mathworks.com/matlabcentral/answers/55423-how-can-i-plot-a-rectangular-train-wave
                obj.waveForm = RectPulseTrain;
                obj.waveForm.type = 'rect_pulse_train';
                obj.waveForm.frequency = obj.frequency;
                obj.waveForm.amplitude = 0.2;
                obj.waveForm.positiveSignalWidth = 50;
                obj.waveForm.periods = 20;
                obj.waveForm.omega = 2 * pi * obj.frequency;
                obj.waveForm.period = 1/obj.waveForm.frequency;
                times_0 = 0:obj.time.dt.value:obj.waveForm.periods*obj.waveForm.period;
                obj.discreteTimeSourceTerm = obj.waveForm.amplitude * square(obj.waveForm.omega*(times_0-obj.waveForm.period*obj.waveForm.positiveSignalWidth/200),...
                    obj.waveForm.positiveSignalWidth);
                obj.discreteTimeSourceTerm = obj.discreteTimeSourceTerm(1:end-1);
            elseif ismember('sinusoidal',obj.wave_form_type)
                obj.waveForm = Sinusoidal;
                obj.waveForm.type = 'sinusoidal';
                obj.waveForm.frequency = obj.frequency;
                obj.waveForm.amplitude = 1;
                obj.discreteTimeSourceTerm = zeros(size(obj.time.times));
                obj.waveForm.minTime = 0;
                obj.waveForm.maxTime = 1;
                if obj.waveForm.maxTime>obj.time.times(end)
                    obj.waveForm.maxTime = obj.time.times(end);
                end
                if obj.waveForm.minTime==0
                    range = 1:...
                        obj.time.timeSteps(round(obj.waveForm.maxTime/obj.time.dt.value));
                    obj.discreteTimeSourceTerm(range) =...
                        obj.waveForm.amplitude*sin(2*pi*obj.waveForm.frequency*range*obj.time.dt.value);
                else
                    range = obj.timeSteps(round(obj.waveForm.minTime/obj.time.dt.value)):...
                        obj.timeSteps(round(obj.waveForm.maxTime/obj.time.dt.value));
                    obj.discreteTimeSourceTerm(range) =...
                        obj.waveForm.amplitude*sin(2*pi*obj.waveForm.frequency*range*obj.time.dt.value);
                end
            end
        end
        
        function set_source_shapes(obj)
            if ismember('static',obj.type)
                for ie=1:obj.fem.mesh.element_size_number
                    IN = inpolygon(obj.x, obj.y, obj.fem.mesh.node_coordinates(1, [obj.fem.mesh.elements(1:3,ie); obj.fem.mesh.elements(1,ie)]),...
                        obj.fem.mesh.node_coordinates(2, [obj.fem.mesh.elements(1:3,ie); obj.fem.mesh.elements(1,ie)]));
                    ON = isPointOnPolyline([obj.x obj.y], obj.fem.mesh.node_coordinates(:, [obj.fem.mesh.elements(1:3,ie); obj.fem.mesh.elements(1,ie)])', 1e-09);
                    if (IN) || (ON)
                        obj.elementBelonged = ie;
                        obj.elementNodeIndexes = obj.fem.mesh.elements(1:3,ie);
                        obj.shapes = getShapes(obj.fem, obj.elementBelonged, [obj.x,obj.y] );
                        break
                    end
                end
            elseif ismember('moving',obj.type)
                disp('-----------moving source shapes computation')
                for k=obj.time.timeSteps
                    fprintf('moving source shapes computation %d/%d\n',k,obj.time.timeSteps(end))
                    array = 1:obj.afemm.mesh.elementSizeNumber;
                    for ie=array
                        IN = inpolygon(obj.cm.state(1,k), obj.cm.state(3,k), obj.afemm.mesh.nodeCoordinates(1, [obj.afemm.mesh.elements(1:3,ie); obj.afemm.mesh.elements(1,ie)]),...
                            obj.afemm.mesh.nodeCoordinates(2, [obj.afemm.mesh.elements(1:3,ie); obj.afemm.mesh.elements(1,ie)]));
                        ON = isPointOnPolyline([obj.cm.state(1,k) obj.cm.state(3,k)], obj.afemm.mesh.nodeCoordinates(:, [obj.afemm.mesh.elements(1:3,ie); obj.afemm.mesh.elements(1,ie)])', 1e-09);
                        if (IN) || (ON)
                            obj.elementBelonged(k) = ie;
                            obj.elementNodeIndexes(:,k) = obj.afemm.mesh.elements(1:3,ie);
                            obj.shapes(:,k) = getShapes(obj.afemm.femModel, obj.elementBelonged(k), [obj.cm.state(1,k),...
                                obj.cm.state(3,k)] );
                            break
                        end
                    end
                end
                fprintf(' \n')
            end
        end
        
        function checkWaveForm(obj, bool)
            if bool==true
                figure
                plot(obj.time.times, obj.source_wave_form)
                tit = sprintf('%s waveform', obj.name);
                xlabel('seconds')
                title(tit)
            end
        end
        
        function plotCinematicPath(obj, bool)
            if bool
                plot(obj.cm.state(1,:),obj.cm.state(3,:),'g>','MarkerSize',10,'LineWidth',3)
            end
        end
        
    end
end
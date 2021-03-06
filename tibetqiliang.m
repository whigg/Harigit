function varargout=tibetqiliang(res,buf)  
% XY=TIBETQILIANG(res,buf)
% 
% Returns the coordinates of the Tibet and Qilian region, which was
% created from locations of glaciers within the region.
% It takes into account neighboring regions, which 
% causes problems when you buffer.
%
% INPUT:
%
% res      0 The standard, default values
%          N Splined values at N times the resolution
% buf      Distance in degrees that the region outline will be enlarged
%          by BUFFERM, not necessarily integer, possibly negative
%          [default: 0]
%
% OUTPUT:
%
% XY       Closed-curved coordinates that result from this process
%
% NOTES: We start with a region outline created by encircling glaciers in
% the Randolph Glacier Inventory 3.2 (http://www.glims.org/RGI/). This
% outline is buffered as requested.  Since buffered regions infringe on
% neighboring regions, we subtract the outlines for neighboring regions.
% This can cause some artifacts near some of the boundary
% intersections, so this function employs the same brushing technique as the
% basin functions for Antarctica. We make the region, plot it, remove
% erroneous points using the brushing tool, and save this new outline.
%
% Not the best solution, but the best I have found so far.
%
% Last modified by charig at princeton.edu, 10/23/2015

defval('res',0)
defval('buf',0)

if ~isstr(res) % Not a demo

  % The directory where you keep the base coordinates
  whereitsat=fullfile(getenv('IFILES'),'GLACIERS','RGI_3_2','REGIONS');

  % Revert to original name if unbuffered
  if res==0 && buf==0
    fnpl=fullfile(whereitsat,'Tibetqiliang.mat');
  elseif buf==0;
    fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','Tibetqiliang',res));
  elseif buf~=0
    fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','Tibetqiliang',res,buf));
  end

  % If you already have a file
  if exist(fnpl,'file')==2 
    load(fnpl)
    if nargout==0
      plot(XY(:,1),XY(:,2),'k-'); axis equal; grid on
    else
      varns={XY};
      varargout=varns(1:nargout);
    end
  else
    % You are about to make a file
    % Do we buffer? Not here, so do it regular
    if buf==0
        if res==0
          % First part 
          load(fullfile(whereitsat,'Tibetqiliang.mat'));
          % We've already checked this file when we made it that it is correct   
        else
          XY=tibetqiliang(0);
          XYb=bezier(XY,res);
          XY=XYb;
        end
    end
  
    if buf ~=0
      % Check if we have this buffer already but only at base resolution, and then change
      % the res on that file
      % This is unlikely since we default to res=10 usually
      fnpl2=fullfile(whereitsat,sprintf('%s-%i-%g.mat','Tibetqiliang',0,buf));
      if exist(fnpl2,'file')==2
          load(fnpl2)
          XYb=bezier(XY,res);
          XY=XYb;
      else
          % We make a new buffer
          disp('Buffering the coastlines... this may take a while');
          XY=tibetqiliang(10);
          if buf > 0
             inout='outPlusInterior';
          else
             inout='in';
          end
          
          % Make it
          [LatB,LonB] = bufferm(XY(:,2),XY(:,1),buf,inout);
          
          % Collect what we have next door
          nd1 = himalayag(10,buf-0.5);
          nd2 = pamirg(10,buf-0.5);
          nd3 = tienshang(10,buf-0.5);
          
          % Start subtracting
          [x1,y1] = polybool('subtraction',LonB,LatB,nd1(:,1),nd1(:,2));
          [x2,y2] = polybool('subtraction',x1,y1,nd2(:,1),nd2(:,2));
          [x,y] = polybool('subtraction',x2,y2,nd3(:,1),nd3(:,2));
          
          
    
          %%%
          % Assembly complete!
          %%%
 
          % Now we look at the new piece, and we know we must fix some edges
          % where the things intersected.
          hdl1=figure;
          plot(x,y);
          title('This plot is used to edit the coastlines.')
    
          fprintf(['The functions ELLESMERE has paused, and made a plot \n'...
          ' of the current coastlines.  These should have some artifacts that \n'...
          'you want to remove.  Here are the instructions to do that:\n \n'])

          fprintf(['DIRECTIONS:  Select the data points you want to remove with \n'...
          'the brush tool.  Then right click and remove them.  After you have\n'...
          ' finished removing the points you want, type return.  \n'...
          'The program will save the \n'...
          'current data in a variable, and then make another plot \n'...
          'for you to confirm you did it right.\n'])
          keyboard
    
          % Get the brushed data from the plot
          pause(0.1);
          brushedData = get(get(get(hdl1,'Children'),'Children'),{'XData', 'Ydata'});
          brushedXData = brushedData{1}';
          brushedYData = brushedData{2}';
    
          figure
          plot(brushedXData,brushedYData)
          title('This figure confirms the new data you selected with the brush.')
    
          fprintf(['The newest figure shows the data you selected with the brush \n'...
          'tool after you finished editing.  If this is correct, type return.\n'...
          '  If this is incorrect, type dbquit and run this program again to redo.\n'])
          keyboard
    
          XY = [brushedXData brushedYData];  
  
      end % end if fnpl2 exist
    
    end % end if buf>0
   
    % Save the file
    save(fnpl,'XY')
    % Output
    varns={XY};
    varargout=varns(1:nargout);
  
  end % end if fnpl exist
  
elseif strcmp(res,'demomake')
      % This demo illustrates the proper order that is needed to make these
      % coordinate files, since there are dependancies.
      % The coordinates need to be created in order of increasing buffer,
      % and ellesmere before baffin
      XY = ellesmere(10,0.2);
      XY = baffin(10,0.2);
      XY = ellesmere(10,0.5);
      XY = baffin(10,0.5);
      XY = ellesmere(10,1);
      XY = baffin(10,1);
      XY = ellesmere(10,1.5);
      XY = baffin(10,1.5);
      XY = ellesmere(10,2.0);
      XY = baffin(10,2.0);
    
    
elseif strcmp(res,'demo1')
      path(path,'~/src/m_map');
      XY1 = ellesmere(10);
      XY2 = ellesmere(10,0.2);
      XY3 = greenland(1,0.5);
      figure
      m_proj('oblique mercator','longitudes',[318 318],'latitudes',[90 50],'aspect',1.0);
      m_grid;
      m_coast('color','k');
      % Original
      m_line(XY1(:,1),XY1(:,2),'color','magenta','linestyle','-');
      % Buffered
      m_line(XY2(:,1),XY2(:,2),'color','blue','linestyle','-');
      m_line(XY3(:,1),XY3(:,2),'color','green','linestyle','-');
      
elseif strcmp(res,'demo2')
      path(path,'~/src/m_map');
      XY1 = ellesmere(10,0.2);
      XY2 = ellesmere(10,0.5);
      XY3 = greenland(1,0.5);
      [x1,y1] = polybool('subtraction',XY3(:,1),XY3(:,2),XY1(:,1),XY1(:,2));
      [x2,y2] = polybool('subtraction',XY2(:,1),XY2(:,2),x1,y1);
      
      figure
      m_proj('oblique mercator','longitudes',[318 318],'latitudes',[90 50],'aspect',1.0);
      m_grid;
      m_coast('color','k');
      % Original
      m_line(x2,y2,'color','magenta','linestyle','-');
      % Buffered
      %m_line(XY2(:,1),XY2(:,2),'color','blue','linestyle','-');
      %m_line(XY3(:,1),XY3(:,2),'color','green','linestyle','-');
  
end
  
  


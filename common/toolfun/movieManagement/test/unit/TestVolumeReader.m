classdef TestVolumeReader < TestProxyReader
    methods
        function self = TestVolumeReader(name)
            self = self@TestProxyReader(name,VolumeReader(MockReader));
        end
        function testCellIndexing(self)
            idxFcn = @(p,c,t,z) p{c,t}(:,:,z);
            self.checkFcnToZ(idxFcn,@loadImage);
        end
        function testZColon(self)
            zColon = @(p,c,t,z) p(c,t).to3D;
            zStack = @(r,c,t,z) r.loadStack(c,t);
            self.checkFcnToZLight(zColon,zStack);
        end
        function testNamedIndexing(self)
            zColon = @(p,c,t,z) p.c(c).t(t).to3D;
            zStack = @(r,c,t,z) r.loadStack(c,t);
            self.checkFcnToZLight(zColon,zStack);
        end

    end
end

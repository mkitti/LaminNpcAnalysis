classdef TestTimeSeriesReader < TestProxyReader
    methods
        function self = TestTimeSeriesReader(name)
            self = self@TestProxyReader(name,TimeSeriesReader(CellReader(MockReader)));
        end
        function testCellIndexing(self)
            idxFcn = @(p,c,t,z) p{c,z}(:,:,t);
            self.checkFcnToZ(idxFcn,@loadImage);
        end
        function testTColon(self)
            zColon = @(p,c,t,z) p(c,z).to3D;
            zStack = @(r,c,t,z) r(c,:,z).to3D;
            self.checkFcnToZLight(zColon,zStack);
        end
        function testNamedIndexing(self)
            zColon = @(p,c,t,z) p.c(c).z(z).to3D;
            zStack = @(r,c,t,z) r.c(c).z(z).to3D;
            self.checkFcnToZLight(zColon,zStack);
        end

    end
end

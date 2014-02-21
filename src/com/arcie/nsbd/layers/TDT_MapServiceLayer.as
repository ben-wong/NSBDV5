package com.arcie.nsbd.layers {
import com.esri.ags.SpatialReference;
import com.esri.ags.geometry.Extent;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.layers.TiledMapServiceLayer;
import com.esri.ags.layers.supportClasses.LOD;
import com.esri.ags.layers.supportClasses.TileInfo;

import flash.net.URLRequest;

/**
 * 重载TiledMapServiceLayer，加载天地图的经纬度坐标瓦片图
 * @author 郑理
 * @version 1.0
 * @updated 07-八月-2013 13:44:39
 */
public class TDT_MapServiceLayer extends TiledMapServiceLayer {
    /**
     * 瓦片图信息
     */
    private var _tileInfo:TileInfo;
    /**
     * 图层服务地址前缀
     */
    private var _baseURL:String;
    /**
     * 初始范围
     */
    private var _initExtent:String;
    /**
     * 服务提供方式
     */
    private var _serviceMode:String;
    /**
     * 图片格式
     */
    private var _imageFormat:String;
    /**
     * 图层编号
     */
    private var _layerId:String;
    /**
     * 瓦片矩阵编号
     */
    private var _tileMatrixSetId:String;

    /**
     * 构造函数
     */
    public function TDT_MapServiceLayer() {
        this._tileInfo = new TileInfo();
        this._initExtent = null;
        this.buildTileInfo();
        setLoaded(true);
    }


    /**
     * 设置图层服务地址前缀
     *
     * @param pbaseurl 图层服务地址前缀
     */
    public function set baseURL(pbaseurl:String):void {
        _baseURL = pbaseurl;
    }

    /**
     * 设置服务访问方式
     *
     * @param pserviceMode 服务访问方式
     */
    public function set serviceMode(pserviceMode:String):void {
        _serviceMode = pserviceMode;
    }

    /**
     * 设置图片格式
     *
     * @param pimageFormat 图片格式
     */
    public function set imageFormat(pimageFormat:String):void {
        _imageFormat = pimageFormat;
    }

    /**
     * 设置图层编号
     *
     * @param playerId 图层编号
     */
    public function set layerId(playerId:String):void {
        _layerId = playerId;
    }

    /**
     * 设置瓦片矩阵编号
     *
     * @param ptileMatrixSetId 瓦片矩阵编号
     */
    public function set tileMatrixSetId(ptileMatrixSetId:String):void {
        _tileMatrixSetId = ptileMatrixSetId;
    }

    /**
     * 得到图层最大范围
     */
    override public function get fullExtent():Extent {
        return new Extent(-180, -90, 180, 90, new SpatialReference(4490));
    }

    /**
     * 设置初始图层范围
     *
     * @param initextent 初始图层范围
     */
    public function set initExtent(initextent:String):void {
        this._initExtent = initextent;
    }

    /**
     * 得到初始图层范围
     */
    override public function get initialExtent():Extent {
        if (this._initExtent == null)
            return new Extent(105, 31, 112, 35, new SpatialReference(4490));
        var coors:Array = this._initExtent.split(",");
        return new Extent(Number(coors[0]), Number(coors[1]), Number(coors[2]), Number(coors[3]), new SpatialReference(4490));
    }

    /**
     * 得到当前坐标系
     */
    override public function get spatialReference():SpatialReference {
        return new SpatialReference(4490);
    }

    /**
     * 瓦片图信息
     */
    override public function get tileInfo():TileInfo {
        return this._tileInfo;
    }

    /**
     * 根据参数构建并返回请求瓦片图层的完整地址
     *
     * @param level  图像级别
     * @param row    瓦片行数
     * @param col    瓦片列数
     */
    override protected function getTileURL(level:Number, row:Number, col:Number):URLRequest {
        var urlRequest:String = _baseURL + "/wmts?Service=WMTS&Request=GetTile&Version=1.0.0" +
                "&Style=Default&Format=" + _imageFormat + "&serviceMode=" + _serviceMode + "&layer=" + _layerId +
                "&TileMatrixSet=" + _tileMatrixSetId + "&TileMatrix=" + level + "&TileRow=" + row + "&TileCol=" + col;
        return new URLRequest(urlRequest);
    }


    /**
     * 设定图层参数，建立图层
     */
    private function buildTileInfo():void {
        this._tileInfo.height = 256;
        this._tileInfo.width = 256;
        this._tileInfo.origin = new MapPoint(-180, 90);
        this._tileInfo.spatialReference = new SpatialReference(4490);
        this._tileInfo.lods = new Array();
        this._tileInfo.lods = [
            new LOD(1, 0.703125, 2.958293554545656E8),
            new LOD(2, 0.351563, 1.479146777272828E8),
            new LOD(3, 0.175781, 7.39573388636414E7),
            new LOD(4, 0.0878906, 3.69786694318207E7),
            new LOD(5, 0.0439453, 1.848933471591035E7),
            new LOD(6, 0.0219727, 9244667.357955175),
            new LOD(7, 0.0109863, 4622333.678977588),
            new LOD(8, 0.00549316, 2311166.839488794),
            new LOD(9, 0.00274658, 1155583.419744397),
            new LOD(10, 0.00137329, 577791.7098721985),
            new LOD(11, 0.000686646, 288895.85493609926),
            new LOD(12, 0.000343323, 144447.92746804963),
            new LOD(13, 0.000171661, 72223.96373402482),
            new LOD(14, 8.58307e-005, 36111.98186701241),
            new LOD(15, 4.29153e-005, 18055.990933506204),
            new LOD(16, 2.14577e-005, 9027.995466753102),
            new LOD(17, 1.07289e-005, 4513.997733376551),
            new LOD(18, 5.36445e-006, 2256.998866688275)
        ];
    }
}
}
package com.arcie.nsbd.mapcontrol
{
import com.arcie.nsbd.mapcontrol.MapCoordinatesShowTool;
import com.arcie.nsbd.pages.FeatureInfoWindow;
import com.arcie.nsbd.pages.MonitoringWindow;
import com.esri.ags.Graphic;
import com.esri.ags.Map;
import com.esri.ags.components.ContentNavigator;
import com.esri.ags.events.MapMouseEvent;
import com.esri.ags.geometry.Geometry;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.layers.GraphicsLayer;
import com.esri.ags.symbols.SimpleFillSymbol;
import com.esri.ags.symbols.SimpleLineSymbol;
import com.esri.ags.symbols.SimpleMarkerSymbol;
import com.esri.ags.tasks.IdentifyTask;
import com.esri.ags.tasks.supportClasses.IdentifyParameters;
import com.esri.ags.tasks.supportClasses.IdentifyResult;

import flash.events.Event;

import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.AsyncResponder;
import mx.rpc.remoting.RemoteObject;

import spark.events.IndexChangeEvent;

public class IdentifyFeature
{
    private var contentNavigator:ContentNavigator;
    public var graphicsLayer:GraphicsLayer;
    public var map:Map;
    public var clickLocation:MapPoint;
    public var identifyTask:IdentifyTask;
    public var clickPtSym:SimpleMarkerSymbol;
    public var smsIdentify:SimpleMarkerSymbol;
    public var slsIdentify:SimpleLineSymbol;
    public var sfsIdentify:SimpleFillSymbol;

    public function IdentifyFeature()
    {

    }
    //查询数据表用到的参数
    public var paramCODE:String;
    public var paramTAB:String;
    /**
     * 初始化句柄
     * @param event
     */
    protected function initializeHandler(event:FlexEvent):void
    {
        contentNavigator = new ContentNavigator();
        contentNavigator.addEventListener(IndexChangeEvent.CHANGE, contentNavigator_indexChangeEventHandler, false, 0, true);
        contentNavigator.addEventListener(Event.CLOSE, contentNavigator_closeEventHandler, false, 0, true);
    }

    /**
     * 点击地图关联句柄
     * @param event
     */
    public function mapClickHandler(event:MapMouseEvent):void
    {
        map.defaultGraphicsLayer.clear();

        //设置识别参数
        var identifyParams:IdentifyParameters = new IdentifyParameters();
        identifyParams.layerOption = IdentifyParameters.LAYER_OPTION_VISIBLE;
        identifyParams.returnGeometry = true;
        identifyParams.tolerance = 5;
        identifyParams.width = map.width;
        identifyParams.height = map.height;
        identifyParams.geometry = event.mapPoint;
        identifyParams.mapExtent = map.extent;
        identifyParams.spatialReference = map.spatialReference;
        //获取点击地图上的点
        clickLocation = event.mapPoint;
        var clickGraphic:Graphic = new Graphic(event.mapPoint, clickPtSym);
        map.defaultGraphicsLayer.add(clickGraphic);

        //执行查询任务并渲染查询结果
        identifyTask.execute(identifyParams, new AsyncResponder(resultFunction, faultFunction));
    }

    /**
     * 结果正确处理函数
     * @param result
     * @param token
     */
    private function resultFunction(results:Array, token:Object = null):void
    {
        if (results && results.length > 0)
        {
            var list:ArrayList = new ArrayList();
            for (var i:int = 0; i < results.length; i++)
            {
                var result:IdentifyResult = results[i];
                list.addItem(result.feature);
            }
//            var mainResult:IdentifyResult = results[0];
//            if(mainResult.layerName == "污水处理厂" ||mainResult.layerName == "水质监测断面" ){
//                PopUpManager.createPopUp( map,MonitoringWindow,true);
//            }
            contentNavigator.dataProvider = list;
            map.infoWindowContent = contentNavigator;
            map.infoWindow.show(clickLocation);

//				将参数赋给类成员变量update by cdliu 2013.08.21 --start--
//				点击到以下这三个图层都到NSBD_RESERVOIR_INFO表中去查找相应的信息
//				if(result.layerName == "丹江口库区边界"){
//					var arr:ArrayList = new ArrayList();
//					var obj:Object = result.feature.attributes as Object;
//					for (var item : * in obj){
//						trace(item+":"+obj[item]);
//						arr.addItem({KEY:item,VALUE:obj[item]});
//					}
//					getFeatureDefaultLayer(arr);
//				} else{
//					if(result.layerName == "大中型水库" || result.layerName == "大型水库" || result.layerName == "丹江口水库" ){
//						paramTAB = "NSBD_RESERVOIR_INFO";
//						paramCODE = result.feature.attributes.CODE;
//					} else {
//						var tab:Object = new TabNameMap().tabNameMap;
//						for (var key:String in tab){
//							if(tab[key] == result.layerName){
//								trace("tabNameMap[key] = " + tab[key]);
//								paramCODE = result.feature.attributes.CODE;
//								paramTAB = key;
//								break;
//							}
//						}
//					}
//					//如果根据涂层没有找到对应的数据表表
//					if(paramTAB != null){
//						//从后台获取满足条件的表信息
//						var fifd : FeatureInfoFromDB = new FeatureInfoFromDB();
//						fifd._tdt = this.map;
//						fifd.getFeatureFromDB(paramCODE,paramTAB);
//						//update by cdliu 2013.08.21  --end--
//					}
//					else
//						Alert.show("还没找到图层的相关信息","Error");
//				}
        }
        map.defaultGraphicsLayer.clear();
    }

    /**
     * 结果错误处理函数
     * @param error
     * @param token
     */
    private function faultFunction(error:Object, token:Object = null):void
    {
        Alert.show(String(error), "Identify Error");
    }

    /**
     * 导航变化事件句柄,当导航变化，重新高亮显示地图要素
     * @param event
     */
    protected function contentNavigator_indexChangeEventHandler(event:IndexChangeEvent):void
    {
        var graphic:Graphic = ContentNavigator(event.currentTarget).selectedItem as Graphic;
        showHighlightCurrentGraphic(graphic);
    }

    /**
     * 导航关闭事件句柄
     * @param event
     */
    protected function contentNavigator_closeEventHandler(event:Event):void
    {
        map.defaultGraphicsLayer.clear();
        graphicsLayer.clear();
    }

    /**
     * 高亮显示当前选中地图元素（点，线，面）
     * @param graphic
     */
    protected function showHighlightCurrentGraphic(graphic:Graphic):void
    {
        graphicsLayer.clear();
        var currentGraphic:Graphic = graphic;
        switch (currentGraphic.geometry.type)
        {
            case Geometry.MAPPOINT:
            {
                currentGraphic.symbol = smsIdentify;
                break;
            }
            case Geometry.POLYLINE:
            {
                currentGraphic.symbol = slsIdentify;
                break;
            }
            case Geometry.POLYGON:
            {
                currentGraphic.symbol = sfsIdentify;
                break;
            }
        }
        graphicsLayer.add(currentGraphic);
    }

    /**
     * 显示鼠标所处的经纬度
     * @param event
     */
    public function showCoordinatesWithMouse(event:FlexEvent):void
    {
        var statusBar:MapCoordinatesShowTool = new MapCoordinatesShowTool();
        statusBar.map = map;
        map.addChild(statusBar);
        initializeHandler(event);
    }
//
//    /**
//     * 显示底层地图的信息
//     */
//    protected var _featureInfoWindow : FeatureInfoWindow;
//    public function getFeatureDefaultLayer(list:ArrayList):void{
//        // Deal with event.result
//        _featureInfoWindow = new FeatureInfoWindow();
//        _featureInfoWindow.tdtW = this.map;
//        PopUpManager.addPopUp(_featureInfoWindow,this.map,false);
//        //PopUpManager.centerPopUp(_featureInfoWindow);
//        _featureInfoWindow.userList.dataProvider = list;
//    }
}
}
package com.arcie.nsbd.mapcontrol
{
	import com.esri.ags.*;
	import com.esri.ags.events.*;
	import com.esri.ags.geometry.MapPoint;
	import flash.events.MouseEvent;
	import flash.text.*;
	import flash.geom.Point;
	import mx.core.*;

	/**
	 * 自定义插件：随鼠标显示地图经纬度
	 * 
	 * @author 刘春东
	 * 
	 * @version 1.0
	 * 
	 * @updated 2013.08.06
	 * 来源：http://www.cnblogs.com/wenjl520/archive/2009/06/02/1494586.html
	 */
	public class MapCoordinatesShowTool extends UIComponent

	{
		private var m_map:Map;
		private var m_stateLabel:TextField;
	
		/**
		 *构造方法
		 */
		public function MapCoordinatesShowTool()
		{
			m_stateLabel = new TextField();
			m_stateLabel.width = 300;

		}
		/**更新显示列表
		 * @param log 列表宽
		 * @param pow 列表长
		 */
		override protected function updateDisplayList(log:Number, pow:Number) : void
		{
			super.updateDisplayList(log, pow);
			return;
		}
		
		/**
		 * 覆盖UIComponent的createChildren方法，创建一个Component子对象
		 */
		override protected function createChildren() : void
		{
			super.createChildren();
			
			var pnt:Point  = new Point;
			if(m_map.loaded)
			{
				var mapPnt:MapPoint = new MapPoint(m_map.extent.xmin,m_map.extent.ymin);
				pnt = m_map.toScreen(mapPnt);
				m_stateLabel.x = pnt.x + 5;
				m_stateLabel.y = pnt.y - 20;
			}
			
			addChild(m_stateLabel);
			return;
		}
		
		/**
		 * 处理鼠标事件句柄，显示鼠标移动经纬度
		 * @param event(MouseEvent)
		 *
		 */
		private function mouseMoveHandler(event:MouseEvent):void
		{
			if(m_map)
			{
				if(m_map.loaded)
				{
					var mapPoint : MapPoint = m_map.toMapFromStage(event.stageX, event.stageY);
					m_stateLabel.text = "经度:"+mapPoint.x.toFixed(2).toString()+"，纬度:"+mapPoint.y.toFixed(2).toString(); 
				}
			}
		}
		
		/**
		 * 处理地图范围变化句柄，重新取点，计算经纬度
		 * @param event(ExtentEvent) 
		 */
		private function extentChangeHandler(event:ExtentEvent):void
		{
			var pnt:Point  = new Point;
			var mapPnt:MapPoint = new MapPoint(m_map.extent.xmin,m_map.extent.ymin);
			pnt = m_map.toScreen(mapPnt);
			
			m_stateLabel.x = pnt.x + 5;
			m_stateLabel.y = pnt.y - 20;
		}
		
		/**
		 * 向地图添加监听器
		 * @param map
		 */
		public function set map(map:Map) : void
		{
			m_map = map;
			m_map.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
			m_map.addEventListener(ExtentEvent.EXTENT_CHANGE,extentChangeHandler);
		}

	}
}
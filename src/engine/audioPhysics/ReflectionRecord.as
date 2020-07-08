package engine.audioPhysics
{
	import engine.interfaces.ISoundObstructable;
	
	public class ReflectionRecord extends Object
	{
		private var _records:Vector.<Record>;
		
		public function ReflectionRecord()
		{
			super();
			_records = new Vector.<Record>();
		}
		
		public function addRecord(original:Source, medium:ISoundObstructable, reflected:Source):Record
		{
			var result:Record = findRecord(original, medium, reflected);
			
			if(result == null) {
				_records.push(new Record(original, medium, reflected));
			}
			
			return result;
		}
		
		public function removeRecord(original:Source, medium:ISoundObstructable, reflected:Source):Record
		{
			var result:Record = findRecord(original, medium, reflected);
			
			if(result != null) {
				_records.splice(_records.indexOf(result), 1);
			}
			return result;
		}
		
		public function removeAllOriginal(original:Source):void
		{
			if(original != null) {
				for(var i:int = _records.length-1; i >= 0; --i) {
					if(_records[i].original == original) {
						removeAllOriginal(_records[i].reflected);
						_records.splice(i, 1);
					}
				}
			}
		}
		
		public function removeAllMedium(medium:ISoundObstructable):void
		{
			if(medium != null) {
				for(var i:int = _records.length-1; i >= 0; --i) {
					if(_records[i].medium == medium) {
						_records.splice(i, 1);
					}
				}
			}
		}
		
		public function removeAllReflected(reflected:Source):void
		{
			if(reflected != null) {
				for(var i:int = _records.length-1; i >= 0; --i) {
					if(_records[i].reflected == reflected) {
						_records.splice(i, 1);
					}
				}
			}
		}
		
		public function getReflected(original:Source, medium:ISoundObstructable):Source
		{
			for each(var r:Record in _records) {
				if(r.original == original && r.medium == medium) {
					return r.reflected;
				}
			}
			
			return null;
		}
		
		public function getReflectedByOriginal(original:Source):Vector.<Source>
		{
			var result:Vector.<Source> = new Vector.<Source>();
			for each(var r:Record in _records) {
				if(r.original == original) {
					result.push(r.reflected);
				}
			}
			return result;
		}
		
		public function getMedium(original:Source, reflected:Source):ISoundObstructable
		{
			for each(var r:Record in _records) {
				if(r.original == original && r.reflected == reflected) {
					return r.medium;
				}
			}
			
			return null;
		}
		
		public function getMediumByReflected(reflected:Source):ISoundObstructable
		{
			for each(var r:Record in _records) {
				if(r.reflected == reflected) {
					return r.medium;
				}
			}
			
			return null;
		}
		
		public function getOriginal(medium:ISoundObstructable, reflected:Source):Source
		{
			for each(var r:Record in _records) {
				if(r.medium == medium && r.reflected == reflected) {
					return r.original;
				}
			}
			
			return null;
		}
		
		public function findRecord(original:Source, medium:ISoundObstructable, reflected:Source):Record
		{
			for each(var r:Record in _records) {
				if(r.isMatched(original, medium, reflected)) {
					return r;
				}
			}
			return null;
		}
		
		public function get length():uint
		{
			return _records.length;
		}
	}
}
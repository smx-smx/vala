[CCode(cheader_filename = "struct.h")]
namespace Vectors {
	[SimpleType,
	 CCode(
		 cname = "vec3",
		 cprefix = "vec3_",
		 copy_function = "vec3_copy"
	 )
	]
	public struct Vector3 {
		public Vector3(){}
	}
}

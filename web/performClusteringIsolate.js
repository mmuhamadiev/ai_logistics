(function dartProgram(){function copyProperties(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
b[q]=a[q]}}function mixinPropertiesHard(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
if(!b.hasOwnProperty(q)){b[q]=a[q]}}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var s=function(){}
s.prototype={p:{}}
var r=new s()
if(!(Object.getPrototypeOf(r)&&Object.getPrototypeOf(r).p===s.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var q=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(q))return true}}catch(p){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){Object.setPrototypeOf(a.prototype,b.prototype)
return}var s=Object.create(b.prototype)
copyProperties(a.prototype,s)
a.prototype=s}}function inheritMany(a,b){for(var s=0;s<b.length;s++){inherit(b[s],a)}}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazy(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){a[b]=d()}a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){var r=d()
if(a[b]!==s){A.kl(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a){a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.fv(b)
return new s(c,this)}:function(){if(s===null)s=A.fv(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.fv(a).prototype
return s}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number"){h+=x}return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var s=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var r=staticTearOffGetter(s)
a[b]=r}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var s=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var r=instanceTearOffGetter(c,s)
a[b]=r}function setOrUpdateInterceptorsByTag(a){var s=v.interceptorsByTag
if(!s){v.interceptorsByTag=a
return}copyProperties(a,s)}function setOrUpdateLeafTags(a){var s=v.leafTags
if(!s){v.leafTags=a
return}copyProperties(a,s)}function updateTypes(a){var s=v.types
var r=s.length
s.push.apply(s,a)
return r}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var s=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},r=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:s(0,0,null,["$0"],0),_instance_1u:s(0,1,null,["$1"],0),_instance_2u:s(0,2,null,["$2"],0),_instance_0i:s(1,0,null,["$0"],0),_instance_1i:s(1,1,null,["$1"],0),_instance_2i:s(1,2,null,["$2"],0),_static_0:r(0,null,["$0"],0),_static_1:r(1,null,["$1"],0),_static_2:r(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var J={
fD(a,b,c,d){return{i:a,p:b,e:c,x:d}},
fz(a){var s,r,q,p,o,n=a[v.dispatchPropertyName]
if(n==null)if($.fA==null){A.k9()
n=a[v.dispatchPropertyName]}if(n!=null){s=n.p
if(!1===s)return n.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return n.i
if(n.e===r)throw A.a(A.bl("Return interceptor for "+A.d(s(a,n))))}q=a.constructor
if(q==null)p=null
else{o=$.dJ
if(o==null)o=$.dJ=v.getIsolateTag("_$dart_js")
p=q[o]}if(p!=null)return p
p=A.ke(a)
if(p!=null)return p
if(typeof a=="function")return B.z
s=Object.getPrototypeOf(a)
if(s==null)return B.m
if(s===Object.prototype)return B.m
if(typeof q=="function"){o=$.dJ
if(o==null)o=$.dJ=v.getIsolateTag("_$dart_js")
Object.defineProperty(q,o,{value:B.j,enumerable:false,writable:true,configurable:true})
return B.j}return B.j},
iy(a,b){if(a<0||a>4294967295)throw A.a(A.a6(a,0,4294967295,"length",null))
return J.iz(new Array(a),b)},
iz(a,b){var s=A.v(a,b.i("z<0>"))
s.$flags=1
return s},
iA(a,b){return J.i9(a,b)},
aB(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.b5.prototype
return J.bZ.prototype}if(typeof a=="string")return J.au.prototype
if(a==null)return J.b6.prototype
if(typeof a=="boolean")return J.b4.prototype
if(Array.isArray(a))return J.z.prototype
if(typeof a!="object"){if(typeof a=="function")return J.ai.prototype
if(typeof a=="symbol")return J.b9.prototype
if(typeof a=="bigint")return J.b7.prototype
return a}if(a instanceof A.l)return a
return J.fz(a)},
aC(a){if(typeof a=="string")return J.au.prototype
if(a==null)return a
if(Array.isArray(a))return J.z.prototype
if(typeof a!="object"){if(typeof a=="function")return J.ai.prototype
if(typeof a=="symbol")return J.b9.prototype
if(typeof a=="bigint")return J.b7.prototype
return a}if(a instanceof A.l)return a
return J.fz(a)},
Q(a){if(a==null)return a
if(Array.isArray(a))return J.z.prototype
if(typeof a!="object"){if(typeof a=="function")return J.ai.prototype
if(typeof a=="symbol")return J.b9.prototype
if(typeof a=="bigint")return J.b7.prototype
return a}if(a instanceof A.l)return a
return J.fz(a)},
hN(a){if(typeof a=="number")return J.at.prototype
if(a==null)return a
if(!(a instanceof A.l))return J.ay.prototype
return a},
k4(a){if(typeof a=="number")return J.at.prototype
if(typeof a=="string")return J.au.prototype
if(a==null)return a
if(!(a instanceof A.l))return J.ay.prototype
return a},
i7(a,b){if(typeof a=="number"&&typeof b=="number")return a/b
return J.hN(a).be(a,b)},
T(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.aB(a).P(a,b)},
fG(a,b){if(typeof a=="number"&&typeof b=="number")return a<=b
return J.hN(a).bf(a,b)},
k(a,b){if(typeof b==="number")if(Array.isArray(a)||typeof a=="string"||A.hQ(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.aC(a).h(a,b)},
i8(a,b,c){if(typeof b==="number")if((Array.isArray(a)||A.hQ(a,a[v.dispatchPropertyName]))&&!(a.$flags&2)&&b>>>0===b&&b<a.length)return a[b]=c
return J.Q(a).n(a,b,c)},
cG(a,b){return J.Q(a).E(a,b)},
fH(a,b){return J.Q(a).a7(a,b)},
i9(a,b){return J.k4(a).X(a,b)},
fa(a,b){return J.Q(a).B(a,b)},
fI(a,b){return J.Q(a).u(a,b)},
fb(a){return J.Q(a).gD(a)},
cH(a){return J.aB(a).gA(a)},
fJ(a){return J.aC(a).gv(a)},
ia(a){return J.Q(a).gK(a)},
aG(a){return J.Q(a).gp(a)},
cI(a){return J.Q(a).gL(a)},
aH(a){return J.aC(a).gk(a)},
fc(a){return J.aB(a).gq(a)},
cJ(a,b,c){return J.Q(a).U(a,b,c)},
ib(a,b){return J.aC(a).sk(a,b)},
ag(a){return J.aB(a).j(a)},
ic(a,b){return J.Q(a).aJ(a,b)},
bV:function bV(){},
b4:function b4(){},
b6:function b6(){},
b8:function b8(){},
aj:function aj(){},
cf:function cf(){},
ay:function ay(){},
ai:function ai(){},
b7:function b7(){},
b9:function b9(){},
z:function z(a){this.$ti=a},
d_:function d_(a){this.$ti=a},
aI:function aI(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
at:function at(){},
b5:function b5(){},
bZ:function bZ(){},
au:function au(){}},A={fj:function fj(){},
ig(a,b,c){if(b.i("m<0>").b(a))return new A.bt(a,b.i("@<0>").t(c).i("bt<1,2>"))
return new A.aq(a,b.i("@<0>").t(c).i("aq<1,2>"))},
h8(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
iN(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
cE(a,b,c){return a},
fB(a){var s,r
for(s=$.aF.length,r=0;r<s;++r)if(a===$.aF[r])return!0
return!1},
iE(a,b,c,d){if(t.W.b(a))return new A.as(a,b,c.i("@<0>").t(d).i("as<1,2>"))
return new A.a5(a,b,c.i("@<0>").t(d).i("a5<1,2>"))},
a3(){return new A.ax("No element")},
al:function al(){},
bO:function bO(a,b){this.a=a
this.$ti=b},
aq:function aq(a,b){this.a=a
this.$ti=b},
bt:function bt(a,b){this.a=a
this.$ti=b},
bp:function bp(){},
a0:function a0(a,b){this.a=a
this.$ti=b},
c1:function c1(a){this.a=a},
d9:function d9(){},
m:function m(){},
D:function D(){},
ak:function ak(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
a5:function a5(a,b,c){this.a=a
this.b=b
this.$ti=c},
as:function as(a,b,c){this.a=a
this.b=b
this.$ti=c},
c4:function c4(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
q:function q(a,b,c){this.a=a
this.b=b
this.$ti=c},
N:function N(a,b,c){this.a=a
this.b=b
this.$ti=c},
ck:function ck(a,b,c){this.a=a
this.b=b
this.$ti=c},
b2:function b2(){},
bG:function bG(){},
hV(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
hQ(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.p.b(a)},
d(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.ag(a)
return s},
bh(a){var s,r=$.fW
if(r==null)r=$.fW=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
iI(a,b){var s,r=/^\s*[+-]?((0x[a-f0-9]+)|(\d+)|([a-z0-9]+))\s*$/i.exec(a)
if(r==null)return null
s=r[3]
if(s!=null)return parseInt(a,10)
if(r[2]!=null)return parseInt(a,16)
return null},
d8(a){return A.iG(a)},
iG(a){var s,r,q,p
if(a instanceof A.l)return A.J(A.ae(a),null)
s=J.aB(a)
if(s===B.w||s===B.A||t.o.b(a)){r=B.k(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.J(A.ae(a),null)},
iJ(a){if(typeof a=="number"||A.e0(a))return J.ag(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.ar)return a.j(0)
return"Instance of '"+A.d8(a)+"'"},
C(a){var s
if(a<=65535)return String.fromCharCode(a)
if(a<=1114111){s=a-65536
return String.fromCharCode((B.d.aZ(s,10)|55296)>>>0,s&1023|56320)}throw A.a(A.a6(a,0,1114111,null,null))},
h1(a,b,c,d,e,f,g,h,i){var s,r,q,p=b-1
if(0<=a&&a<100){a+=400
p-=4800}s=B.d.bg(h,1000)
g+=B.d.b_(h-s,1000)
r=i?Date.UTC(a,p,c,d,e,f,g):new Date(a,p,c,d,e,f,g).valueOf()
q=!0
if(!isNaN(r))if(!(r<-864e13))if(!(r>864e13))q=r===864e13&&s!==0
if(q)return null
return r},
M(a){if(a.date===void 0)a.date=new Date(a.a)
return a.date},
I(a){return a.c?A.M(a).getUTCFullYear()+0:A.M(a).getFullYear()+0},
V(a){return a.c?A.M(a).getUTCMonth()+1:A.M(a).getMonth()+1},
U(a){return a.c?A.M(a).getUTCDate()+0:A.M(a).getDate()+0},
fX(a){return a.c?A.M(a).getUTCHours()+0:A.M(a).getHours()+0},
fZ(a){return a.c?A.M(a).getUTCMinutes()+0:A.M(a).getMinutes()+0},
h_(a){return a.c?A.M(a).getUTCSeconds()+0:A.M(a).getSeconds()+0},
fY(a){return a.c?A.M(a).getUTCMilliseconds()+0:A.M(a).getMilliseconds()+0},
iH(a){var s=a.$thrownJsError
if(s==null)return null
return A.Y(s)},
h0(a,b){var s
if(a.$thrownJsError==null){s=A.a(a)
a.$thrownJsError=s
s.stack=b.j(0)}},
e5(a,b){var s,r="index"
if(!A.hx(b))return new A.Z(!0,b,r,null)
s=J.aH(a)
if(b<0||b>=s)return A.fh(b,s,a,r)
return new A.bi(null,null,!0,b,r,"Value not in range")},
a(a){return A.hP(new Error(),a)},
hP(a,b){var s
if(b==null)b=new A.a7()
a.dartException=b
s=A.km
if("defineProperty" in Object){Object.defineProperty(a,"message",{get:s})
a.name=""}else a.toString=s
return a},
km(){return J.ag(this.dartException)},
aD(a){throw A.a(a)},
hU(a,b){throw A.hP(b,a)},
aE(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.hU(A.jn(a,b,c),s)},
jn(a,b,c){var s,r,q,p,o,n,m,l,k
if(typeof b=="string")s=b
else{r="[]=;add;removeWhere;retainWhere;removeRange;setRange;setInt8;setInt16;setInt32;setUint8;setUint16;setUint32;setFloat32;setFloat64".split(";")
q=r.length
p=b
if(p>q){c=p/q|0
p%=q}s=r[p]}o=typeof c=="string"?c:"modify;remove from;add to".split(";")[c]
n=t.j.b(a)?"list":"ByteData"
m=a.$flags|0
l="a "
if((m&4)!==0)k="constant "
else if((m&2)!==0){k="unmodifiable "
l="an "}else k=(m&1)!==0?"fixed-length ":""
return new A.bm("'"+s+"': Cannot "+o+" "+l+k+n)},
b_(a){throw A.a(A.B(a))},
a8(a){var s,r,q,p,o,n
a=A.kk(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.v([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.de(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
df(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
h9(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
fk(a,b){var s=b==null,r=s?null:b.method
return new A.c_(a,r,s?null:b.receiver)},
S(a){if(a==null)return new A.d7(a)
if(a instanceof A.b1)return A.ao(a,a.a)
if(typeof a!=="object")return a
if("dartException" in a)return A.ao(a,a.dartException)
return A.jU(a)},
ao(a,b){if(t.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
jU(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.d.aZ(r,16)&8191)===10)switch(q){case 438:return A.ao(a,A.fk(A.d(s)+" (Error "+q+")",null))
case 445:case 5007:A.d(s)
return A.ao(a,new A.bg())}}if(a instanceof TypeError){p=$.hX()
o=$.hY()
n=$.hZ()
m=$.i_()
l=$.i2()
k=$.i3()
j=$.i1()
$.i0()
i=$.i5()
h=$.i4()
g=p.I(s)
if(g!=null)return A.ao(a,A.fk(s,g))
else{g=o.I(s)
if(g!=null){g.method="call"
return A.ao(a,A.fk(s,g))}else if(n.I(s)!=null||m.I(s)!=null||l.I(s)!=null||k.I(s)!=null||j.I(s)!=null||m.I(s)!=null||i.I(s)!=null||h.I(s)!=null)return A.ao(a,new A.bg())}return A.ao(a,new A.cj(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.bj()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.ao(a,new A.Z(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.bj()
return a},
Y(a){var s
if(a instanceof A.b1)return a.b
if(a==null)return new A.bB(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.bB(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
eg(a){if(a==null)return J.cH(a)
if(typeof a=="object")return A.bh(a)
return J.cH(a)},
k3(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.n(0,a[s],a[r])}return b},
jx(a,b,c,d,e,f){switch(b){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.a(A.is("Unsupported number of arguments for wrapped closure"))},
aZ(a,b){var s=a.$identity
if(!!s)return s
s=A.k0(a,b)
a.$identity=s
return s},
k0(a,b){var s
switch(b){case 0:s=a.$0
break
case 1:s=a.$1
break
case 2:s=a.$2
break
case 3:s=a.$3
break
case 4:s=a.$4
break
default:s=null}if(s!=null)return s.bind(a)
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.jx)},
il(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.da().constructor.prototype):Object.create(new A.b0(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.fO(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.ih(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.fO(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
ih(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.a("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.id)}throw A.a("Error in functionType of tearoff")},
ii(a,b,c,d){var s=A.fN
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
fO(a,b,c,d){if(c)return A.ik(a,b,d)
return A.ii(b.length,d,a,b)},
ij(a,b,c,d){var s=A.fN,r=A.ie
switch(b?-1:a){case 0:throw A.a(new A.cg("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
ik(a,b,c){var s,r
if($.fL==null)$.fL=A.fK("interceptor")
if($.fM==null)$.fM=A.fK("receiver")
s=b.length
r=A.ij(s,c,a,b)
return r},
fv(a){return A.il(a)},
id(a,b){return A.dV(v.typeUniverse,A.ae(a.a),b)},
fN(a){return a.a},
ie(a){return a.b},
fK(a){var s,r,q,p=new A.b0("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.a(A.ap("Field name "+a+" not found.",null))},
kQ(a){throw A.a(new A.cp(a))},
k5(a){return v.getIsolateTag(a)},
ke(a){var s,r,q,p,o,n=$.hO.$1(a),m=$.e6[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.ea[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=$.hJ.$2(a,n)
if(q!=null){m=$.e6[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.ea[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.ef(s)
$.e6[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.ea[n]=s
return s}if(p==="-"){o=A.ef(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.hS(a,s)
if(p==="*")throw A.a(A.bl(n))
if(v.leafTags[n]===true){o=A.ef(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.hS(a,s)},
hS(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.fD(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
ef(a){return J.fD(a,!1,null,!!a.$iK)},
kg(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.ef(s)
else return J.fD(s,c,null,null)},
k9(){if(!0===$.fA)return
$.fA=!0
A.ka()},
ka(){var s,r,q,p,o,n,m,l
$.e6=Object.create(null)
$.ea=Object.create(null)
A.k8()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.hT.$1(o)
if(n!=null){m=A.kg(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
k8(){var s,r,q,p,o,n,m=B.o()
m=A.aY(B.p,A.aY(B.q,A.aY(B.l,A.aY(B.l,A.aY(B.r,A.aY(B.t,A.aY(B.u(B.k),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.hO=new A.e7(p)
$.hJ=new A.e8(o)
$.hT=new A.e9(n)},
aY(a,b){return a(b)||b},
k2(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
iB(a,b,c,d,e,f){var s=function(g,h){try{return new RegExp(g,h)}catch(r){return r}}(a,""+""+""+""+"")
if(s instanceof RegExp)return s
throw A.a(A.bT("Illegal RegExp pattern ("+String(s)+")",a))},
kk(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
de:function de(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
bg:function bg(){},
c_:function c_(a,b,c){this.a=a
this.b=b
this.c=c},
cj:function cj(a){this.a=a},
d7:function d7(a){this.a=a},
b1:function b1(a,b){this.a=a
this.b=b},
bB:function bB(a){this.a=a
this.b=null},
ar:function ar(){},
cK:function cK(){},
cL:function cL(){},
dd:function dd(){},
da:function da(){},
b0:function b0(a,b){this.a=a
this.b=b},
cp:function cp(a){this.a=a},
cg:function cg(a){this.a=a},
a4:function a4(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
d3:function d3(a,b){this.a=a
this.b=b
this.c=null},
av:function av(a,b){this.a=a
this.$ti=b},
c2:function c2(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=null
_.$ti=c},
e7:function e7(a){this.a=a},
e8:function e8(a){this.a=a},
e9:function e9(a){this.a=a},
cZ:function cZ(a,b){this.a=a
this.b=b},
dO:function dO(a){this.b=a},
ac(a,b,c){if(a>>>0!==a||a>=c)throw A.a(A.e5(b,a))},
c5:function c5(){},
be:function be(){},
c6:function c6(){},
aL:function aL(){},
bc:function bc(){},
bd:function bd(){},
c7:function c7(){},
c8:function c8(){},
c9:function c9(){},
ca:function ca(){},
cb:function cb(){},
cc:function cc(){},
cd:function cd(){},
bf:function bf(){},
ce:function ce(){},
bw:function bw(){},
bx:function bx(){},
by:function by(){},
bz:function bz(){},
h3(a,b){var s=b.c
return s==null?b.c=A.fs(a,b.x,!0):s},
fl(a,b){var s=b.c
return s==null?b.c=A.bE(a,"aJ",[b.x]):s},
h4(a){var s=a.w
if(s===6||s===7||s===8)return A.h4(a.x)
return s===12||s===13},
iM(a){return a.as},
hM(a){return A.cB(v.typeUniverse,a,!1)},
an(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.an(a1,s,a3,a4)
if(r===s)return a2
return A.hl(a1,r,!0)
case 7:s=a2.x
r=A.an(a1,s,a3,a4)
if(r===s)return a2
return A.fs(a1,r,!0)
case 8:s=a2.x
r=A.an(a1,s,a3,a4)
if(r===s)return a2
return A.hj(a1,r,!0)
case 9:q=a2.y
p=A.aX(a1,q,a3,a4)
if(p===q)return a2
return A.bE(a1,a2.x,p)
case 10:o=a2.x
n=A.an(a1,o,a3,a4)
m=a2.y
l=A.aX(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.fq(a1,n,l)
case 11:k=a2.x
j=a2.y
i=A.aX(a1,j,a3,a4)
if(i===j)return a2
return A.hk(a1,k,i)
case 12:h=a2.x
g=A.an(a1,h,a3,a4)
f=a2.y
e=A.jR(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.hi(a1,g,e)
case 13:d=a2.y
a4+=d.length
c=A.aX(a1,d,a3,a4)
o=a2.x
n=A.an(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.fr(a1,n,c,!0)
case 14:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.a(A.bN("Attempted to substitute unexpected RTI kind "+a0))}},
aX(a,b,c,d){var s,r,q,p,o=b.length,n=A.dW(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.an(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
jS(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.dW(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.an(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
jR(a,b,c,d){var s,r=b.a,q=A.aX(a,r,c,d),p=b.b,o=A.aX(a,p,c,d),n=b.c,m=A.jS(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.ct()
s.a=q
s.b=o
s.c=m
return s},
v(a,b){a[v.arrayRti]=b
return a},
fw(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.k7(s)
return a.$S()}return null},
kb(a,b){var s
if(A.h4(b))if(a instanceof A.ar){s=A.fw(a)
if(s!=null)return s}return A.ae(a)},
ae(a){if(a instanceof A.l)return A.u(a)
if(Array.isArray(a))return A.H(a)
return A.ft(J.aB(a))},
H(a){var s=a[v.arrayRti],r=t.r
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
u(a){var s=a.$ti
return s!=null?s:A.ft(a)},
ft(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.ju(a,s)},
ju(a,b){var s=a instanceof A.ar?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.jd(v.typeUniverse,s.name)
b.$ccache=r
return r},
k7(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.cB(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
k6(a){return A.a_(A.u(a))},
jQ(a){var s=a instanceof A.ar?A.fw(a):null
if(s!=null)return s
if(t.R.b(a))return J.fc(a).a
if(Array.isArray(a))return A.H(a)
return A.ae(a)},
a_(a){var s=a.r
return s==null?a.r=A.hr(a):s},
hr(a){var s,r,q=a.as,p=q.replace(/\*/g,"")
if(p===q)return a.r=new A.dU(a)
s=A.cB(v.typeUniverse,p,!0)
r=s.r
return r==null?s.r=A.hr(s):r},
R(a){return A.a_(A.cB(v.typeUniverse,a,!1))},
jt(a){var s,r,q,p,o,n,m=this
if(m===t.K)return A.ad(m,a,A.jC)
if(!A.af(m))s=m===t._
else s=!0
if(s)return A.ad(m,a,A.jG)
s=m.w
if(s===7)return A.ad(m,a,A.jr)
if(s===1)return A.ad(m,a,A.hy)
r=s===6?m.x:m
q=r.w
if(q===8)return A.ad(m,a,A.jy)
if(r===t.S)p=A.hx
else if(r===t.i||r===t.n)p=A.jB
else if(r===t.N)p=A.jE
else p=r===t.y?A.e0:null
if(p!=null)return A.ad(m,a,p)
if(q===9){o=r.x
if(r.y.every(A.kc)){m.f="$i"+o
if(o==="h")return A.ad(m,a,A.jA)
return A.ad(m,a,A.jF)}}else if(q===11){n=A.k2(r.x,r.y)
return A.ad(m,a,n==null?A.hy:n)}return A.ad(m,a,A.jp)},
ad(a,b,c){a.b=c
return a.b(b)},
js(a){var s,r=this,q=A.jo
if(!A.af(r))s=r===t._
else s=!0
if(s)q=A.jh
else if(r===t.K)q=A.jg
else{s=A.bK(r)
if(s)q=A.jq}r.a=q
return r.a(a)},
cD(a){var s=a.w,r=!0
if(!A.af(a))if(!(a===t._))if(!(a===t.F))if(s!==7)if(!(s===6&&A.cD(a.x)))r=s===8&&A.cD(a.x)||a===t.P||a===t.T
return r},
jp(a){var s=this
if(a==null)return A.cD(s)
return A.kd(v.typeUniverse,A.kb(a,s),s)},
jr(a){if(a==null)return!0
return this.x.b(a)},
jF(a){var s,r=this
if(a==null)return A.cD(r)
s=r.f
if(a instanceof A.l)return!!a[s]
return!!J.aB(a)[s]},
jA(a){var s,r=this
if(a==null)return A.cD(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.l)return!!a[s]
return!!J.aB(a)[s]},
jo(a){var s=this
if(a==null){if(A.bK(s))return a}else if(s.b(a))return a
A.hs(a,s)},
jq(a){var s=this
if(a==null)return a
else if(s.b(a))return a
A.hs(a,s)},
hs(a,b){throw A.a(A.j3(A.ha(a,A.J(b,null))))},
ha(a,b){return A.bS(a)+": type '"+A.J(A.jQ(a),null)+"' is not a subtype of type '"+b+"'"},
j3(a){return new A.bC("TypeError: "+a)},
G(a,b){return new A.bC("TypeError: "+A.ha(a,b))},
jy(a){var s=this,r=s.w===6?s.x:s
return r.x.b(a)||A.fl(v.typeUniverse,r).b(a)},
jC(a){return a!=null},
jg(a){if(a!=null)return a
throw A.a(A.G(a,"Object"))},
jG(a){return!0},
jh(a){return a},
hy(a){return!1},
e0(a){return!0===a||!1===a},
cC(a){if(!0===a)return!0
if(!1===a)return!1
throw A.a(A.G(a,"bool"))},
kF(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.a(A.G(a,"bool"))},
jf(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.a(A.G(a,"bool?"))},
ab(a){if(typeof a=="number")return a
throw A.a(A.G(a,"double"))},
kH(a){if(typeof a=="number")return a
if(a==null)return a
throw A.a(A.G(a,"double"))},
kG(a){if(typeof a=="number")return a
if(a==null)return a
throw A.a(A.G(a,"double?"))},
hx(a){return typeof a=="number"&&Math.floor(a)===a},
kI(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.a(A.G(a,"int"))},
kK(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.a(A.G(a,"int"))},
kJ(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.a(A.G(a,"int?"))},
jB(a){return typeof a=="number"},
kL(a){if(typeof a=="number")return a
throw A.a(A.G(a,"num"))},
kN(a){if(typeof a=="number")return a
if(a==null)return a
throw A.a(A.G(a,"num"))},
kM(a){if(typeof a=="number")return a
if(a==null)return a
throw A.a(A.G(a,"num?"))},
jE(a){return typeof a=="string"},
aA(a){if(typeof a=="string")return a
throw A.a(A.G(a,"String"))},
kO(a){if(typeof a=="string")return a
if(a==null)return a
throw A.a(A.G(a,"String"))},
X(a){if(typeof a=="string")return a
if(a==null)return a
throw A.a(A.G(a,"String?"))},
hF(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.J(a[q],b)
return s},
jM(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.hF(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.J(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
ht(a3,a4,a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=", ",a2=null
if(a5!=null){s=a5.length
if(a4==null)a4=A.v([],t.s)
else a2=a4.length
r=a4.length
for(q=s;q>0;--q)a4.push("T"+(r+q))
for(p=t.X,o=t._,n="<",m="",q=0;q<s;++q,m=a1){n=n+m+a4[a4.length-1-q]
l=a5[q]
k=l.w
if(!(k===2||k===3||k===4||k===5||l===p))j=l===o
else j=!0
if(!j)n+=" extends "+A.J(l,a4)}n+=">"}else n=""
p=a3.x
i=a3.y
h=i.a
g=h.length
f=i.b
e=f.length
d=i.c
c=d.length
b=A.J(p,a4)
for(a="",a0="",q=0;q<g;++q,a0=a1)a+=a0+A.J(h[q],a4)
if(e>0){a+=a0+"["
for(a0="",q=0;q<e;++q,a0=a1)a+=a0+A.J(f[q],a4)
a+="]"}if(c>0){a+=a0+"{"
for(a0="",q=0;q<c;q+=3,a0=a1){a+=a0
if(d[q+1])a+="required "
a+=A.J(d[q+2],a4)+" "+d[q]}a+="}"}if(a2!=null){a4.toString
a4.length=a2}return n+"("+a+") => "+b},
J(a,b){var s,r,q,p,o,n,m=a.w
if(m===5)return"erased"
if(m===2)return"dynamic"
if(m===3)return"void"
if(m===1)return"Never"
if(m===4)return"any"
if(m===6)return A.J(a.x,b)
if(m===7){s=a.x
r=A.J(s,b)
q=s.w
return(q===12||q===13?"("+r+")":r)+"?"}if(m===8)return"FutureOr<"+A.J(a.x,b)+">"
if(m===9){p=A.jT(a.x)
o=a.y
return o.length>0?p+("<"+A.hF(o,b)+">"):p}if(m===11)return A.jM(a,b)
if(m===12)return A.ht(a,b,null)
if(m===13)return A.ht(a.x,b,a.y)
if(m===14){n=a.x
return b[b.length-1-n]}return"?"},
jT(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
je(a,b){var s=a.tR[b]
for(;typeof s=="string";)s=a.tR[s]
return s},
jd(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.cB(a,b,!1)
else if(typeof m=="number"){s=m
r=A.bF(a,5,"#")
q=A.dW(s)
for(p=0;p<s;++p)q[p]=r
o=A.bE(a,b,q)
n[b]=o
return o}else return m},
jb(a,b){return A.hm(a.tR,b)},
ja(a,b){return A.hm(a.eT,b)},
cB(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.hg(A.he(a,null,b,c))
r.set(b,s)
return s},
dV(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.hg(A.he(a,b,c,!0))
q.set(c,r)
return r},
jc(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.fq(a,b,c.w===10?c.y:[c])
p.set(s,q)
return q},
aa(a,b){b.a=A.js
b.b=A.jt
return b},
bF(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.P(null,null)
s.w=b
s.as=c
r=A.aa(a,s)
a.eC.set(c,r)
return r},
hl(a,b,c){var s,r=b.as+"*",q=a.eC.get(r)
if(q!=null)return q
s=A.j8(a,b,r,c)
a.eC.set(r,s)
return s},
j8(a,b,c,d){var s,r,q
if(d){s=b.w
if(!A.af(b))r=b===t.P||b===t.T||s===7||s===6
else r=!0
if(r)return b}q=new A.P(null,null)
q.w=6
q.x=b
q.as=c
return A.aa(a,q)},
fs(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.j7(a,b,r,c)
a.eC.set(r,s)
return s},
j7(a,b,c,d){var s,r,q,p
if(d){s=b.w
r=!0
if(!A.af(b))if(!(b===t.P||b===t.T))if(s!==7)r=s===8&&A.bK(b.x)
if(r)return b
else if(s===1||b===t.F)return t.P
else if(s===6){q=b.x
if(q.w===8&&A.bK(q.x))return q
else return A.h3(a,b)}}p=new A.P(null,null)
p.w=7
p.x=b
p.as=c
return A.aa(a,p)},
hj(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.j5(a,b,r,c)
a.eC.set(r,s)
return s},
j5(a,b,c,d){var s,r
if(d){s=b.w
if(A.af(b)||b===t.K||b===t._)return b
else if(s===1)return A.bE(a,"aJ",[b])
else if(b===t.P||b===t.T)return t.bc}r=new A.P(null,null)
r.w=8
r.x=b
r.as=c
return A.aa(a,r)},
j9(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.P(null,null)
s.w=14
s.x=b
s.as=q
r=A.aa(a,s)
a.eC.set(q,r)
return r},
bD(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
j4(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
bE(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.bD(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.P(null,null)
r.w=9
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.aa(a,r)
a.eC.set(p,q)
return q},
fq(a,b,c){var s,r,q,p,o,n
if(b.w===10){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.bD(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.P(null,null)
o.w=10
o.x=s
o.y=r
o.as=q
n=A.aa(a,o)
a.eC.set(q,n)
return n},
hk(a,b,c){var s,r,q="+"+(b+"("+A.bD(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.P(null,null)
s.w=11
s.x=b
s.y=c
s.as=q
r=A.aa(a,s)
a.eC.set(q,r)
return r},
hi(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.bD(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.bD(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.j4(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.P(null,null)
p.w=12
p.x=b
p.y=c
p.as=r
o=A.aa(a,p)
a.eC.set(r,o)
return o},
fr(a,b,c,d){var s,r=b.as+("<"+A.bD(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.j6(a,b,c,r,d)
a.eC.set(r,s)
return s},
j6(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.dW(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.an(a,b,r,0)
m=A.aX(a,c,r,0)
return A.fr(a,n,m,c!==m)}}l=new A.P(null,null)
l.w=13
l.x=b
l.y=c
l.as=d
return A.aa(a,l)},
he(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
hg(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.iY(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.hf(a,r,l,k,!1)
else if(q===46)r=A.hf(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.am(a.u,a.e,k.pop()))
break
case 94:k.push(A.j9(a.u,k.pop()))
break
case 35:k.push(A.bF(a.u,5,"#"))
break
case 64:k.push(A.bF(a.u,2,"@"))
break
case 126:k.push(A.bF(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.j_(a,k)
break
case 38:A.iZ(a,k)
break
case 42:p=a.u
k.push(A.hl(p,A.am(p,a.e,k.pop()),a.n))
break
case 63:p=a.u
k.push(A.fs(p,A.am(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.hj(p,A.am(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.iX(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.hh(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.j1(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-2)
break
case 43:n=l.indexOf("(",r)
k.push(l.substring(r,n))
k.push(-4)
k.push(a.p)
a.p=k.length
r=n+1
break
default:throw"Bad character "+q}}}m=k.pop()
return A.am(a.u,a.e,m)},
iY(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
hf(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===10)o=o.x
n=A.je(s,o.x)[p]
if(n==null)A.aD('No "'+p+'" in "'+A.iM(o)+'"')
d.push(A.dV(s,o,n))}else d.push(p)
return m},
j_(a,b){var s,r=a.u,q=A.hd(a,b),p=b.pop()
if(typeof p=="string")b.push(A.bE(r,p,q))
else{s=A.am(r,a.e,p)
switch(s.w){case 12:b.push(A.fr(r,s,q,a.n))
break
default:b.push(A.fq(r,s,q))
break}}},
iX(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.hd(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.am(p,a.e,o)
q=new A.ct()
q.a=s
q.b=n
q.c=m
b.push(A.hi(p,r,q))
return
case-4:b.push(A.hk(p,b.pop(),s))
return
default:throw A.a(A.bN("Unexpected state under `()`: "+A.d(o)))}},
iZ(a,b){var s=b.pop()
if(0===s){b.push(A.bF(a.u,1,"0&"))
return}if(1===s){b.push(A.bF(a.u,4,"1&"))
return}throw A.a(A.bN("Unexpected extended operation "+A.d(s)))},
hd(a,b){var s=b.splice(a.p)
A.hh(a.u,a.e,s)
a.p=b.pop()
return s},
am(a,b,c){if(typeof c=="string")return A.bE(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.j0(a,b,c)}else return c},
hh(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.am(a,b,c[s])},
j1(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.am(a,b,c[s])},
j0(a,b,c){var s,r,q=b.w
if(q===10){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==9)throw A.a(A.bN("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.a(A.bN("Bad index "+c+" for "+b.j(0)))},
kd(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.x(a,b,null,c,null,!1)?1:0
r.set(c,s)}if(0===s)return!1
if(1===s)return!0
return!0},
x(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(!A.af(d))s=d===t._
else s=!0
if(s)return!0
r=b.w
if(r===4)return!0
if(A.af(b))return!1
s=b.w
if(s===1)return!0
q=r===14
if(q)if(A.x(a,c[b.x],c,d,e,!1))return!0
p=d.w
s=b===t.P||b===t.T
if(s){if(p===8)return A.x(a,b,c,d.x,e,!1)
return d===t.P||d===t.T||p===7||p===6}if(d===t.K){if(r===8)return A.x(a,b.x,c,d,e,!1)
if(r===6)return A.x(a,b.x,c,d,e,!1)
return r!==7}if(r===6)return A.x(a,b.x,c,d,e,!1)
if(p===6){s=A.h3(a,d)
return A.x(a,b,c,s,e,!1)}if(r===8){if(!A.x(a,b.x,c,d,e,!1))return!1
return A.x(a,A.fl(a,b),c,d,e,!1)}if(r===7){s=A.x(a,t.P,c,d,e,!1)
return s&&A.x(a,b.x,c,d,e,!1)}if(p===8){if(A.x(a,b,c,d.x,e,!1))return!0
return A.x(a,b,c,A.fl(a,d),e,!1)}if(p===7){s=A.x(a,b,c,t.P,e,!1)
return s||A.x(a,b,c,d.x,e,!1)}if(q)return!1
s=r!==12
if((!s||r===13)&&d===t.Z)return!0
o=r===11
if(o&&d===t.cY)return!0
if(p===13){if(b===t.g)return!0
if(r!==13)return!1
n=b.y
m=d.y
l=n.length
if(l!==m.length)return!1
c=c==null?n:n.concat(c)
e=e==null?m:m.concat(e)
for(k=0;k<l;++k){j=n[k]
i=m[k]
if(!A.x(a,j,c,i,e,!1)||!A.x(a,i,e,j,c,!1))return!1}return A.hw(a,b.x,c,d.x,e,!1)}if(p===12){if(b===t.g)return!0
if(s)return!1
return A.hw(a,b,c,d,e,!1)}if(r===9){if(p!==9)return!1
return A.jz(a,b,c,d,e,!1)}if(o&&p===11)return A.jD(a,b,c,d,e,!1)
return!1},
hw(a3,a4,a5,a6,a7,a8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.x(a3,a4.x,a5,a6.x,a7,!1))return!1
s=a4.y
r=a6.y
q=s.a
p=r.a
o=q.length
n=p.length
if(o>n)return!1
m=n-o
l=s.b
k=r.b
j=l.length
i=k.length
if(o+j<n+i)return!1
for(h=0;h<o;++h){g=q[h]
if(!A.x(a3,p[h],a7,g,a5,!1))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.x(a3,p[o+h],a7,g,a5,!1))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.x(a3,k[h],a7,g,a5,!1))return!1}f=s.c
e=r.c
d=f.length
c=e.length
for(b=0,a=0;a<c;a+=3){a0=e[a]
for(;!0;){if(b>=d)return!1
a1=f[b]
b+=3
if(a0<a1)return!1
a2=f[b-2]
if(a1<a0){if(a2)return!1
continue}g=e[a+1]
if(a2&&!g)return!1
g=f[b-1]
if(!A.x(a3,e[a+2],a7,g,a5,!1))return!1
break}}for(;b<d;){if(f[b+1])return!1
b+=3}return!0},
jz(a,b,c,d,e,f){var s,r,q,p,o,n=b.x,m=d.x
for(;n!==m;){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.dV(a,b,r[o])
return A.hn(a,p,null,c,d.y,e,!1)}return A.hn(a,b.y,null,c,d.y,e,!1)},
hn(a,b,c,d,e,f,g){var s,r=b.length
for(s=0;s<r;++s)if(!A.x(a,b[s],d,e[s],f,!1))return!1
return!0},
jD(a,b,c,d,e,f){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.x(a,r[s],c,q[s],e,!1))return!1
return!0},
bK(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.af(a))if(s!==7)if(!(s===6&&A.bK(a.x)))r=s===8&&A.bK(a.x)
return r},
kc(a){var s
if(!A.af(a))s=a===t._
else s=!0
return s},
af(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.X},
hm(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
dW(a){return a>0?new Array(a):v.typeUniverse.sEA},
P:function P(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
ct:function ct(){this.c=this.b=this.a=null},
dU:function dU(a){this.a=a},
cs:function cs(){},
bC:function bC(a){this.a=a},
iO(){var s,r,q={}
if(self.scheduleImmediate!=null)return A.jV()
if(self.MutationObserver!=null&&self.document!=null){s=self.document.createElement("div")
r=self.document.createElement("span")
q.a=null
new self.MutationObserver(A.aZ(new A.dm(q),1)).observe(s,{childList:true})
return new A.dl(q,s,r)}else if(self.setImmediate!=null)return A.jW()
return A.jX()},
iP(a){self.scheduleImmediate(A.aZ(new A.dn(a),0))},
iQ(a){self.setImmediate(A.aZ(new A.dp(a),0))},
iR(a){A.j2(0,a)},
j2(a,b){var s=new A.dS()
s.bm(a,b)
return s},
hz(a){return new A.cl(new A.r($.o,a.i("r<0>")),a.i("cl<0>"))},
hq(a,b){a.$2(0,null)
b.b=!0
return b.a},
ji(a,b){A.jj(a,b)},
hp(a,b){b.Y(a)},
ho(a,b){b.a8(A.S(a),A.Y(a))},
jj(a,b){var s,r,q=new A.dY(b),p=new A.dZ(b)
if(a instanceof A.r)a.b0(q,p,t.z)
else{s=t.z
if(a instanceof A.r)a.ad(q,p,s)
else{r=new A.r($.o,t.aY)
r.a=8
r.c=a
r.b0(q,p,s)}}},
hI(a){var s=function(b,c){return function(d,e){while(true){try{b(d,e)
break}catch(r){e=r
d=c}}}}(a,1)
return $.o.aF(new A.e2(s))},
fe(a){var s
if(t.C.b(a)){s=a.ga0()
if(s!=null)return s}return B.i},
jv(a,b){if($.o===B.c)return null
return null},
hv(a,b){if($.o!==B.c)A.jv(a,b)
if(b==null)if(t.C.b(a)){b=a.ga0()
if(b==null){A.h0(a,B.i)
b=B.i}}else b=B.i
else if(t.C.b(a))A.h0(a,b)
return new A.ah(a,b)},
hb(a,b){var s,r
for(;s=a.a,(s&4)!==0;)a=a.c
if(a===b){b.a2(new A.Z(!0,a,null,"Cannot complete a future with itself"),A.h5())
return}s|=b.a&1
a.a=s
if((s&24)!==0){r=b.a5()
b.a3(a)
A.aR(b,r)}else{r=b.c
b.aY(a)
a.au(r)}},
iT(a,b){var s,r,q={},p=q.a=a
for(;s=p.a,(s&4)!==0;){p=p.c
q.a=p}if(p===b){b.a2(new A.Z(!0,p,null,"Cannot complete a future with itself"),A.h5())
return}if((s&24)===0){r=b.c
b.aY(p)
q.a.au(r)
return}if((s&16)===0&&b.c==null){b.a3(p)
return}b.a^=2
A.aW(null,null,b.b,new A.dz(q,b))},
aR(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g={},f=g.a=a
for(;!0;){s={}
r=f.a
q=(r&16)===0
p=!q
if(b==null){if(p&&(r&1)===0){f=f.c
A.bJ(f.a,f.b)}return}s.a=b
o=b.a
for(f=b;o!=null;f=o,o=n){f.a=null
A.aR(g.a,f)
s.a=o
n=o.a}r=g.a
m=r.c
s.b=p
s.c=m
if(q){l=f.c
l=(l&1)!==0||(l&15)===8}else l=!0
if(l){k=f.b.b
if(p){r=r.b===k
r=!(r||r)}else r=!1
if(r){A.bJ(m.a,m.b)
return}j=$.o
if(j!==k)$.o=k
else j=null
f=f.c
if((f&15)===8)new A.dG(s,g,p).$0()
else if(q){if((f&1)!==0)new A.dF(s,m).$0()}else if((f&2)!==0)new A.dE(g,s).$0()
if(j!=null)$.o=j
f=s.c
if(f instanceof A.r){r=s.a.$ti
r=r.i("aJ<2>").b(f)||!r.y[1].b(f)}else r=!1
if(r){i=s.a.b
if((f.a&24)!==0){h=i.c
i.c=null
b=i.a6(h)
i.a=f.a&30|i.a&1
i.c=f.c
g.a=f
continue}else A.hb(f,i)
return}}i=s.a.b
h=i.c
i.c=null
b=i.a6(h)
f=s.b
r=s.c
if(!f){i.a=8
i.c=r}else{i.a=i.a&1|16
i.c=r}g.a=i
f=i}},
jN(a,b){if(t.Q.b(a))return b.aF(a)
if(t.v.b(a))return a
throw A.a(A.fd(a,"onError",u.c))},
jI(){var s,r
for(s=$.aV;s!=null;s=$.aV){$.bI=null
r=s.b
$.aV=r
if(r==null)$.bH=null
s.a.$0()}},
jP(){$.fu=!0
try{A.jI()}finally{$.bI=null
$.fu=!1
if($.aV!=null)$.fF().$1(A.hK())}},
hH(a){var s=new A.cm(a),r=$.bH
if(r==null){$.aV=$.bH=s
if(!$.fu)$.fF().$1(A.hK())}else $.bH=r.b=s},
jO(a){var s,r,q,p=$.aV
if(p==null){A.hH(a)
$.bI=$.bH
return}s=new A.cm(a)
r=$.bI
if(r==null){s.b=p
$.aV=$.bI=s}else{q=r.b
s.b=q
$.bI=r.b=s
if(q==null)$.bH=s}},
fE(a){var s=null,r=$.o
if(B.c===r){A.aW(s,s,B.c,a)
return}A.aW(s,s,r,r.b1(a))},
kt(a,b){A.cE(a,"stream",t.K)
return new A.cz(b.i("cz<0>"))},
h6(a){return new A.bn(null,null,a.i("bn<0>"))},
hG(a){return},
iS(a,b){if(b==null)b=A.jZ()
if(t.k.b(b))return a.aF(b)
if(t.u.b(b))return b
throw A.a(A.ap("handleError callback must take either an Object (the error), or both an Object (the error) and a StackTrace.",null))},
jK(a,b){A.bJ(a,b)},
jJ(){},
bJ(a,b){A.jO(new A.e1(a,b))},
hC(a,b,c,d){var s,r=$.o
if(r===c)return d.$0()
$.o=c
s=r
try{r=d.$0()
return r}finally{$.o=s}},
hE(a,b,c,d,e){var s,r=$.o
if(r===c)return d.$1(e)
$.o=c
s=r
try{r=d.$1(e)
return r}finally{$.o=s}},
hD(a,b,c,d,e,f){var s,r=$.o
if(r===c)return d.$2(e,f)
$.o=c
s=r
try{r=d.$2(e,f)
return r}finally{$.o=s}},
aW(a,b,c,d){if(B.c!==c)d=c.b1(d)
A.hH(d)},
dm:function dm(a){this.a=a},
dl:function dl(a,b,c){this.a=a
this.b=b
this.c=c},
dn:function dn(a){this.a=a},
dp:function dp(a){this.a=a},
dS:function dS(){},
dT:function dT(a,b){this.a=a
this.b=b},
cl:function cl(a,b){this.a=a
this.b=!1
this.$ti=b},
dY:function dY(a){this.a=a},
dZ:function dZ(a){this.a=a},
e2:function e2(a){this.a=a},
ah:function ah(a,b){this.a=a
this.b=b},
aO:function aO(a,b){this.a=a
this.$ti=b},
aP:function aP(a,b,c,d,e,f,g){var _=this
_.ay=0
_.CW=_.ch=null
_.w=a
_.a=b
_.b=c
_.c=d
_.d=e
_.e=f
_.r=_.f=null
_.$ti=g},
cn:function cn(){},
bn:function bn(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.r=_.e=_.d=null
_.$ti=c},
co:function co(){},
a9:function a9(a,b){this.a=a
this.$ti=b},
aQ:function aQ(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
r:function r(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
dw:function dw(a,b){this.a=a
this.b=b},
dD:function dD(a,b){this.a=a
this.b=b},
dA:function dA(a){this.a=a},
dB:function dB(a){this.a=a},
dC:function dC(a,b,c){this.a=a
this.b=b
this.c=c},
dz:function dz(a,b){this.a=a
this.b=b},
dy:function dy(a,b){this.a=a
this.b=b},
dx:function dx(a,b,c){this.a=a
this.b=b
this.c=c},
dG:function dG(a,b,c){this.a=a
this.b=b
this.c=c},
dH:function dH(a){this.a=a},
dF:function dF(a,b){this.a=a
this.b=b},
dE:function dE(a,b){this.a=a
this.b=b},
cm:function cm(a){this.a=a
this.b=null},
aN:function aN(){},
db:function db(a,b){this.a=a
this.b=b},
dc:function dc(a,b){this.a=a
this.b=b},
bq:function bq(){},
br:function br(){},
bo:function bo(){},
dr:function dr(a,b,c){this.a=a
this.b=b
this.c=c},
dq:function dq(a){this.a=a},
aU:function aU(){},
cr:function cr(){},
cq:function cq(a,b){this.b=a
this.a=null
this.$ti=b},
dt:function dt(a,b){this.b=a
this.c=b
this.a=null},
ds:function ds(){},
cy:function cy(a){var _=this
_.a=0
_.c=_.b=null
_.$ti=a},
dP:function dP(a,b){this.a=a
this.b=b},
bs:function bs(a,b){var _=this
_.a=1
_.b=a
_.c=null
_.$ti=b},
cz:function cz(a){this.$ti=a},
dX:function dX(){},
e1:function e1(a,b){this.a=a
this.b=b},
dQ:function dQ(){},
dR:function dR(a,b){this.a=a
this.b=b},
hc(a,b){var s=a[b]
return s===a?null:s},
fn(a,b,c){if(c==null)a[b]=a
else a[b]=c},
fm(){var s=Object.create(null)
A.fn(s,"<non-identifier-key>",s)
delete s["<non-identifier-key>"]
return s},
iC(a,b){return new A.a4(a.i("@<0>").t(b).i("a4<1,2>"))},
w(a,b,c){return A.k3(a,new A.a4(b.i("@<0>").t(c).i("a4<1,2>")))},
c3(a,b){return new A.a4(a.i("@<0>").t(b).i("a4<1,2>"))},
iD(a){return new A.az(a.i("az<0>"))},
fS(a){return new A.az(a.i("az<0>"))},
fp(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
fo(a,b,c){var s=new A.aT(a,b,c.i("aT<0>"))
s.c=a.e
return s},
fR(a,b,c){var s=A.iC(b,c)
a.u(0,new A.d4(s,b,c))
return s},
fV(a){var s,r={}
if(A.fB(a))return"{...}"
s=new A.bk("")
try{$.aF.push(a)
s.a+="{"
r.a=!0
a.u(0,new A.d5(r,s))
s.a+="}"}finally{$.aF.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
bu:function bu(){},
aS:function aS(a){var _=this
_.a=0
_.e=_.d=_.c=_.b=null
_.$ti=a},
bv:function bv(a,b){this.a=a
this.$ti=b},
cu:function cu(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
az:function az(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
dN:function dN(a){this.a=a
this.b=null},
aT:function aT(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=null
_.$ti=c},
d4:function d4(a,b,c){this.a=a
this.b=b
this.c=c},
n:function n(){},
L:function L(){},
d5:function d5(a,b){this.a=a
this.b=b},
aM:function aM(){},
bA:function bA(){},
jL(a,b){var s,r,q,p=null
try{p=JSON.parse(a)}catch(r){s=A.S(r)
q=A.bT(String(s),null)
throw A.a(q)}q=A.e_(p)
return q},
e_(a){var s
if(a==null)return null
if(typeof a!="object")return a
if(!Array.isArray(a))return new A.cw(a,Object.create(null))
for(s=0;s<a.length;++s)a[s]=A.e_(a[s])
return a},
fQ(a,b,c){return new A.ba(a,b)},
jm(a){return a.aI()},
iV(a,b){return new A.dK(a,[],A.k1())},
iW(a,b,c){var s,r=new A.bk(""),q=A.iV(r,b)
q.ae(a)
s=r.a
return s.charCodeAt(0)==0?s:s},
cw:function cw(a,b){this.a=a
this.b=b
this.c=null},
cx:function cx(a){this.a=a},
bP:function bP(){},
bR:function bR(){},
ba:function ba(a,b){this.a=a
this.b=b},
c0:function c0(a,b){this.a=a
this.b=b},
d0:function d0(){},
d2:function d2(a){this.b=a},
d1:function d1(a){this.a=a},
dL:function dL(){},
dM:function dM(a,b){this.a=a
this.b=b},
dK:function dK(a,b,c){this.c=a
this.a=b
this.b=c},
cF(a){var s=A.iI(a,null)
if(s!=null)return s
throw A.a(A.bT(a,null))},
iq(a,b){a=A.a(a)
a.stack=b.j(0)
throw a
throw A.a("unreachable")},
bb(a,b,c,d){var s,r=J.iy(a,d)
if(a!==0&&b!=null)for(s=0;s<a;++s)r[s]=b
return r},
fU(a,b){var s,r=A.v([],b.i("z<0>"))
for(s=J.aG(a);s.l();)r.push(s.gm())
return r},
aw(a,b,c){var s
if(b)return A.fT(a,c)
s=A.fT(a,c)
s.$flags=1
return s},
fT(a,b){var s,r
if(Array.isArray(a))return A.v(a.slice(0),b.i("z<0>"))
s=A.v([],b.i("z<0>"))
for(r=J.aG(a);r.l();)s.push(r.gm())
return s},
iL(a){return new A.cZ(a,A.iB(a,!1,!0,!1,!1,!1))},
h7(a,b,c){var s=J.aG(b)
if(!s.l())return a
if(c.length===0){do a+=A.d(s.gm())
while(s.l())}else{a+=A.d(s.gm())
for(;s.l();)a=a+c+A.d(s.gm())}return a},
h5(){return A.Y(new Error())},
im(a,b,c,d,e,f,g,h,i){var s=A.h1(a,b,c,d,e,f,g,h,i)
if(s==null)return null
return new A.E(A.ip(s,h,i),h,i)},
a1(a,b,c){var s=A.h1(a,b,c,0,0,0,0,0,!1)
if(s==null)s=864e14
if(s===864e14)A.aD(A.ap("("+a+", "+b+", "+c+", 0, 0, 0, 0, 0)",null))
return new A.E(s,0,!1)},
cN(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=$.hW().bN(a)
if(c!=null){s=new A.cO()
r=c.b
q=r[1]
q.toString
p=A.cF(q)
q=r[2]
q.toString
o=A.cF(q)
q=r[3]
q.toString
n=A.cF(q)
m=s.$1(r[4])
l=s.$1(r[5])
k=s.$1(r[6])
j=new A.cP().$1(r[7])
i=B.d.b_(j,1000)
h=r[8]!=null
if(h){g=r[9]
if(g!=null){f=g==="-"?-1:1
q=r[10]
q.toString
e=A.cF(q)
l-=f*(s.$1(r[11])+60*e)}}d=A.im(p,o,n,m,l,k,i,j%1000,h)
if(d==null)throw A.a(A.bT("Time out of range",a))
return d}else throw A.a(A.bT("Invalid date format",a))},
ip(a,b,c){var s="microsecond"
if(b>999)throw A.a(A.a6(b,0,999,s,null))
if(a<-864e13||a>864e13)throw A.a(A.a6(a,-864e13,864e13,"millisecondsSinceEpoch",null))
if(a===864e13&&b!==0)throw A.a(A.fd(b,s,"Time including microseconds is outside valid range"))
A.cE(c,"isUtc",t.y)
return a},
fP(a){var s=Math.abs(a),r=a<0?"-":""
if(s>=1000)return""+a
if(s>=100)return r+"0"+s
if(s>=10)return r+"00"+s
return r+"000"+s},
io(a){var s=Math.abs(a),r=a<0?"-":"+"
if(s>=1e5)return r+s
return r+"0"+s},
cM(a){if(a>=100)return""+a
if(a>=10)return"0"+a
return"00"+a},
a2(a){if(a>=10)return""+a
return"0"+a},
bS(a){if(typeof a=="number"||A.e0(a)||a==null)return J.ag(a)
if(typeof a=="string")return JSON.stringify(a)
return A.iJ(a)},
ir(a,b){A.cE(a,"error",t.K)
A.cE(b,"stackTrace",t.l)
A.iq(a,b)},
bN(a){return new A.bM(a)},
ap(a,b){return new A.Z(!1,null,b,a)},
fd(a,b,c){return new A.Z(!0,a,b,c)},
a6(a,b,c,d,e){return new A.bi(b,c,!0,a,d,"Invalid value")},
iK(a,b,c){if(0>a||a>c)throw A.a(A.a6(a,0,c,"start",null))
if(a>b||b>c)throw A.a(A.a6(b,a,c,"end",null))
return b},
h2(a,b){if(a<0)throw A.a(A.a6(a,0,null,b,null))
return a},
fh(a,b,c,d){return new A.bU(b,!0,a,d,"Index out of range")},
dk(a){return new A.bm(a)},
bl(a){return new A.ci(a)},
ch(a){return new A.ax(a)},
B(a){return new A.bQ(a)},
is(a){return new A.dv(a)},
bT(a,b){return new A.cS(a,b)},
ix(a,b,c){var s,r
if(A.fB(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.v([],t.s)
$.aF.push(a)
try{A.jH(a,s)}finally{$.aF.pop()}r=A.h7(b,s,", ")+c
return r.charCodeAt(0)==0?r:r},
fi(a,b,c){var s,r
if(A.fB(a))return b+"..."+c
s=new A.bk(b)
$.aF.push(a)
try{r=s
r.a=A.h7(r.a,a,", ")}finally{$.aF.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
jH(a,b){var s,r,q,p,o,n,m,l=a.gp(a),k=0,j=0
while(!0){if(!(k<80||j<3))break
if(!l.l())return
s=A.d(l.gm())
b.push(s)
k+=s.length+2;++j}if(!l.l()){if(j<=5)return
r=b.pop()
q=b.pop()}else{p=l.gm();++j
if(!l.l()){if(j<=4){b.push(A.d(p))
return}r=A.d(p)
q=b.pop()
k+=r.length+2}else{o=l.gm();++j
for(;l.l();p=o,o=n){n=l.gm();++j
if(j>100){while(!0){if(!(k>75&&j>3))break
k-=b.pop().length+2;--j}b.push("...")
return}}q=A.d(p)
r=A.d(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
while(!0){if(!(k>80&&b.length>3))break
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)b.push(m)
b.push(q)
b.push(r)},
iF(a,b){var s=B.d.gA(a)
b=B.d.gA(b)
b=A.iN(A.h8(A.h8($.i6(),s),b))
return b},
i(a){A.O(a)},
E:function E(a,b,c){this.a=a
this.b=b
this.c=c},
cO:function cO(){},
cP:function cP(){},
du:function du(){},
t:function t(){},
bM:function bM(a){this.a=a},
a7:function a7(){},
Z:function Z(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
bi:function bi(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
bU:function bU(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
bm:function bm(a){this.a=a},
ci:function ci(a){this.a=a},
ax:function ax(a){this.a=a},
bQ:function bQ(a){this.a=a},
bj:function bj(){},
dv:function dv(a){this.a=a},
cS:function cS(a,b){this.a=a
this.b=b},
f:function f(){},
aK:function aK(a,b,c){this.a=a
this.b=b
this.$ti=c},
A:function A(){},
l:function l(){},
cA:function cA(a){this.a=a},
bk:function bk(a){this.a=a},
hu(a){var s
if(typeof a=="function")throw A.a(A.ap("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d){return b(c,d,arguments.length)}}(A.jl,a)
s[$.f9()]=a
return s},
jk(a){return a.$0()},
jl(a,b,c){if(c>=1)return a.$1(b)
return a.$0()},
hB(a){return a==null||A.e0(a)||typeof a=="number"||typeof a=="string"||t.U.b(a)||t.bX.b(a)||t.ca.b(a)||t.O.b(a)||t.c0.b(a)||t.e.b(a)||t.bk.b(a)||t.E.b(a)||t.q.b(a)||t.J.b(a)||t.V.b(a)},
hR(a){if(A.hB(a))return a
return new A.ed(new A.aS(t.A)).$1(a)},
kj(a,b){var s=new A.r($.o,b.i("r<0>")),r=new A.a9(s,b.i("a9<0>"))
a.then(A.aZ(new A.f7(r),1),A.aZ(new A.f8(r),1))
return s},
hA(a){return a==null||typeof a==="boolean"||typeof a==="number"||typeof a==="string"||a instanceof Int8Array||a instanceof Uint8Array||a instanceof Uint8ClampedArray||a instanceof Int16Array||a instanceof Uint16Array||a instanceof Int32Array||a instanceof Uint32Array||a instanceof Float32Array||a instanceof Float64Array||a instanceof ArrayBuffer||a instanceof DataView},
hL(a){if(A.hA(a))return a
return new A.e4(new A.aS(t.A)).$1(a)},
ed:function ed(a){this.a=a},
f7:function f7(a){this.a=a},
f8:function f8(a){this.a=a},
e4:function e4(a){this.a=a},
d6:function d6(a){this.a=a},
ki(c8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,c0,c1,c2,c3,c4,c5,c6,c7="orderID"
A.i("Isolate received params of type: "+J.fc(c8).j(0))
A.aA(c8)
A.i("Raw params length: "+c8.length)
s=t.a
r=s.a(B.e.a9(c8,null))
q=t.j
p=J.fH(q.a(r.h(0,"orders")),s)
o=r.h(0,"eps")
if(o==null)o=200
n=r.h(0,"minPts")
if(n==null)n=2
m=r.h(0,"minPricePerKm")
if(m==null)m=2
l=r.h(0,"maxRadius")
if(l==null)l=200
k=J.fH(q.a(r.h(0,"carTypes")),s)
j=r.h(0,"currentTime")
A.i("Isolate parameters extracted: orders="+J.aH(p.a)+", eps="+A.d(o)+" km, minPts="+A.d(n)+", minPricePerKm="+A.d(m)+", maxRadius="+A.d(l)+" km, currentTime="+j)
i=new A.er(new A.eq())
h=new A.es(i)
g=new A.eK(h,k,j)
A.i("\n--- Starting Clustering Process ---")
s=t.t
f=A.v([],s)
e=A.v([],s)
d=A.v([],s)
A.i("Step 1: Identifying Best Orders")
c=A.v([],s)
b=A.v([],s)
for(q=p.$ti,a=new A.ak(p,p.gk(0),q.i("ak<n.E>")),q=q.i("n.E"),a0=t.N,a1=t.z,a2=t.L;a.l();){a3=a.d
if(a3==null)a3=q.a(a3)
A.O("\nChecking OrderID: "+A.d(a3.h(0,c7)))
if(g.$2(a3,m)){a4=A.fR(a3,a0,a1)
a4.n(0,"connectedGroupID",A.aA(a4.h(0,c7)))
a4.n(0,"isConnected",!0)
a3=A.aA(a4.h(0,c7))
a5=A.v([a4],s)
a6=h.$1(a4)
a7=A.ab(a4.h(0,"price"))
a8=A.ab(a4.h(0,"ldm"))
a9=A.ab(a4.h(0,"weight"))
b0=A.X(a4.h(0,"creatorID"))
if(b0==null)b0="system"
b1=A.X(a4.h(0,"creatorName"))
if(b1==null)b1="System"
b2=A.X(a4.h(0,"createdAt"))
if(b2==null)b2=new A.E(Date.now(),0,!1).bb()
b3=A.X(a4.h(0,"lastModifiedAt"))
b4=A.jf(a4.h(0,"isEditing"))
b5=a2.a(a4.h(0,"comments"))
if(b5==null)b5=[]
b6=a2.a(a4.h(0,"orderLogs"))
if(b6==null)b6=[]
b7=A.w(["groupID",a3,"orders",a5,"totalDistance",0,"pricePerKm",a6,"totalPrice",a7,"totalLDM",a8,"totalWeight",a9,"status","Pending","creatorID",b0,"creatorName",b1,"createdAt",b2,"lastModifiedAt",b3,"isEditing",b4===!0,"comments",b5,"logs",b6,"driverInfo",a4.h(0,"driverInfo")],a0,a1)
c.push(b7)
A.O("  Added to Best Orders: "+A.d(b7.h(0,"groupID")))}else{b.push(a3)
A.O("  Added to Remaining Orders: "+A.d(a3.h(0,c7)))}}B.a.W(f,c)
A.i("Total Best Orders Identified: "+f.length)
A.i("\nStep 2: Running DBSCAN Clustering on Remaining Orders")
q=t.G
b8=A.c3(t.S,q)
b9=A.v([],s)
s=b.length
if(s!==0){A.i("  Remaining Orders to Cluster: "+s)
c0=A.bb(b.length,null,!1,t.I)
c1=new A.eT(i,o)
c2=new A.eH(b8,c1,n)
for(c3=0,c4=0;c4<b.length;++c4){if(c0[c4]!=null)continue
c5=c1.$2(b,c4)
if(J.aH(c5)<n){c0[c4]=-1
b9.push(b[c4])
A.O("    OrderID: "+A.d(b[c4].h(0,c7))+" marked as noise.")}else{++c3
A.O("    Starting new Cluster "+c3+" with OrderID: "+A.d(b[c4].h(0,c7)))
c2.$5(b,c0,c4,c5,c3)}}A.i("\nDBSCAN Results: Clusters Formed: "+b8.a+", Noise Orders: "+b9.length)
b8.u(0,new A.ez())
A.i("  Noise: "+new A.q(b9,new A.eA(),t.cq).G(0,", "))}else A.i("  No remaining orders to cluster.")
if(b8.a!==0){A.i("\nStep 3: Processing Clusters for Best Groups")
c6=new A.q(f,new A.eB(),t.M).c8(0)
s=new A.eU(k,new A.eP(i),new A.eu(),new A.et(i),i,new A.f2(j,new A.eO(),new A.eN()))
b8.u(0,new A.eC(s,l,m,f,d))
A.i("\nStep 4: Processing Clusters for Suggestion Groups")
b8.u(0,new A.eD(c6,s,l,m,e))}else{A.i("\nNo clusters to process.")
B.a.W(d,b9)}A.i("\n--- Final Clustering Results ---")
A.i("Best Orders: "+f.length)
B.a.u(f,new A.eE())
A.i("Suggestion Groups: "+e.length)
B.a.u(e,new A.eF())
A.i("Noise Orders: "+d.length)
B.a.u(d,new A.eG())
return B.e.aa(A.w(["bestOrders",f,"suggestions",e,"noise",d],a0,q),null)},
eq:function eq(){},
eN:function eN(){},
eO:function eO(){},
er:function er(a){this.a=a},
es:function es(a){this.a=a},
eK:function eK(a,b,c){this.a=a
this.b=b
this.c=c},
eL:function eL(a){this.a=a},
eM:function eM(){},
eu:function eu(){},
ev:function ev(){},
ew:function ew(){},
ex:function ex(){},
ey:function ey(){},
eP:function eP(a){this.a=a},
eQ:function eQ(){},
eR:function eR(a,b){this.a=a
this.b=b},
eS:function eS(a){this.a=a},
f2:function f2(a,b,c){this.a=a
this.b=b
this.c=c},
f6:function f6(){},
f3:function f3(){},
f4:function f4(a){this.a=a},
f5:function f5(a){this.a=a},
et:function et(a){this.a=a},
eT:function eT(a,b){this.a=a
this.b=b},
eH:function eH(a,b,c){this.a=a
this.b=b
this.c=c},
eI:function eI(){},
eJ:function eJ(a){this.a=a},
ez:function ez(){},
ep:function ep(){},
eA:function eA(){},
eB:function eB(){},
eU:function eU(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
eV:function eV(){},
eW:function eW(){},
eX:function eX(){},
eY:function eY(a){this.a=a},
eZ:function eZ(a){this.a=a},
f_:function f_(){},
f0:function f0(){},
f1:function f1(a){this.a=a},
eC:function eC(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
em:function em(){},
en:function en(a){this.a=a},
eh:function eh(a){this.a=a},
eo:function eo(){},
eD:function eD(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
ek:function ek(a){this.a=a},
el:function el(){},
eE:function eE(){},
ej:function ej(){},
eF:function eF(){},
ei:function ei(){},
eG:function eG(){},
iv(a,b,c,d){var s=new A.cX(c)
return A.iu(a,s,b,s,c,d)},
cX:function cX(a){this.a=a},
it(a,b,c,d,e,f){var s=A.h6(e),r=$.o,q=t.j.b(a),p=q?J.cI(a).gb3():t.m.a(a)
if(q)J.fb(a)
s=new A.bW(p,s,c,d,new A.a9(new A.r(r,t.D),t.h),e.i("@<0>").t(f).i("bW<1,2>"))
s.bk(a,b,c,d,e,f)
return s},
bW:function bW(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.f=e
_.$ti=f},
cW:function cW(a){this.a=a},
iw(a){var s,r,q
if(typeof a!="string")return!1
try{s=t.f.a(B.e.a9(a,null))
r=s.F("$IsolateException")
return r}catch(q){}return!1},
cY:function cY(a,b){this.a=a
this.b=b},
bY:function bY(a){this.b=a},
fy(a){if(!t.m.b(a))return a
return A.fx(A.hL(a))},
fx(a){var s,r
if(t.j.b(a)){s=J.cJ(a,A.kn(),t.z)
return A.aw(s,!0,s.$ti.i("D.E"))}else if(t.f.b(a)){s=t.z
r=A.c3(s,s)
a.u(0,new A.e3(r))
return r}else return A.fy(a)},
bL(a){var s,r
if(a==null)return null
if(t.j.b(a)){s=J.cJ(a,A.ko(),t.X)
return A.aw(s,!0,s.$ti.i("D.E"))}if(t.f.b(a)){s=t.X
return A.hR(a.bV(0,new A.ee(),s,s))}if(t.B.b(a)){if(typeof a=="function")A.aD(A.ap("Attempting to rewrap a JS function.",null))
r=function(b,c){return function(){return b(c)}}(A.jk,a)
r[$.f9()]=a
return r}return A.hR(a)},
e3:function e3(a){this.a=a},
ee:function ee(){},
b3:function b3(a,b){this.a=a
this.$ti=b},
iU(a,b,c){var s=new A.cv(a,A.h6(c),b.i("@<0>").t(c).i("cv<1,2>"))
s.bl(a,b,c)
return s},
bX:function bX(a,b){this.a=a
this.$ti=b},
cv:function cv(a,b,c){this.a=a
this.b=b
this.$ti=c},
dI:function dI(a){this.a=a},
fC(a,b,c,d){var s=0,r=A.hz(t.H),q
var $async$fC=A.hI(function(e,f){if(e===1)return A.ho(f,r)
while(true)switch(s){case 0:q=self.self
q=J.fc(q)===B.n?A.iU(q,c,d):A.iv(q,null,c,d)
q.gb9().bU(new A.ec(new A.b3(new A.bX(q,c.i("@<0>").t(d).i("bX<1,2>")),c.i("@<0>").t(d).i("b3<1,2>")),a,d,c))
q.b6()
return A.hp(null,r)}})
return A.hq($async$fC,r)},
ec:function ec(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
eb:function eb(a){this.a=a},
O(a){if(typeof dartPrint=="function"){dartPrint(a)
return}if(typeof console=="object"&&typeof console.log!="undefined"){console.log(a)
return}if(typeof print=="function"){print(a)
return}throw"Unable to print message: "+String(a)},
kl(a){A.hU(new A.c1("Field '"+a+"' has been assigned during initialization."),new Error())},
kf(){A.fC(A.k_(),null,t.N,t.z)},
iu(a,b,c,d,e,f){if(t.j.b(a))J.cI(a).gb3()
return A.it(a,b,c,d,e,f)}},B={}
var w=[A,J,B]
var $={}
A.fj.prototype={}
J.bV.prototype={
P(a,b){return a===b},
gA(a){return A.bh(a)},
j(a){return"Instance of '"+A.d8(a)+"'"},
gq(a){return A.a_(A.ft(this))}}
J.b4.prototype={
j(a){return String(a)},
O(a,b){return b&&a},
gA(a){return a?519018:218159},
gq(a){return A.a_(t.y)},
$ip:1,
$iF:1}
J.b6.prototype={
P(a,b){return null==b},
j(a){return"null"},
gA(a){return 0},
gq(a){return A.a_(t.P)},
$ip:1,
$iA:1}
J.b8.prototype={$iy:1}
J.aj.prototype={
gA(a){return 0},
gq(a){return B.n},
j(a){return String(a)}}
J.cf.prototype={}
J.ay.prototype={}
J.ai.prototype={
j(a){var s=a[$.f9()]
if(s==null)return this.bj(a)
return"JavaScript function for "+J.ag(s)}}
J.b7.prototype={
gA(a){return 0},
j(a){return String(a)}}
J.b9.prototype={
gA(a){return 0},
j(a){return String(a)}}
J.z.prototype={
a7(a,b){return new A.a0(a,A.H(a).i("@<1>").t(b).i("a0<1,2>"))},
E(a,b){a.$flags&1&&A.aE(a,29)
a.push(b)},
bZ(a,b){a.$flags&1&&A.aE(a,16)
this.bC(a,b,!0)},
bC(a,b,c){var s,r,q,p=[],o=a.length
for(s=0;s<o;++s){r=a[s]
if(!b.$1(r))p.push(r)
if(a.length!==o)throw A.a(A.B(a))}q=p.length
if(q===o)return
this.sk(a,q)
for(s=0;s<p.length;++s)a[s]=p[s]},
aJ(a,b){return new A.N(a,b,A.H(a).i("N<1>"))},
W(a,b){var s
a.$flags&1&&A.aE(a,"addAll",2)
if(Array.isArray(b)){this.bo(a,b)
return}for(s=J.aG(b);s.l();)a.push(s.gm())},
bo(a,b){var s,r=b.length
if(r===0)return
if(a===b)throw A.a(A.B(a))
for(s=0;s<r;++s)a.push(b[s])},
u(a,b){var s,r=a.length
for(s=0;s<r;++s){b.$1(a[s])
if(a.length!==r)throw A.a(A.B(a))}},
U(a,b,c){return new A.q(a,b,A.H(a).i("@<1>").t(c).i("q<1,2>"))},
G(a,b){var s,r=A.bb(a.length,"",!1,t.N)
for(s=0;s<a.length;++s)r[s]=A.d(a[s])
return r.join(b)},
bO(a,b,c){var s,r,q=a.length
for(s=b,r=0;r<q;++r){s=c.$2(s,a[r])
if(a.length!==q)throw A.a(A.B(a))}return s},
aA(a,b,c){return this.bO(a,b,c,t.z)},
B(a,b){return a[b]},
gD(a){if(a.length>0)return a[0]
throw A.a(A.a3())},
gL(a){var s=a.length
if(s>0)return a[s-1]
throw A.a(A.a3())},
bJ(a,b){var s,r=a.length
for(s=0;s<r;++s){if(b.$1(a[s]))return!0
if(a.length!==r)throw A.a(A.B(a))}return!1},
b4(a,b){var s,r=a.length
for(s=0;s<r;++s){if(!b.$1(a[s]))return!1
if(a.length!==r)throw A.a(A.B(a))}return!0},
bi(a,b){var s,r,q,p,o
a.$flags&2&&A.aE(a,"sort")
s=a.length
if(s<2)return
if(b==null)b=J.jw()
if(s===2){r=a[0]
q=a[1]
if(b.$2(r,q)>0){a[0]=q
a[1]=r}return}p=0
if(A.H(a).c.b(null))for(o=0;o<a.length;++o)if(a[o]===void 0){a[o]=null;++p}a.sort(A.aZ(b,2))
if(p>0)this.bD(a,p)},
aM(a){return this.bi(a,null)},
bD(a,b){var s,r=a.length
for(;s=r-1,r>0;r=s)if(a[s]===null){a[s]=void 0;--b
if(b===0)break}},
gv(a){return a.length===0},
gK(a){return a.length!==0},
j(a){return A.fi(a,"[","]")},
gp(a){return new J.aI(a,a.length,A.H(a).i("aI<1>"))},
gA(a){return A.bh(a)},
gk(a){return a.length},
sk(a,b){a.$flags&1&&A.aE(a,"set length","change the length of")
if(b<0)throw A.a(A.a6(b,0,null,"newLength",null))
if(b>a.length)A.H(a).c.a(null)
a.length=b},
h(a,b){if(!(b>=0&&b<a.length))throw A.a(A.e5(a,b))
return a[b]},
n(a,b,c){a.$flags&2&&A.aE(a)
if(!(b>=0&&b<a.length))throw A.a(A.e5(a,b))
a[b]=c},
bQ(a,b){var s
if(0>=a.length)return-1
for(s=0;s<a.length;++s)if(b.$1(a[s]))return s
return-1},
gq(a){return A.a_(A.H(a))},
$im:1,
$if:1,
$ih:1}
J.d_.prototype={}
J.aI.prototype={
gm(){var s=this.d
return s==null?this.$ti.c.a(s):s},
l(){var s,r=this,q=r.a,p=q.length
if(r.b!==p)throw A.a(A.b_(q))
s=r.c
if(s>=p){r.d=null
return!1}r.d=q[s]
r.c=s+1
return!0}}
J.at.prototype={
X(a,b){var s
if(a<b)return-1
else if(a>b)return 1
else if(a===b){if(a===0){s=this.gac(b)
if(this.gac(a)===s)return 0
if(this.gac(a))return-1
return 1}return 0}else if(isNaN(a)){if(isNaN(b))return 0
return 1}else return-1},
gac(a){return a===0?1/a<0:a<0},
C(a,b){var s
if(b>20)throw A.a(A.a6(b,0,20,"fractionDigits",null))
s=a.toFixed(b)
if(a===0&&this.gac(a))return"-"+s
return s},
j(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gA(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
be(a,b){return a/b},
bg(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
return s+b},
b_(a,b){return(a|0)===a?a/b|0:this.bH(a,b)},
bH(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.a(A.dk("Result of truncating division is "+A.d(s)+": "+A.d(a)+" ~/ "+b))},
aZ(a,b){var s
if(a>0)s=this.bF(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
bF(a,b){return b>31?0:a>>>b},
bf(a,b){return a<=b},
gq(a){return A.a_(t.n)},
$ij:1}
J.b5.prototype={
gq(a){return A.a_(t.S)},
$ip:1,
$ib:1}
J.bZ.prototype={
gq(a){return A.a_(t.i)},
$ip:1}
J.au.prototype={
V(a,b,c){return a.substring(b,A.iK(b,c,a.length))},
X(a,b){var s
if(a===b)s=0
else s=a<b?-1:1
return s},
j(a){return a},
gA(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gq(a){return A.a_(t.N)},
gk(a){return a.length},
h(a,b){if(!(b.cc(0,0)&&b.cd(0,a.length)))throw A.a(A.e5(a,b))
return a[b]},
$ip:1,
$ic:1}
A.al.prototype={
gp(a){return new A.bO(J.aG(this.gJ()),A.u(this).i("bO<1,2>"))},
gk(a){return J.aH(this.gJ())},
gv(a){return J.fJ(this.gJ())},
gK(a){return J.ia(this.gJ())},
B(a,b){return A.u(this).y[1].a(J.fa(this.gJ(),b))},
gD(a){return A.u(this).y[1].a(J.fb(this.gJ()))},
gL(a){return A.u(this).y[1].a(J.cI(this.gJ()))},
j(a){return J.ag(this.gJ())}}
A.bO.prototype={
l(){return this.a.l()},
gm(){return this.$ti.y[1].a(this.a.gm())}}
A.aq.prototype={
gJ(){return this.a}}
A.bt.prototype={$im:1}
A.bp.prototype={
h(a,b){return this.$ti.y[1].a(J.k(this.a,b))},
n(a,b,c){J.i8(this.a,b,this.$ti.c.a(c))},
sk(a,b){J.ib(this.a,b)},
E(a,b){J.cG(this.a,this.$ti.c.a(b))},
$im:1,
$ih:1}
A.a0.prototype={
a7(a,b){return new A.a0(this.a,this.$ti.i("@<1>").t(b).i("a0<1,2>"))},
gJ(){return this.a}}
A.c1.prototype={
j(a){return"LateInitializationError: "+this.a}}
A.d9.prototype={}
A.m.prototype={}
A.D.prototype={
gp(a){var s=this
return new A.ak(s,s.gk(s),A.u(s).i("ak<D.E>"))},
gv(a){return this.gk(this)===0},
gD(a){if(this.gk(this)===0)throw A.a(A.a3())
return this.B(0,0)},
gL(a){var s=this
if(s.gk(s)===0)throw A.a(A.a3())
return s.B(0,s.gk(s)-1)},
G(a,b){var s,r,q,p=this,o=p.gk(p)
if(b.length!==0){if(o===0)return""
s=A.d(p.B(0,0))
if(o!==p.gk(p))throw A.a(A.B(p))
for(r=s,q=1;q<o;++q){r=r+b+A.d(p.B(0,q))
if(o!==p.gk(p))throw A.a(A.B(p))}return r.charCodeAt(0)==0?r:r}else{for(q=0,r="";q<o;++q){r+=A.d(p.B(0,q))
if(o!==p.gk(p))throw A.a(A.B(p))}return r.charCodeAt(0)==0?r:r}},
U(a,b,c){return new A.q(this,b,A.u(this).i("@<D.E>").t(c).i("q<1,2>"))},
c8(a){var s,r=this,q=A.iD(A.u(r).i("D.E"))
for(s=0;s<r.gk(r);++s)q.E(0,r.B(0,s))
return q}}
A.ak.prototype={
gm(){var s=this.d
return s==null?this.$ti.c.a(s):s},
l(){var s,r=this,q=r.a,p=J.aC(q),o=p.gk(q)
if(r.b!==o)throw A.a(A.B(q))
s=r.c
if(s>=o){r.d=null
return!1}r.d=p.B(q,s);++r.c
return!0}}
A.a5.prototype={
gp(a){return new A.c4(J.aG(this.a),this.b,A.u(this).i("c4<1,2>"))},
gk(a){return J.aH(this.a)},
gv(a){return J.fJ(this.a)},
gD(a){return this.b.$1(J.fb(this.a))},
gL(a){return this.b.$1(J.cI(this.a))},
B(a,b){return this.b.$1(J.fa(this.a,b))}}
A.as.prototype={$im:1}
A.c4.prototype={
l(){var s=this,r=s.b
if(r.l()){s.a=s.c.$1(r.gm())
return!0}s.a=null
return!1},
gm(){var s=this.a
return s==null?this.$ti.y[1].a(s):s}}
A.q.prototype={
gk(a){return J.aH(this.a)},
B(a,b){return this.b.$1(J.fa(this.a,b))}}
A.N.prototype={
gp(a){return new A.ck(J.aG(this.a),this.b,this.$ti.i("ck<1>"))},
U(a,b,c){return new A.a5(this,b,this.$ti.i("@<1>").t(c).i("a5<1,2>"))}}
A.ck.prototype={
l(){var s,r
for(s=this.a,r=this.b;s.l();)if(r.$1(s.gm()))return!0
return!1},
gm(){return this.a.gm()}}
A.b2.prototype={
sk(a,b){throw A.a(A.dk("Cannot change the length of a fixed-length list"))},
E(a,b){throw A.a(A.dk("Cannot add to a fixed-length list"))}}
A.bG.prototype={}
A.de.prototype={
I(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
if(p==null)return null
s=Object.create(null)
r=q.b
if(r!==-1)s.arguments=p[r+1]
r=q.c
if(r!==-1)s.argumentsExpr=p[r+1]
r=q.d
if(r!==-1)s.expr=p[r+1]
r=q.e
if(r!==-1)s.method=p[r+1]
r=q.f
if(r!==-1)s.receiver=p[r+1]
return s}}
A.bg.prototype={
j(a){return"Null check operator used on a null value"}}
A.c_.prototype={
j(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.cj.prototype={
j(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.d7.prototype={
j(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.b1.prototype={}
A.bB.prototype={
j(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$iW:1}
A.ar.prototype={
j(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.hV(r==null?"unknown":r)+"'"},
gq(a){var s=A.fw(this)
return A.a_(s==null?A.ae(this):s)},
gcb(){return this},
$C:"$1",
$R:1,
$D:null}
A.cK.prototype={$C:"$0",$R:0}
A.cL.prototype={$C:"$2",$R:2}
A.dd.prototype={}
A.da.prototype={
j(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.hV(s)+"'"}}
A.b0.prototype={
P(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.b0))return!1
return this.$_target===b.$_target&&this.a===b.a},
gA(a){return(A.eg(this.a)^A.bh(this.$_target))>>>0},
j(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.d8(this.a)+"'")}}
A.cp.prototype={
j(a){return"Reading static variable '"+this.a+"' during its initialization"}}
A.cg.prototype={
j(a){return"RuntimeError: "+this.a}}
A.a4.prototype={
gk(a){return this.a},
gv(a){return this.a===0},
gH(){return new A.av(this,A.u(this).i("av<1>"))},
F(a){var s,r
if(typeof a=="string"){s=this.b
if(s==null)return!1
return s[a]!=null}else if(typeof a=="number"&&(a&0x3fffffff)===a){r=this.c
if(r==null)return!1
return r[a]!=null}else return this.bR(a)},
bR(a){var s=this.d
if(s==null)return!1
return this.aC(s[this.aB(a)],a)>=0},
h(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.bS(b)},
bS(a){var s,r,q=this.d
if(q==null)return null
s=q[this.aB(a)]
r=this.aC(s,a)
if(r<0)return null
return s[r].b},
n(a,b,c){var s,r,q=this
if(typeof b=="string"){s=q.b
q.aN(s==null?q.b=q.ao():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=q.c
q.aN(r==null?q.c=q.ao():r,b,c)}else q.bT(b,c)},
bT(a,b){var s,r,q,p=this,o=p.d
if(o==null)o=p.d=p.ao()
s=p.aB(a)
r=o[s]
if(r==null)o[s]=[p.af(a,b)]
else{q=p.aC(r,a)
if(q>=0)r[q].b=b
else r.push(p.af(a,b))}},
bX(a,b){var s,r,q=this
if(q.F(a)){s=q.h(0,a)
return s==null?A.u(q).y[1].a(s):s}r=b.$0()
q.n(0,a,r)
return r},
u(a,b){var s=this,r=s.e,q=s.r
for(;r!=null;){b.$2(r.a,r.b)
if(q!==s.r)throw A.a(A.B(s))
r=r.c}},
aN(a,b,c){var s=a[b]
if(s==null)a[b]=this.af(b,c)
else s.b=c},
af(a,b){var s=this,r=new A.d3(a,b)
if(s.e==null)s.e=s.f=r
else s.f=s.f.c=r;++s.a
s.r=s.r+1&1073741823
return r},
aB(a){return J.cH(a)&1073741823},
aC(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.T(a[r].a,b))return r
return-1},
j(a){return A.fV(this)},
ao(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s}}
A.d3.prototype={}
A.av.prototype={
gk(a){return this.a.a},
gv(a){return this.a.a===0},
gp(a){var s=this.a,r=new A.c2(s,s.r,this.$ti.i("c2<1>"))
r.c=s.e
return r},
M(a,b){return this.a.F(b)}}
A.c2.prototype={
gm(){return this.d},
l(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.a(A.B(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.a
r.c=s.c
return!0}}}
A.e7.prototype={
$1(a){return this.a(a)},
$S:9}
A.e8.prototype={
$2(a,b){return this.a(a,b)},
$S:42}
A.e9.prototype={
$1(a){return this.a(a)},
$S:47}
A.cZ.prototype={
j(a){return"RegExp/"+this.a+"/"+this.b.flags},
bN(a){var s=this.b.exec(a)
if(s==null)return null
return new A.dO(s)}}
A.dO.prototype={
h(a,b){return this.b[b]}}
A.c5.prototype={
gq(a){return B.D},
$ip:1,
$iff:1}
A.be.prototype={}
A.c6.prototype={
gq(a){return B.E},
$ip:1,
$ifg:1}
A.aL.prototype={
gk(a){return a.length},
$iK:1}
A.bc.prototype={
h(a,b){A.ac(b,a,a.length)
return a[b]},
n(a,b,c){a.$flags&2&&A.aE(a)
A.ac(b,a,a.length)
a[b]=c},
$im:1,
$if:1,
$ih:1}
A.bd.prototype={
n(a,b,c){a.$flags&2&&A.aE(a)
A.ac(b,a,a.length)
a[b]=c},
$im:1,
$if:1,
$ih:1}
A.c7.prototype={
gq(a){return B.F},
$ip:1,
$icQ:1}
A.c8.prototype={
gq(a){return B.G},
$ip:1,
$icR:1}
A.c9.prototype={
gq(a){return B.H},
h(a,b){A.ac(b,a,a.length)
return a[b]},
$ip:1,
$icT:1}
A.ca.prototype={
gq(a){return B.I},
h(a,b){A.ac(b,a,a.length)
return a[b]},
$ip:1,
$icU:1}
A.cb.prototype={
gq(a){return B.J},
h(a,b){A.ac(b,a,a.length)
return a[b]},
$ip:1,
$icV:1}
A.cc.prototype={
gq(a){return B.L},
h(a,b){A.ac(b,a,a.length)
return a[b]},
$ip:1,
$idg:1}
A.cd.prototype={
gq(a){return B.M},
h(a,b){A.ac(b,a,a.length)
return a[b]},
$ip:1,
$idh:1}
A.bf.prototype={
gq(a){return B.N},
gk(a){return a.length},
h(a,b){A.ac(b,a,a.length)
return a[b]},
$ip:1,
$idi:1}
A.ce.prototype={
gq(a){return B.O},
gk(a){return a.length},
h(a,b){A.ac(b,a,a.length)
return a[b]},
$ip:1,
$idj:1}
A.bw.prototype={}
A.bx.prototype={}
A.by.prototype={}
A.bz.prototype={}
A.P.prototype={
i(a){return A.dV(v.typeUniverse,this,a)},
t(a){return A.jc(v.typeUniverse,this,a)}}
A.ct.prototype={}
A.dU.prototype={
j(a){return A.J(this.a,null)}}
A.cs.prototype={
j(a){return this.a}}
A.bC.prototype={$ia7:1}
A.dm.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:19}
A.dl.prototype={
$1(a){var s,r
this.a.a=a
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:26}
A.dn.prototype={
$0(){this.a.$0()},
$S:12}
A.dp.prototype={
$0(){this.a.$0()},
$S:12}
A.dS.prototype={
bm(a,b){if(self.setTimeout!=null)self.setTimeout(A.aZ(new A.dT(this,b),0),a)
else throw A.a(A.dk("`setTimeout()` not found."))}}
A.dT.prototype={
$0(){this.b.$0()},
$S:0}
A.cl.prototype={
Y(a){var s,r=this
if(a==null)a=r.$ti.c.a(a)
if(!r.b)r.a.a1(a)
else{s=r.a
if(r.$ti.i("aJ<1>").b(a))s.aR(a)
else s.ak(a)}},
a8(a,b){var s=this.a
if(this.b)s.R(a,b)
else s.a2(a,b)}}
A.dY.prototype={
$1(a){return this.a.$2(0,a)},
$S:3}
A.dZ.prototype={
$2(a,b){this.a.$2(1,new A.b1(a,b))},
$S:24}
A.e2.prototype={
$2(a,b){this.a(a,b)},
$S:43}
A.ah.prototype={
j(a){return A.d(this.a)},
$it:1,
ga0(){return this.b}}
A.aO.prototype={}
A.aP.prototype={
aq(){},
ar(){}}
A.cn.prototype={
gan(){return this.c<4},
bB(a){var s=a.CW,r=a.ch
if(s==null)this.d=r
else s.ch=r
if(r==null)this.e=s
else r.CW=s
a.CW=a
a.ch=a},
bG(a,b,c,d){var s,r,q,p,o,n,m,l=this
if((l.c&4)!==0){s=new A.bs($.o,A.u(l).i("bs<1>"))
A.fE(s.gbx())
if(c!=null)s.c=c
return s}s=$.o
r=d?1:0
q=b!=null?32:0
p=A.iS(s,b)
o=c==null?A.jY():c
n=new A.aP(l,a,p,o,s,r|q,A.u(l).i("aP<1>"))
n.CW=n
n.ch=n
n.ay=l.c&1
m=l.e
l.e=n
n.ch=null
n.CW=m
if(m==null)l.d=n
else m.ch=n
if(l.d===n)A.hG(l.a)
return n},
bA(a){var s,r=this
A.u(r).i("aP<1>").a(a)
if(a.ch===a)return null
s=a.ay
if((s&2)!==0)a.ay=s|4
else{r.bB(a)
if((r.c&2)===0&&r.d==null)r.bq()}return null},
ag(){if((this.c&4)!==0)return new A.ax("Cannot add new events after calling close")
return new A.ax("Cannot add new events while doing an addStream")},
E(a,b){if(!this.gan())throw A.a(this.ag())
this.av(b)},
bI(a,b){var s
if(!this.gan())throw A.a(this.ag())
s=A.hv(a,b)
this.az(s.a,s.b)},
T(){var s,r,q=this
if((q.c&4)!==0){s=q.r
s.toString
return s}if(!q.gan())throw A.a(q.ag())
q.c|=4
r=q.r
if(r==null)r=q.r=new A.r($.o,t.D)
q.aw()
return r},
bq(){if((this.c&4)!==0){var s=this.r
if((s.a&30)===0)s.a1(null)}A.hG(this.b)}}
A.bn.prototype={
av(a){var s,r
for(s=this.d,r=this.$ti.i("cq<1>");s!=null;s=s.ch)s.ai(new A.cq(a,r))},
az(a,b){var s
for(s=this.d;s!=null;s=s.ch)s.ai(new A.dt(a,b))},
aw(){var s=this.d
if(s!=null)for(;s!=null;s=s.ch)s.ai(B.v)
else this.r.a1(null)}}
A.co.prototype={
a8(a,b){var s,r=this.a
if((r.a&30)!==0)throw A.a(A.ch("Future already completed"))
s=A.hv(a,b)
r.a2(s.a,s.b)},
b2(a){return this.a8(a,null)}}
A.a9.prototype={
Y(a){var s=this.a
if((s.a&30)!==0)throw A.a(A.ch("Future already completed"))
s.a1(a)},
bK(){return this.Y(null)}}
A.aQ.prototype={
bW(a){if((this.c&15)!==6)return!0
return this.b.b.aH(this.d,a.a)},
bP(a){var s,r=this.e,q=null,p=a.a,o=this.b.b
if(t.Q.b(r))q=o.c1(r,p,a.b)
else q=o.aH(r,p)
try{p=q
return p}catch(s){if(t.b7.b(A.S(s))){if((this.c&1)!==0)throw A.a(A.ap("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.a(A.ap("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.r.prototype={
aY(a){this.a=this.a&1|4
this.c=a},
ad(a,b,c){var s,r,q=$.o
if(q===B.c){if(b!=null&&!t.Q.b(b)&&!t.v.b(b))throw A.a(A.fd(b,"onError",u.c))}else if(b!=null)b=A.jN(b,q)
s=new A.r(q,c.i("r<0>"))
r=b==null?1:3
this.ah(new A.aQ(s,r,a,b,this.$ti.i("@<1>").t(c).i("aQ<1,2>")))
return s},
c7(a,b){return this.ad(a,null,b)},
b0(a,b,c){var s=new A.r($.o,c.i("r<0>"))
this.ah(new A.aQ(s,19,a,b,this.$ti.i("@<1>").t(c).i("aQ<1,2>")))
return s},
bE(a){this.a=this.a&1|16
this.c=a},
a3(a){this.a=a.a&30|this.a&1
this.c=a.c},
ah(a){var s=this,r=s.a
if(r<=3){a.a=s.c
s.c=a}else{if((r&4)!==0){r=s.c
if((r.a&24)===0){r.ah(a)
return}s.a3(r)}A.aW(null,null,s.b,new A.dw(s,a))}},
au(a){var s,r,q,p,o,n=this,m={}
m.a=a
if(a==null)return
s=n.a
if(s<=3){r=n.c
n.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){s=n.c
if((s.a&24)===0){s.au(a)
return}n.a3(s)}m.a=n.a6(a)
A.aW(null,null,n.b,new A.dD(m,n))}},
a5(){var s=this.c
this.c=null
return this.a6(s)},
a6(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
br(a){var s,r,q,p=this
p.a^=2
try{a.ad(new A.dA(p),new A.dB(p),t.P)}catch(q){s=A.S(q)
r=A.Y(q)
A.fE(new A.dC(p,s,r))}},
ak(a){var s=this,r=s.a5()
s.a=8
s.c=a
A.aR(s,r)},
R(a,b){var s=this.a5()
this.bE(new A.ah(a,b))
A.aR(this,s)},
a1(a){if(this.$ti.i("aJ<1>").b(a)){this.aR(a)
return}this.bp(a)},
bp(a){this.a^=2
A.aW(null,null,this.b,new A.dy(this,a))},
aR(a){if(this.$ti.b(a)){A.iT(a,this)
return}this.br(a)},
a2(a,b){this.a^=2
A.aW(null,null,this.b,new A.dx(this,a,b))},
$iaJ:1}
A.dw.prototype={
$0(){A.aR(this.a,this.b)},
$S:0}
A.dD.prototype={
$0(){A.aR(this.b,this.a.a)},
$S:0}
A.dA.prototype={
$1(a){var s,r,q,p=this.a
p.a^=2
try{p.ak(p.$ti.c.a(a))}catch(q){s=A.S(q)
r=A.Y(q)
p.R(s,r)}},
$S:19}
A.dB.prototype={
$2(a,b){this.a.R(a,b)},
$S:38}
A.dC.prototype={
$0(){this.a.R(this.b,this.c)},
$S:0}
A.dz.prototype={
$0(){A.hb(this.a.a,this.b)},
$S:0}
A.dy.prototype={
$0(){this.a.ak(this.b)},
$S:0}
A.dx.prototype={
$0(){this.a.R(this.b,this.c)},
$S:0}
A.dG.prototype={
$0(){var s,r,q,p,o,n,m,l=this,k=null
try{q=l.a.a
k=q.b.b.c_(q.d)}catch(p){s=A.S(p)
r=A.Y(p)
if(l.c&&l.b.a.c.a===s){q=l.a
q.c=l.b.a.c}else{q=s
o=r
if(o==null)o=A.fe(q)
n=l.a
n.c=new A.ah(q,o)
q=n}q.b=!0
return}if(k instanceof A.r&&(k.a&24)!==0){if((k.a&16)!==0){q=l.a
q.c=k.c
q.b=!0}return}if(k instanceof A.r){m=l.b.a
q=l.a
q.c=k.c7(new A.dH(m),t.z)
q.b=!1}},
$S:0}
A.dH.prototype={
$1(a){return this.a},
$S:37}
A.dF.prototype={
$0(){var s,r,q,p,o,n
try{q=this.a
p=q.a
q.c=p.b.b.aH(p.d,this.b)}catch(o){s=A.S(o)
r=A.Y(o)
q=s
p=r
if(p==null)p=A.fe(q)
n=this.a
n.c=new A.ah(q,p)
n.b=!0}},
$S:0}
A.dE.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=l.a.a.c
p=l.b
if(p.a.bW(s)&&p.a.e!=null){p.c=p.a.bP(s)
p.b=!1}}catch(o){r=A.S(o)
q=A.Y(o)
p=l.a.a.c
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.fe(p)
m=l.b
m.c=new A.ah(p,n)
p=m}p.b=!0}},
$S:0}
A.cm.prototype={}
A.aN.prototype={
gk(a){var s={},r=new A.r($.o,t.aQ)
s.a=0
this.b8(new A.db(s,this),!0,new A.dc(s,r),r.gbs())
return r}}
A.db.prototype={
$1(a){++this.a.a},
$S(){return this.b.$ti.i("~(1)")}}
A.dc.prototype={
$0(){var s=this.b,r=this.a.a,q=s.a5()
s.a=8
s.c=r
A.aR(s,q)},
$S:0}
A.bq.prototype={
gA(a){return(A.bh(this.a)^892482866)>>>0},
P(a,b){if(b==null)return!1
if(this===b)return!0
return b instanceof A.aO&&b.a===this.a}}
A.br.prototype={
aW(){return this.w.bA(this)},
aq(){},
ar(){}}
A.bo.prototype={
aQ(){var s,r=this,q=r.e|=8
if((q&128)!==0){s=r.r
if(s.a===1)s.a=3}if((q&64)===0)r.r=null
r.f=r.aW()},
aq(){},
ar(){},
aW(){return null},
ai(a){var s,r,q=this,p=q.r
if(p==null)p=q.r=new A.cy(A.u(q).i("cy<1>"))
s=p.c
if(s==null)p.b=p.c=a
else{s.sZ(a)
p.c=a}r=q.e
if((r&128)===0){r|=128
q.e=r
if(r<256)p.aK(q)}},
av(a){var s=this,r=s.e
s.e=r|64
s.d.ba(s.a,a)
s.e&=4294967231
s.aS((r&4)!==0)},
az(a,b){var s=this,r=s.e,q=new A.dr(s,a,b)
if((r&1)!==0){s.e=r|16
s.aQ()
q.$0()}else{q.$0()
s.aS((r&4)!==0)}},
aw(){this.aQ()
this.e|=16
new A.dq(this).$0()},
aS(a){var s,r,q=this,p=q.e
if((p&128)!==0&&q.r.c==null){p=q.e=p&4294967167
s=!1
if((p&4)!==0)if(p<256){s=q.r
s=s==null?null:s.c==null
s=s!==!1}if(s){p&=4294967291
q.e=p}}for(;!0;a=r){if((p&8)!==0){q.r=null
return}r=(p&4)!==0
if(a===r)break
q.e=p^64
if(r)q.aq()
else q.ar()
p=q.e&=4294967231}if((p&128)!==0&&p<256)q.r.aK(q)}}
A.dr.prototype={
$0(){var s,r,q=this.a,p=q.e
if((p&8)!==0&&(p&16)===0)return
q.e=p|64
s=q.b
p=this.b
r=q.d
if(t.k.b(s))r.c4(s,p,this.c)
else r.ba(s,p)
q.e&=4294967231},
$S:0}
A.dq.prototype={
$0(){var s=this.a,r=s.e
if((r&16)===0)return
s.e=r|74
s.d.aG(s.c)
s.e&=4294967231},
$S:0}
A.aU.prototype={
b8(a,b,c,d){return this.a.bG(a,d,c,b===!0)},
bU(a){return this.b8(a,null,null,null)}}
A.cr.prototype={
gZ(){return this.a},
sZ(a){return this.a=a}}
A.cq.prototype={
aE(a){a.av(this.b)}}
A.dt.prototype={
aE(a){a.az(this.b,this.c)}}
A.ds.prototype={
aE(a){a.aw()},
gZ(){return null},
sZ(a){throw A.a(A.ch("No events after a done."))}}
A.cy.prototype={
aK(a){var s=this,r=s.a
if(r===1)return
if(r>=1){s.a=1
return}A.fE(new A.dP(s,a))
s.a=1}}
A.dP.prototype={
$0(){var s,r,q=this.a,p=q.a
q.a=0
if(p===3)return
s=q.b
r=s.gZ()
q.b=r
if(r==null)q.c=null
s.aE(this.b)},
$S:0}
A.bs.prototype={
by(){var s,r=this,q=r.a-1
if(q===0){r.a=-1
s=r.c
if(s!=null){r.c=null
r.b.aG(s)}}else r.a=q}}
A.cz.prototype={}
A.dX.prototype={}
A.e1.prototype={
$0(){A.ir(this.a,this.b)},
$S:0}
A.dQ.prototype={
aG(a){var s,r,q
try{if(B.c===$.o){a.$0()
return}A.hC(null,null,this,a)}catch(q){s=A.S(q)
r=A.Y(q)
A.bJ(s,r)}},
c6(a,b){var s,r,q
try{if(B.c===$.o){a.$1(b)
return}A.hE(null,null,this,a,b)}catch(q){s=A.S(q)
r=A.Y(q)
A.bJ(s,r)}},
ba(a,b){return this.c6(a,b,t.z)},
c3(a,b,c){var s,r,q
try{if(B.c===$.o){a.$2(b,c)
return}A.hD(null,null,this,a,b,c)}catch(q){s=A.S(q)
r=A.Y(q)
A.bJ(s,r)}},
c4(a,b,c){var s=t.z
return this.c3(a,b,c,s,s)},
b1(a){return new A.dR(this,a)},
h(a,b){return null},
c0(a){if($.o===B.c)return a.$0()
return A.hC(null,null,this,a)},
c_(a){return this.c0(a,t.z)},
c5(a,b){if($.o===B.c)return a.$1(b)
return A.hE(null,null,this,a,b)},
aH(a,b){var s=t.z
return this.c5(a,b,s,s)},
c2(a,b,c){if($.o===B.c)return a.$2(b,c)
return A.hD(null,null,this,a,b,c)},
c1(a,b,c){var s=t.z
return this.c2(a,b,c,s,s,s)},
bY(a){return a},
aF(a){var s=t.z
return this.bY(a,s,s,s)}}
A.dR.prototype={
$0(){return this.a.aG(this.b)},
$S:0}
A.bu.prototype={
gk(a){return this.a},
gv(a){return this.a===0},
gH(){return new A.bv(this,this.$ti.i("bv<1>"))},
F(a){var s,r
if(typeof a=="string"&&a!=="__proto__"){s=this.b
return s==null?!1:s[a]!=null}else if(typeof a=="number"&&(a&1073741823)===a){r=this.c
return r==null?!1:r[a]!=null}else return this.bu(a)},
bu(a){var s=this.d
if(s==null)return!1
return this.S(this.aV(s,a),a)>=0},
h(a,b){var s,r,q
if(typeof b=="string"&&b!=="__proto__"){s=this.b
r=s==null?null:A.hc(s,b)
return r}else if(typeof b=="number"&&(b&1073741823)===b){q=this.c
r=q==null?null:A.hc(q,b)
return r}else return this.bw(b)},
bw(a){var s,r,q=this.d
if(q==null)return null
s=this.aV(q,a)
r=this.S(s,a)
return r<0?null:s[r+1]},
n(a,b,c){var s,r,q,p,o,n,m=this
if(typeof b=="string"&&b!=="__proto__"){s=m.b
m.aP(s==null?m.b=A.fm():s,b,c)}else if(typeof b=="number"&&(b&1073741823)===b){r=m.c
m.aP(r==null?m.c=A.fm():r,b,c)}else{q=m.d
if(q==null)q=m.d=A.fm()
p=A.eg(b)&1073741823
o=q[p]
if(o==null){A.fn(q,p,[b,c]);++m.a
m.e=null}else{n=m.S(o,b)
if(n>=0)o[n+1]=c
else{o.push(b,c);++m.a
m.e=null}}}},
u(a,b){var s,r,q,p,o,n=this,m=n.aT()
for(s=m.length,r=n.$ti.y[1],q=0;q<s;++q){p=m[q]
o=n.h(0,p)
b.$2(p,o==null?r.a(o):o)
if(m!==n.e)throw A.a(A.B(n))}},
aT(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.e
if(h!=null)return h
h=A.bb(i.a,null,!1,t.z)
s=i.b
r=0
if(s!=null){q=Object.getOwnPropertyNames(s)
p=q.length
for(o=0;o<p;++o){h[r]=q[o];++r}}n=i.c
if(n!=null){q=Object.getOwnPropertyNames(n)
p=q.length
for(o=0;o<p;++o){h[r]=+q[o];++r}}m=i.d
if(m!=null){q=Object.getOwnPropertyNames(m)
p=q.length
for(o=0;o<p;++o){l=m[q[o]]
k=l.length
for(j=0;j<k;j+=2){h[r]=l[j];++r}}}return i.e=h},
aP(a,b,c){if(a[b]==null){++this.a
this.e=null}A.fn(a,b,c)},
aV(a,b){return a[A.eg(b)&1073741823]}}
A.aS.prototype={
S(a,b){var s,r,q
if(a==null)return-1
s=a.length
for(r=0;r<s;r+=2){q=a[r]
if(q==null?b==null:q===b)return r}return-1}}
A.bv.prototype={
gk(a){return this.a.a},
gv(a){return this.a.a===0},
gK(a){return this.a.a!==0},
gp(a){var s=this.a
return new A.cu(s,s.aT(),this.$ti.i("cu<1>"))},
M(a,b){return this.a.F(b)}}
A.cu.prototype={
gm(){var s=this.d
return s==null?this.$ti.c.a(s):s},
l(){var s=this,r=s.b,q=s.c,p=s.a
if(r!==p.e)throw A.a(A.B(p))
else if(q>=r.length){s.d=null
return!1}else{s.d=r[q]
s.c=q+1
return!0}}}
A.az.prototype={
gp(a){var s=this,r=new A.aT(s,s.r,A.u(s).i("aT<1>"))
r.c=s.e
return r},
gk(a){return this.a},
gv(a){return this.a===0},
gK(a){return this.a!==0},
M(a,b){var s,r
if(typeof b=="string"&&b!=="__proto__"){s=this.b
if(s==null)return!1
return s[b]!=null}else if(typeof b=="number"&&(b&1073741823)===b){r=this.c
if(r==null)return!1
return r[b]!=null}else return this.bt(b)},
bt(a){var s=this.d
if(s==null)return!1
return this.S(s[this.aU(a)],a)>=0},
gD(a){var s=this.e
if(s==null)throw A.a(A.ch("No elements"))
return s.a},
gL(a){var s=this.f
if(s==null)throw A.a(A.ch("No elements"))
return s.a},
E(a,b){var s,r,q=this
if(typeof b=="string"&&b!=="__proto__"){s=q.b
return q.aO(s==null?q.b=A.fp():s,b)}else if(typeof b=="number"&&(b&1073741823)===b){r=q.c
return q.aO(r==null?q.c=A.fp():r,b)}else return q.bn(b)},
bn(a){var s,r,q=this,p=q.d
if(p==null)p=q.d=A.fp()
s=q.aU(a)
r=p[s]
if(r==null)p[s]=[q.ap(a)]
else{if(q.S(r,a)>=0)return!1
r.push(q.ap(a))}return!0},
aO(a,b){if(a[b]!=null)return!1
a[b]=this.ap(b)
return!0},
ap(a){var s=this,r=new A.dN(a)
if(s.e==null)s.e=s.f=r
else s.f=s.f.b=r;++s.a
s.r=s.r+1&1073741823
return r},
aU(a){return J.cH(a)&1073741823},
S(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.T(a[r].a,b))return r
return-1}}
A.dN.prototype={}
A.aT.prototype={
gm(){var s=this.d
return s==null?this.$ti.c.a(s):s},
l(){var s=this,r=s.c,q=s.a
if(s.b!==q.r)throw A.a(A.B(q))
else if(r==null){s.d=null
return!1}else{s.d=r.a
s.c=r.b
return!0}}}
A.d4.prototype={
$2(a,b){this.a.n(0,this.b.a(a),this.c.a(b))},
$S:13}
A.n.prototype={
gp(a){return new A.ak(a,this.gk(a),A.ae(a).i("ak<n.E>"))},
B(a,b){return this.h(a,b)},
u(a,b){var s,r=this.gk(a)
for(s=0;s<r;++s){b.$1(this.h(a,s))
if(r!==this.gk(a))throw A.a(A.B(a))}},
gv(a){return this.gk(a)===0},
gK(a){return!this.gv(a)},
gD(a){if(this.gk(a)===0)throw A.a(A.a3())
return this.h(a,0)},
gL(a){if(this.gk(a)===0)throw A.a(A.a3())
return this.h(a,this.gk(a)-1)},
b5(a,b,c){var s,r,q=this.gk(a)
for(s=0;s<q;++s){r=this.h(a,s)
if(b.$1(r))return r
if(q!==this.gk(a))throw A.a(A.B(a))}return c.$0()},
aJ(a,b){return new A.N(a,b,A.ae(a).i("N<n.E>"))},
U(a,b,c){return new A.q(a,b,A.ae(a).i("@<n.E>").t(c).i("q<1,2>"))},
E(a,b){var s=this.gk(a)
this.sk(a,s+1)
this.n(a,s,b)},
a7(a,b){return new A.a0(a,A.ae(a).i("@<n.E>").t(b).i("a0<1,2>"))},
j(a){return A.fi(a,"[","]")}}
A.L.prototype={
u(a,b){var s,r,q,p
for(s=this.gH(),s=s.gp(s),r=A.u(this).i("L.V");s.l();){q=s.gm()
p=this.h(0,q)
b.$2(q,p==null?r.a(p):p)}},
bV(a,b,c,d){var s,r,q,p,o,n=A.c3(c,d)
for(s=this.gH(),s=s.gp(s),r=A.u(this).i("L.V");s.l();){q=s.gm()
p=this.h(0,q)
o=b.$2(q,p==null?r.a(p):p)
n.n(0,o.a,o.b)}return n},
F(a){return this.gH().M(0,a)},
gk(a){var s=this.gH()
return s.gk(s)},
gv(a){var s=this.gH()
return s.gv(s)},
j(a){return A.fV(this)},
$ie:1}
A.d5.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.d(a)
s=r.a+=s
r.a=s+": "
s=A.d(b)
r.a+=s},
$S:14}
A.aM.prototype={
gv(a){return this.a===0},
gK(a){return this.a!==0},
U(a,b,c){return new A.as(this,b,A.u(this).i("@<1>").t(c).i("as<1,2>"))},
j(a){return A.fi(this,"{","}")},
gD(a){var s,r=A.fo(this,this.r,A.u(this).c)
if(!r.l())throw A.a(A.a3())
s=r.d
return s==null?r.$ti.c.a(s):s},
gL(a){var s,r,q=A.fo(this,this.r,A.u(this).c)
if(!q.l())throw A.a(A.a3())
s=q.$ti.c
do{r=q.d
if(r==null)r=s.a(r)}while(q.l())
return r},
B(a,b){var s,r,q,p=this
A.h2(b,"index")
s=A.fo(p,p.r,A.u(p).c)
for(r=b;s.l();){if(r===0){q=s.d
return q==null?s.$ti.c.a(q):q}--r}throw A.a(A.fh(b,b-r,p,"index"))},
$im:1,
$if:1}
A.bA.prototype={}
A.cw.prototype={
h(a,b){var s,r=this.b
if(r==null)return this.c.h(0,b)
else if(typeof b!="string")return null
else{s=r[b]
return typeof s=="undefined"?this.bz(b):s}},
gk(a){return this.b==null?this.c.a:this.a4().length},
gv(a){return this.gk(0)===0},
gH(){if(this.b==null){var s=this.c
return new A.av(s,A.u(s).i("av<1>"))}return new A.cx(this)},
F(a){if(this.b==null)return this.c.F(a)
return Object.prototype.hasOwnProperty.call(this.a,a)},
u(a,b){var s,r,q,p,o=this
if(o.b==null)return o.c.u(0,b)
s=o.a4()
for(r=0;r<s.length;++r){q=s[r]
p=o.b[q]
if(typeof p=="undefined"){p=A.e_(o.a[q])
o.b[q]=p}b.$2(q,p)
if(s!==o.c)throw A.a(A.B(o))}},
a4(){var s=this.c
if(s==null)s=this.c=A.v(Object.keys(this.a),t.s)
return s},
bz(a){var s
if(!Object.prototype.hasOwnProperty.call(this.a,a))return null
s=A.e_(this.a[a])
return this.b[a]=s}}
A.cx.prototype={
gk(a){return this.a.gk(0)},
B(a,b){var s=this.a
return s.b==null?s.gH().B(0,b):s.a4()[b]},
gp(a){var s=this.a
if(s.b==null){s=s.gH()
s=s.gp(s)}else{s=s.a4()
s=new J.aI(s,s.length,A.H(s).i("aI<1>"))}return s},
M(a,b){return this.a.F(b)}}
A.bP.prototype={}
A.bR.prototype={}
A.ba.prototype={
j(a){var s=A.bS(this.a)
return(this.b!=null?"Converting object to an encodable object failed:":"Converting object did not return an encodable object:")+" "+s}}
A.c0.prototype={
j(a){return"Cyclic error in JSON stringify"}}
A.d0.prototype={
a9(a,b){var s=A.jL(a,this.gbL().a)
return s},
aa(a,b){var s=A.iW(a,this.gbM().b,null)
return s},
gbM(){return B.C},
gbL(){return B.B}}
A.d2.prototype={}
A.d1.prototype={}
A.dL.prototype={
bd(a){var s,r,q,p,o,n,m=a.length
for(s=this.c,r=0,q=0;q<m;++q){p=a.charCodeAt(q)
if(p>92){if(p>=55296){o=p&64512
if(o===55296){n=q+1
n=!(n<m&&(a.charCodeAt(n)&64512)===56320)}else n=!1
if(!n)if(o===56320){o=q-1
o=!(o>=0&&(a.charCodeAt(o)&64512)===55296)}else o=!1
else o=!0
if(o){if(q>r)s.a+=B.h.V(a,r,q)
r=q+1
o=A.C(92)
s.a+=o
o=A.C(117)
s.a+=o
o=A.C(100)
s.a+=o
o=p>>>8&15
o=A.C(o<10?48+o:87+o)
s.a+=o
o=p>>>4&15
o=A.C(o<10?48+o:87+o)
s.a+=o
o=p&15
o=A.C(o<10?48+o:87+o)
s.a+=o}}continue}if(p<32){if(q>r)s.a+=B.h.V(a,r,q)
r=q+1
o=A.C(92)
s.a+=o
switch(p){case 8:o=A.C(98)
s.a+=o
break
case 9:o=A.C(116)
s.a+=o
break
case 10:o=A.C(110)
s.a+=o
break
case 12:o=A.C(102)
s.a+=o
break
case 13:o=A.C(114)
s.a+=o
break
default:o=A.C(117)
s.a+=o
o=A.C(48)
s.a+=o
o=A.C(48)
s.a+=o
o=p>>>4&15
o=A.C(o<10?48+o:87+o)
s.a+=o
o=p&15
o=A.C(o<10?48+o:87+o)
s.a+=o
break}}else if(p===34||p===92){if(q>r)s.a+=B.h.V(a,r,q)
r=q+1
o=A.C(92)
s.a+=o
o=A.C(p)
s.a+=o}}if(r===0)s.a+=a
else if(r<m)s.a+=B.h.V(a,r,m)},
aj(a){var s,r,q,p
for(s=this.a,r=s.length,q=0;q<r;++q){p=s[q]
if(a==null?p==null:a===p)throw A.a(new A.c0(a,null))}s.push(a)},
ae(a){var s,r,q,p,o=this
if(o.bc(a))return
o.aj(a)
try{s=o.b.$1(a)
if(!o.bc(s)){q=A.fQ(a,null,o.gaX())
throw A.a(q)}o.a.pop()}catch(p){r=A.S(p)
q=A.fQ(a,r,o.gaX())
throw A.a(q)}},
bc(a){var s,r,q,p=this
if(typeof a=="number"){if(!isFinite(a))return!1
s=p.c
r=B.b.j(a)
s.a+=r
return!0}else if(a===!0){p.c.a+="true"
return!0}else if(a===!1){p.c.a+="false"
return!0}else if(a==null){p.c.a+="null"
return!0}else if(typeof a=="string"){s=p.c
s.a+='"'
p.bd(a)
s.a+='"'
return!0}else if(t.j.b(a)){p.aj(a)
p.c9(a)
p.a.pop()
return!0}else if(t.f.b(a)){p.aj(a)
q=p.ca(a)
p.a.pop()
return q}else return!1},
c9(a){var s,r,q=this.c
q.a+="["
s=J.Q(a)
if(s.gK(a)){this.ae(s.h(a,0))
for(r=1;r<s.gk(a);++r){q.a+=","
this.ae(s.h(a,r))}}q.a+="]"},
ca(a){var s,r,q,p,o,n=this,m={}
if(a.gv(a)){n.c.a+="{}"
return!0}s=a.gk(a)*2
r=A.bb(s,null,!1,t.X)
q=m.a=0
m.b=!0
a.u(0,new A.dM(m,r))
if(!m.b)return!1
p=n.c
p.a+="{"
for(o='"';q<s;q+=2,o=',"'){p.a+=o
n.bd(A.aA(r[q]))
p.a+='":'
n.ae(r[q+1])}p.a+="}"
return!0}}
A.dM.prototype={
$2(a,b){var s,r,q,p
if(typeof a!="string")this.a.b=!1
s=this.b
r=this.a
q=r.a
p=r.a=q+1
s[q]=a
r.a=p+1
s[p]=b},
$S:14}
A.dK.prototype={
gaX(){var s=this.c.a
return s.charCodeAt(0)==0?s:s}}
A.E.prototype={
P(a,b){if(b==null)return!1
return b instanceof A.E&&this.a===b.a&&this.b===b.b&&this.c===b.c},
gA(a){return A.iF(this.a,this.b)},
ab(a){var s=this.a,r=a.a
if(s>=r)s=s===r&&this.b<a.b
else s=!0
return s},
N(a){var s=this.a,r=a.a
if(s<=r)s=s===r&&this.b>a.b
else s=!0
return s},
X(a,b){var s=B.d.X(this.a,b.a)
if(s!==0)return s
return B.d.X(this.b,b.b)},
j(a){var s=this,r=A.fP(A.I(s)),q=A.a2(A.V(s)),p=A.a2(A.U(s)),o=A.a2(A.fX(s)),n=A.a2(A.fZ(s)),m=A.a2(A.h_(s)),l=A.cM(A.fY(s)),k=s.b,j=k===0?"":A.cM(k)
k=r+"-"+q
if(s.c)return k+"-"+p+" "+o+":"+n+":"+m+"."+l+j+"Z"
else return k+"-"+p+" "+o+":"+n+":"+m+"."+l+j},
bb(){var s=this,r=A.I(s)>=-9999&&A.I(s)<=9999?A.fP(A.I(s)):A.io(A.I(s)),q=A.a2(A.V(s)),p=A.a2(A.U(s)),o=A.a2(A.fX(s)),n=A.a2(A.fZ(s)),m=A.a2(A.h_(s)),l=A.cM(A.fY(s)),k=s.b,j=k===0?"":A.cM(k)
k=r+"-"+q
if(s.c)return k+"-"+p+"T"+o+":"+n+":"+m+"."+l+j+"Z"
else return k+"-"+p+"T"+o+":"+n+":"+m+"."+l+j}}
A.cO.prototype={
$1(a){if(a==null)return 0
return A.cF(a)},
$S:15}
A.cP.prototype={
$1(a){var s,r,q
if(a==null)return 0
for(s=a.length,r=0,q=0;q<6;++q){r*=10
if(q<s)r+=a.charCodeAt(q)^48}return r},
$S:15}
A.du.prototype={
j(a){return this.bv()}}
A.t.prototype={
ga0(){return A.iH(this)}}
A.bM.prototype={
j(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.bS(s)
return"Assertion failed"}}
A.a7.prototype={}
A.Z.prototype={
gam(){return"Invalid argument"+(!this.a?"(s)":"")},
gal(){return""},
j(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+A.d(p),n=s.gam()+q+o
if(!s.a)return n
return n+s.gal()+": "+A.bS(s.gaD())},
gaD(){return this.b}}
A.bi.prototype={
gaD(){return this.b},
gam(){return"RangeError"},
gal(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.d(q):""
else if(q==null)s=": Not greater than or equal to "+A.d(r)
else if(q>r)s=": Not in inclusive range "+A.d(r)+".."+A.d(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.d(r)
return s}}
A.bU.prototype={
gaD(){return this.b},
gam(){return"RangeError"},
gal(){if(this.b<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gk(a){return this.f}}
A.bm.prototype={
j(a){return"Unsupported operation: "+this.a}}
A.ci.prototype={
j(a){var s=this.a
return s!=null?"UnimplementedError: "+s:"UnimplementedError"}}
A.ax.prototype={
j(a){return"Bad state: "+this.a}}
A.bQ.prototype={
j(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.bS(s)+"."}}
A.bj.prototype={
j(a){return"Stack Overflow"},
ga0(){return null},
$it:1}
A.dv.prototype={
j(a){return"Exception: "+this.a}}
A.cS.prototype={
j(a){var s=this.a,r=""!==s?"FormatException: "+s:"FormatException",q=this.b
if(typeof q=="string"){if(q.length>78)q=B.h.V(q,0,75)+"..."
return r+"\n"+q}else return r}}
A.f.prototype={
a7(a,b){return A.ig(this,A.u(this).i("f.E"),b)},
U(a,b,c){return A.iE(this,b,A.u(this).i("f.E"),c)},
aJ(a,b){return new A.N(this,b,A.u(this).i("N<f.E>"))},
u(a,b){var s
for(s=this.gp(this);s.l();)b.$1(s.gm())},
gk(a){var s,r=this.gp(this)
for(s=0;r.l();)++s
return s},
gv(a){return!this.gp(this).l()},
gK(a){return!this.gv(this)},
gD(a){var s=this.gp(this)
if(!s.l())throw A.a(A.a3())
return s.gm()},
gL(a){var s,r=this.gp(this)
if(!r.l())throw A.a(A.a3())
do s=r.gm()
while(r.l())
return s},
B(a,b){var s,r
A.h2(b,"index")
s=this.gp(this)
for(r=b;s.l();){if(r===0)return s.gm();--r}throw A.a(A.fh(b,b-r,this,"index"))},
j(a){return A.ix(this,"(",")")}}
A.aK.prototype={
j(a){return"MapEntry("+A.d(this.a)+": "+A.d(this.b)+")"}}
A.A.prototype={
gA(a){return A.l.prototype.gA.call(this,0)},
j(a){return"null"}}
A.l.prototype={$il:1,
P(a,b){return this===b},
gA(a){return A.bh(this)},
j(a){return"Instance of '"+A.d8(this)+"'"},
gq(a){return A.k6(this)},
toString(){return this.j(this)}}
A.cA.prototype={
j(a){return this.a},
$iW:1}
A.bk.prototype={
gk(a){return this.a.length},
j(a){var s=this.a
return s.charCodeAt(0)==0?s:s}}
A.ed.prototype={
$1(a){var s,r,q,p
if(A.hB(a))return a
s=this.a
if(s.F(a))return s.h(0,a)
if(t.d.b(a)){r={}
s.n(0,a,r)
for(s=a.gH(),s=s.gp(s);s.l();){q=s.gm()
r[q]=this.$1(a.h(0,q))}return r}else if(t.x.b(a)){p=[]
s.n(0,a,p)
B.a.W(p,J.cJ(a,this,t.z))
return p}else return a},
$S:7}
A.f7.prototype={
$1(a){return this.a.Y(a)},
$S:3}
A.f8.prototype={
$1(a){if(a==null)return this.a.b2(new A.d6(a===undefined))
return this.a.b2(a)},
$S:3}
A.e4.prototype={
$1(a){var s,r,q,p,o,n,m,l,k,j,i,h
if(A.hA(a))return a
s=this.a
a.toString
if(s.F(a))return s.h(0,a)
if(a instanceof Date){r=a.getTime()
if(r<-864e13||r>864e13)A.aD(A.a6(r,-864e13,864e13,"millisecondsSinceEpoch",null))
A.cE(!0,"isUtc",t.y)
return new A.E(r,0,!0)}if(a instanceof RegExp)throw A.a(A.ap("structured clone of RegExp",null))
if(typeof Promise!="undefined"&&a instanceof Promise)return A.kj(a,t.X)
q=Object.getPrototypeOf(a)
if(q===Object.prototype||q===null){p=t.X
o=A.c3(p,p)
s.n(0,a,o)
n=Object.keys(a)
m=[]
for(s=J.Q(n),p=s.gp(n);p.l();)m.push(A.hL(p.gm()))
for(l=0;l<s.gk(n);++l){k=s.h(n,l)
j=m[l]
if(k!=null)o.n(0,j,this.$1(a[k]))}return o}if(a instanceof Array){i=a
o=[]
s.n(0,a,o)
h=a.length
for(s=J.aC(i),l=0;l<h;++l)o.push(this.$1(s.h(i,l)))
return o}return a},
$S:7}
A.d6.prototype={
j(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.eq.prototype={
$1(a){return a*3.141592653589793/180},
$S:23}
A.eN.prototype={
$2(a,b){return a.N(b)?a:b},
$S:18}
A.eO.prototype={
$2(a,b){return a.ab(b)?a:b},
$S:18}
A.er.prototype={
$5$errorMargin(a,b,c,d,e){var s=this.a,r=s.$1(c-a)/2,q=s.$1(d-b)/2,p=Math.sin(r)*Math.sin(r)+Math.cos(s.$1(a))*Math.cos(s.$1(c))*Math.sin(q)*Math.sin(q)
return 6371*(2*Math.atan2(Math.sqrt(p),Math.sqrt(1-p)))*(1+e)},
$4(a,b,c,d){return this.$5$errorMargin(a,b,c,d,0.15)},
$S:22}
A.es.prototype={
$1(a){var s="pickupPlace",r="latitude",q="longitude",p="deliveryPlace",o=this.a.$4(J.k(a.h(0,s),r),J.k(a.h(0,s),q),J.k(a.h(0,p),r),J.k(a.h(0,p),q)),n=o>0?J.i7(a.h(0,"price"),o):0
A.i("  OrderID: "+A.d(a.h(0,"orderID"))+", Distance: "+B.b.C(o,2)+" km, Price/Km: "+B.b.C(n,2)+" EUR/km")
return n},
$S:20}
A.eK.prototype={
$2(a,b){var s,r,q,p,o,n,m="maxWeight",l=this.a.$1(a),k=this.b,j=k.b5(k,new A.eL(a),new A.eM())
if(j.gv(j)){A.i("  OrderID: "+A.d(a.h(0,"orderID"))+" - Car type '"+A.d(a.h(0,"carTypeName"))+"' not found.")
return!1}s=A.cN(this.c)
r=A.cN(J.k(a.h(0,"pickupTimeWindow"),"end"))
q=J.fG(a.h(0,"weight"),j.h(0,m))
p=J.fG(a.h(0,"ldm"),j.h(0,"length"))
o=l>=b
n=r.N(s)
A.i("  OrderID: "+A.d(a.h(0,"orderID"))+", Weight OK: "+q+" ("+A.d(a.h(0,"weight"))+" <= "+A.d(j.h(0,m))+"), LDM OK: "+p+" ("+A.d(a.h(0,"ldm"))+" <= "+A.d(j.h(0,"length"))+"), Price OK: "+o+" ("+A.d(l)+" >= "+A.d(b)+"), Time OK: "+n+" (Pickup End: "+r.j(0)+" > Now: "+s.j(0)+")")
return q&&p&&o&&n},
$S:21}
A.eL.prototype={
$1(a){return J.T(a.h(0,"name"),this.a.h(0,"carTypeName"))},
$S:1}
A.eM.prototype={
$0(){return A.c3(t.N,t.z)},
$S:17}
A.eu.prototype={
$1(a){var s,r,q
if(a.length===0)return!1
if(B.a.bJ(a,new A.ev())){if(!B.a.b4(a,new A.ew())){A.i("  Group ADR validation failed: Non-ADR order cannot group with ADR.")
return!1}s=A.H(a).i("N<1>")
r=A.aw(new A.N(a,new A.ex(),s),!0,s.i("f.E"))
if(r.length>1){q=B.a.b4(r,new A.ey())
A.i("  Multiple ADR orders: Can group with ADR: "+q)
return q}A.i("  Single ADR order detected, grouping OK.")
return!0}A.i("  No ADR orders, grouping OK.")
return!0},
$S:48}
A.ev.prototype={
$1(a){return A.cC(a.h(0,"isAdrOrder"))},
$S:1}
A.ew.prototype={
$1(a){return A.cC(a.h(0,"isAdrOrder"))||A.cC(a.h(0,"canGroupWithAdr"))},
$S:1}
A.ex.prototype={
$1(a){return A.cC(a.h(0,"isAdrOrder"))},
$S:1}
A.ey.prototype={
$1(a){return A.cC(a.h(0,"canGroupWithAdr"))},
$S:1}
A.eP.prototype={
$1(a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d="pickupPlace",c="latitude",b="longitude",a="deliveryPlace"
if(a0.length===0)return A.v([],t.Y)
A.i("  Optimizing route for group: "+new A.q(a0,new A.eQ(),A.H(a0).i("q<1,@>")).G(0,", "))
s=A.v([],t.t)
for(r=a0.length,q=t.N,p=t.z,o=0;o<a0.length;a0.length===r||(0,A.b_)(a0),++o){n=a0[o]
s.push(A.w(["type","pickup","orderId",n.h(0,"orderID"),"lat",J.k(n.h(0,d),c),"lon",J.k(n.h(0,d),b)],q,p))
s.push(A.w(["type","delivery","orderId",n.h(0,"orderID"),"lat",J.k(n.h(0,a),c),"lon",J.k(n.h(0,a),b)],q,p))}m=s.length
l=A.v(new Array(m),t.b)
for(r=t.i,k=0;k<m;++k)l[k]=A.bb(m,0,!1,r)
for(r=this.a,k=0;k<m;++k)for(j=0;j<m;++j)if(k!==j)l[k][j]=r.$4(s[k].h(0,"lat"),s[k].h(0,"lon"),s[j].h(0,"lat"),s[j].h(0,"lon"))
i=A.bb(m,!1,!1,t.y)
h=A.v([],t.Y)
i[0]=!0
h.push(0)
for(g=0;h.length<m;g=e){for(f=1/0,e=-1,k=0;k<m;++k)if(!i[k]&&l[g][k]<f){if(J.T(s[k].h(0,"type"),"delivery"))if(!i[B.a.bQ(s,new A.eR(s,k))])continue
f=l[g][k]
e=k}if(e===-1)break
i[e]=!0
h.push(e)}A.i("  Optimized route: "+new A.q(h,new A.eS(s),t.cQ).G(0," -> "))
return h},
$S:25}
A.eQ.prototype={
$1(a){return a.h(0,"orderID")},
$S:2}
A.eR.prototype={
$1(a){return J.T(a.h(0,"type"),"pickup")&&J.T(a.h(0,"orderId"),this.a[this.b].h(0,"orderId"))},
$S:1}
A.eS.prototype={
$1(a){var s=this.a
return A.d(s[a].h(0,"type"))+"-"+A.d(s[a].h(0,"orderId"))},
$S:27}
A.f2.prototype={
$2(a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c="pickupTimeWindow",b="start",a="deliveryTimeWindow",a0="end",a1="/2 valid overlaps"
if(a2.length===0||a3.length===0){A.i("  Time window validation failed: Group or route empty.")
return!1}s=new A.f6()
r=A.cN(this.a)
A.i("  Validating time windows for group: "+new A.q(a2,new A.f3(),A.H(a2).i("q<1,@>")).G(0,", "))
for(q=a2.length,p=this.b,o=this.c,n=r,m=n,l=0;k=a2.length,l<k;a2.length===q||(0,A.b_)(a2),++l){j=a2[l]
i=s.$1(J.k(j.h(0,c),b))
h=s.$1(J.k(j.h(0,a),a0))
m=p.$2(m,i)
n=o.$2(n,h)
A.O("    OrderID: "+A.d(j.h(0,"orderID"))+", Pickup: "+i.j(0)+" - "+h.j(0))}for(l=0;l<a2.length;a2.length===k||(0,A.b_)(a2),++l){j=a2[l]
i=s.$1(J.k(j.h(0,c),b))
g=s.$1(J.k(j.h(0,c),a0))
q=i.a
p=g.a
if(q<=p)q=q===p&&i.b>g.b
else q=!0
if(q){A.O("    OrderID: "+A.d(j.h(0,"orderID"))+" - Pickup start after end: "+i.j(0)+" > "+g.j(0))
return!1}}f=A.v([],t.t)
for(q=a3.length,p=t.N,o=t.z,l=0;l<a3.length;a3.length===q||(0,A.b_)(a3),++l){e=a3[l]
if(e===0)f.push(A.w(["start",J.k(a2[0].h(0,c),b),"end",J.k(a2[0].h(0,c),a0)],p,o))
else if(e===1)f.push(A.w(["start",J.k(a2[0].h(0,a),b),"end",J.k(a2[0].h(0,a),a0)],p,o))
else if(e===2)f.push(A.w(["start",J.k(a2[1].h(0,c),b),"end",J.k(a2[1].h(0,c),a0)],p,o))
else if(e===3)f.push(A.w(["start",J.k(a2[1].h(0,a),b),"end",J.k(a2[1].h(0,a),a0)],p,o))
else if(e===4)f.push(A.w(["start",J.k(a2[2].h(0,c),b),"end",J.k(a2[2].h(0,c),a0)],p,o))
else if(e===5)f.push(A.w(["start",J.k(a2[2].h(0,a),b),"end",J.k(a2[2].h(0,a),a0)],p,o))}q=new A.f4(s)
p=new A.f5(s)
if(a2.length===2){d=q.$2(f[0],f[1])?1:0
if(q.$2(f[2],f[3]))++d
A.i("    Two-order time validation: "+d+a1)
return d===2}else{d=p.$3(f[0],f[1],f[2])?1:0
if(p.$3(f[3],f[4],f[5]))++d
A.i("    Three-order time validation: "+d+a1)
return d===2}},
$S:28}
A.f6.prototype={
$1(a){return A.cN(a)},
$S:29}
A.f3.prototype={
$1(a){return a.h(0,"orderID")},
$S:2}
A.f4.prototype={
$2(a,b){var s,r="end",q=this.a,p=q.$1(a.h(0,"start")),o=q.$1(b.h(0,"start")),n=A.a1(A.I(p),A.V(p),A.U(p)),m=A.a1(A.I(q.$1(a.h(0,r))),A.V(q.$1(a.h(0,r))),A.U(q.$1(a.h(0,r)))),l=A.a1(A.I(o),A.V(o),A.U(o)),k=A.a1(A.I(q.$1(b.h(0,r))),A.V(q.$1(b.h(0,r))),A.U(q.$1(b.h(0,r))))
if(!n.ab(k))q=n.a===k.a&&n.b===k.b
else q=!0
if(q)if(!m.N(l)){q=m.a===l.a&&m.b===l.b
s=q}else s=!0
else s=!1
A.i("      Time Window Check: "+n.j(0)+" - "+m.j(0)+" vs "+l.j(0)+" - "+k.j(0)+": "+s)
return s},
$S:30}
A.f5.prototype={
$3(a,b,c){var s,r,q,p,o,n,m,l="start",k="end",j=this.a,i=j.$1(a.h(0,l)),h=j.$1(b.h(0,l)),g=j.$1(c.h(0,l))
if(i.N(j.$1(a.h(0,k))))return!1
if(h.N(j.$1(b.h(0,k))))return!1
if(g.N(j.$1(c.h(0,k))))return!1
s=A.a1(A.I(i),A.V(i),A.U(i))
r=A.a1(A.I(j.$1(a.h(0,k))),A.V(j.$1(a.h(0,k))),A.U(j.$1(a.h(0,k))))
q=A.a1(A.I(h),A.V(h),A.U(h))
p=A.a1(A.I(j.$1(b.h(0,k))),A.V(j.$1(b.h(0,k))),A.U(j.$1(b.h(0,k))))
o=A.a1(A.I(g),A.V(g),A.U(g))
n=A.a1(A.I(j.$1(c.h(0,k))),A.V(j.$1(c.h(0,k))),A.U(j.$1(c.h(0,k))))
if(!s.ab(p))j=s.a===p.a&&s.b===p.b
else j=!0
m=!1
if(j){if(!q.ab(n))j=q.a===n.a&&q.b===n.b
else j=!0
if(j){if(!r.N(o))j=r.a===o.a&&r.b===o.b
else j=!0
m=j}}A.i("      Three-Way Time Window Check: "+s.j(0)+" - "+r.j(0)+" vs "+q.j(0)+" - "+p.j(0)+" vs "+o.j(0)+" - "+n.j(0)+": "+m)
return m},
$S:31}
A.et.prototype={
$2(a,b){var s,r,q,p,o,n,m,l,k,j,i,h="pickupPlace",g="latitude",f="longitude",e="deliveryPlace"
if(a.length===0||b.length===0){A.i("  Route distance calculation failed: Group or route empty.")
return 0}s=A.v([],t.t)
for(r=a.length,q=t.N,p=t.z,o=0;o<a.length;a.length===r||(0,A.b_)(a),++o){n=a[o]
s.push(A.w(["type","pickup","lat",J.k(n.h(0,h),g),"lon",J.k(n.h(0,h),f)],q,p))
s.push(A.w(["type","delivery","lat",J.k(n.h(0,e),g),"lon",J.k(n.h(0,e),f)],q,p))}for(r=this.a,m=0,l=0;l<b.length-1;){k=b[l];++l
j=b[l]
i=r.$4(s[k].h(0,"lat"),s[k].h(0,"lon"),s[j].h(0,"lat"),s[j].h(0,"lon"))
m=(m+i)*1.1
A.O("    Segment "+A.d(s[k].h(0,"type"))+"-"+A.d(s[k].h(0,"orderId"))+" to "+A.d(s[j].h(0,"type"))+"-"+A.d(s[j].h(0,"orderId"))+": "+B.b.C(i,2)+" km, Cumulative: "+B.b.C(m,2)+" km")}A.i("  Total Route Distance: "+B.b.C(m,2)+" km")
return m},
$S:40}
A.eT.prototype={
$2(a,b){var s,r,q,p,o,n="pickupPlace",m="latitude",l="longitude",k="deliveryPlace",j=A.v([],t.Y)
for(s=this.b,r=this.a,q=0;q<a.length;++q){p=r.$4(J.k(a[b].h(0,n),m),J.k(a[b].h(0,n),l),J.k(a[q].h(0,n),m),J.k(a[q].h(0,n),l))
o=r.$4(J.k(a[b].h(0,k),m),J.k(a[b].h(0,k),l),J.k(a[q].h(0,k),m),J.k(a[q].h(0,k),l))
if(p<=s&&o<=s)j.push(q)}A.i("    Region Query for OrderID: "+A.d(a[b].h(0,"orderID"))+", Neighbors: "+j.length)
return j},
$S:33}
A.eH.prototype={
$5(a,b,c,d,e){var s,r,q,p,o,n,m,l="orderID"
b[c]=e
s=this.a
J.cG(s.bX(e,new A.eI()),a[c])
A.i("      Expanding Cluster "+e+", Added OrderID: "+A.d(a[c].h(0,l)))
r=A.fU(d,t.S)
for(q=this.c,p=this.b;r.length!==0;){o=r.pop()
if(b[o]===-1){b[o]=e
n=s.h(0,e)
if(n!=null)J.cG(n,a[o])
A.O("      Added Noise-to-Cluster OrderID: "+A.d(a[o].h(0,l)))}if(b[o]!=null)continue
b[o]=e
n=s.h(0,e)
if(n!=null)J.cG(n,a[o])
A.O("      Added Core OrderID: "+A.d(a[o].h(0,l)))
m=p.$2(a,o)
if(J.aH(m)>=q){B.a.W(r,new A.N(m,new A.eJ(b),A.H(m).i("N<1>")))
A.O("      Expanded with "+m.length+" neighbors for OrderID: "+A.d(a[o].h(0,l)))}}},
$S:34}
A.eI.prototype={
$0(){return A.v([],t.t)},
$S:35}
A.eJ.prototype={
$1(a){return this.a[a]==null},
$S:36}
A.ez.prototype={
$2(a,b){A.i("  Cluster "+a+": "+J.cJ(b,new A.ep(),t.z).G(0,", "))},
$S:11}
A.ep.prototype={
$1(a){return a.h(0,"orderID")},
$S:2}
A.eA.prototype={
$1(a){return a.h(0,"orderID")},
$S:2}
A.eB.prototype={
$1(a){return A.aA(a.h(0,"groupID"))},
$S:5}
A.eU.prototype={
$3(b9,c0,c1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1=this,b2="maxWeight",b3="pickupPlace",b4="deliveryPlace",b5="latitude",b6="longitude",b7="    Pickup Distance (0-1): ",b8=b9.length
if(b8===0||b8>3){A.i("  Group Validation Failed: Empty or too large ("+b8+" orders).")
return A.w(["status","noise"],t.N,t.z)}b8=A.H(b9)
A.i("\n  Validating Group: "+new A.q(b9,new A.eV(),b8.i("q<1,@>")).G(0,", "))
s=B.a.aA(b9,0,new A.eW())
r=B.a.aA(b9,0,new A.eX())
q=b1.a
p=q.b5(q,new A.eY(b9),new A.eZ(q))
o=s<=p.h(0,b2)
n=r<=p.h(0,"length")
A.i("    Total Weight: "+B.b.C(s,2)+" tons (Max: "+A.d(p.h(0,b2))+"), OK: "+o)
A.i("    Total LDM: "+B.b.C(r,2)+" (Max: "+A.d(p.h(0,"length"))+"), OK: "+n)
m=b1.b.$1(b9)
l=A.v([],t.t)
for(q=m.length,k=0;k<m.length;m.length===q||(0,A.b_)(m),++k){j=m[k]
if(j===0)l.push(b9[0].h(0,b3))
else if(j===1)l.push(b9[0].h(0,b4))
else if(j===2)l.push(b9[1].h(0,b3))
else if(j===3)l.push(b9[1].h(0,b4))
else if(j===4)l.push(b9[2].h(0,b3))
else if(j===5)l.push(b9[2].h(0,b4))}i=b1.c.$1(b9)
A.i("    ADR Validation: "+A.d(i))
h=b1.d.$2(b9,m)
g=B.a.aA(b9,0,new A.f_())
f=h>0?g/h:0
e=f>=c1
A.i(" "+A.d(f)+" "+A.d(c1)+"    Total Price: "+B.b.C(g,2)+" EUR, Price/Km: "+B.b.C(f,2)+" EUR/km, OK: "+e)
q=b9.length
if(q===2){q=b1.e
d=q.$4(l[0].h(0,b5),l[0].h(0,b6),l[1].h(0,b5),l[1].h(0,b6))
c=d<=c0
b=B.f.O(!0,c)
A.i(b7+B.b.C(d,2)+" km, OK: "+c)
a=q.$4(l[2].h(0,b5),l[2].h(0,b6),l[3].h(0,b5),l[3].h(0,b6))
q=a<=c0
b=B.f.O(b,q)
A.i("    Delivery Distance (2-3): "+B.b.C(a,2)+" km, OK: "+q)}else if(q===3){q=b1.e
a0=q.$4(l[0].h(0,b5),l[0].h(0,b6),l[1].h(0,b5),l[1].h(0,b6))
c=a0<=c0
b=B.f.O(!0,c)
A.i(b7+B.b.C(a0,2)+" km, OK: "+c)
a1=q.$4(l[1].h(0,b5),l[1].h(0,b6),l[2].h(0,b5),l[2].h(0,b6))
c=a1<=c0
b=B.f.O(b,c)
A.i("    Pickup Distance (1-2): "+B.b.C(a1,2)+" km, OK: "+c)
a2=q.$4(l[3].h(0,b5),l[3].h(0,b6),l[4].h(0,b5),l[4].h(0,b6))
c=a2<=c0
b=B.f.O(b,c)
A.i("    Delivery Distance (3-4): "+B.b.C(a2,2)+" km, OK: "+c)
a3=q.$4(l[4].h(0,b5),l[4].h(0,b6),l[5].h(0,b5),l[5].h(0,b6))
q=a3<=c0
b=B.f.O(b,q)
A.i("    Delivery Distance (4-5): "+B.b.C(a3,2)+" km, OK: "+q)}else b=!0
a4=b1.f.$2(b9,m)
A.i("    Time Window Validation: "+A.d(a4))
a5=!b?1:0
if(!a4)++a5
if(!e)++a5
A.i("    Failed Criteria: "+a5)
if(!o||!n||!i){A.i("    Failed Weight/LDM/ADR: Marked as Noise")
return A.w(["status","noise"],t.N,t.z)}q=b8.i("q<1,c>")
a6=B.a.G(A.aw(new A.q(b9,new A.f0(),q),!0,q.i("D.E")),"-").toUpperCase()
b8=b8.i("q<1,e<c,@>>")
a7=A.aw(new A.q(b9,new A.f1(a6),b8),!0,b8.i("D.E"))
b8=new A.E(Date.now(),0,!1).bb()
q=t.L
c=q.a(J.k(B.a.gD(a7),"comments"))
if(c==null)c=[]
q=q.a(J.k(B.a.gD(a7),"orderLogs"))
if(q==null)q=[]
a8=t.N
a9=t.z
b0=A.w(["groupID",a6,"orders",a7,"totalDistance",h,"pricePerKm",f,"totalPrice",g,"totalLDM",r,"totalWeight",s,"status","Pending","creatorID","system","creatorName","System","createdAt",b8,"lastModifiedAt",null,"isEditing",!1,"comments",c,"logs",q,"driverInfo",J.k(B.a.gD(a7),"driverInfo")],a8,a9)
if(a5===0){A.i("    All criteria met: Marked as Best Group - "+a6)
return A.w(["status","best","group",b0],a8,a9)}if(a5<=2){A.i("    Up to 2 criteria failed: Marked as Suggestion Group - "+a6)
return A.w(["status","suggestion","group",b0],a8,a9)}A.i("    More than 2 criteria failed: Marked as Noise")
return A.w(["status","noise"],a8,a9)},
$S:39}
A.eV.prototype={
$1(a){return a.h(0,"orderID")},
$S:2}
A.eW.prototype={
$2(a,b){return a+A.ab(b.h(0,"weight"))},
$S:6}
A.eX.prototype={
$2(a,b){return a+A.ab(b.h(0,"ldm"))},
$S:6}
A.eY.prototype={
$1(a){return J.T(a.h(0,"name"),B.a.gD(this.a).h(0,"carTypeName"))},
$S:1}
A.eZ.prototype={
$0(){var s=this.a
return s.gD(s)},
$S:17}
A.f_.prototype={
$2(a,b){return a+A.ab(b.h(0,"price"))},
$S:6}
A.f0.prototype={
$1(a){return A.aA(a.h(0,"orderID"))},
$S:5}
A.f1.prototype={
$1(a){var s,r,q,p,o,n="pickupPlace",m="countryCode",l="postalCode",k="latitude",j="longitude",i="deliveryPlace",h=t.N,g=A.fR(a,h,t.z)
g.n(0,"connectedGroupID",this.a)
g.n(0,"isConnected",!0)
s=A.X(J.k(g.h(0,n),m))
if(s==null)s=""
r=A.X(J.k(g.h(0,n),l))
if(r==null)r=""
q=A.X(J.k(g.h(0,n),"name"))
if(q==null)q=""
p=A.X(J.k(g.h(0,n),"code"))
if(p==null)p=""
o=t.K
g.n(0,n,A.w(["countryCode",s,"postalCode",r,"name",q,"code",p,"latitude",A.ab(J.k(g.h(0,n),k)),"longitude",A.ab(J.k(g.h(0,n),j))],h,o))
p=A.X(J.k(g.h(0,i),m))
s=p==null?"":p
r=A.X(J.k(g.h(0,i),l))
if(r==null)r=""
q=A.X(J.k(g.h(0,i),"name"))
if(q==null)q=""
p=A.X(J.k(g.h(0,i),"code"))
if(p==null)p=""
g.n(0,i,A.w(["countryCode",s,"postalCode",r,"name",q,"code",p,"latitude",A.ab(J.k(g.h(0,i),k)),"longitude",A.ab(J.k(g.h(0,i),j))],h,o))
return g},
$S:41}
A.eC.prototype={
$2(a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=this,a0=""+a2,a1=J.aC(a3)
A.i("\n  Processing Cluster "+a0+" with "+a1.gk(a3)+" orders")
s=A.fU(a3,t.a)
r=A.fS(t.N)
for(q=a.a,p=a.b,o=a.c,n=t.M,m=n.i("D.E"),l=t.t,k=a.d,j=0;j<a1.gk(a3);j=i)for(i=j+1,h=i;h<a1.gk(a3);h=g)for(g=h+1,f=g;f<=a1.gk(a3);++f){e=A.v([a1.h(a3,j),a1.h(a3,h)],l)
if(f<a1.gk(a3))e.push(a1.h(a3,f))
d=A.aw(new A.q(e,new A.em(),n),!0,m)
B.a.aM(d)
c=B.a.G(d,"-")
if(r.M(0,c)){A.O("    Skipping already checked group: "+c)
continue}r.E(0,c)
b=q.$3(e,p,o)
if(J.T(b.h(0,"status"),"best")){k.push(b.h(0,"group"))
B.a.u(e,new A.en(s))}}B.a.W(a.e,s)
A.i("  Remaining Noise Orders in Cluster "+a0+": "+new A.q(s,new A.eo(),A.H(s).i("q<1,@>")).G(0,", "))},
$S:11}
A.em.prototype={
$1(a){return A.aA(a.h(0,"orderName"))},
$S:5}
A.en.prototype={
$1(a){return B.a.bZ(this.a,new A.eh(a))},
$S:4}
A.eh.prototype={
$1(a){return J.T(a.h(0,"orderID"),this.a.h(0,"orderID"))},
$S:1}
A.eo.prototype={
$1(a){return a.h(0,"orderID")},
$S:2}
A.eD.prototype={
$2(a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=this
A.i("\n  Processing Suggestions for Cluster "+a1)
s=J.ic(a2,new A.ek(a0.a))
r=A.aw(s,!0,s.$ti.i("f.E"))
q=A.fS(t.N)
for(s=a0.b,p=a0.c,o=a0.d,n=t.M,m=n.i("D.E"),l=t.t,k=a0.e,j=0;i=r.length,j<i;j=h)for(h=j+1,g=h;g<i;g=f)for(f=g+1,e=f;e<=i;++e){d=A.v([r[j],r[g]],l)
if(e<i)d.push(r[e])
c=A.aw(new A.q(d,new A.el(),n),!0,m)
B.a.aM(c)
b=B.a.G(c,"-")
if(q.M(0,b)){A.O("    Skipping already checked group: "+b)
continue}q.E(0,b)
a=s.$3(d,p,o)
if(J.T(a.h(0,"status"),"suggestion"))k.push(a.h(0,"group"))}},
$S:11}
A.ek.prototype={
$1(a){return!this.a.M(0,a.h(0,"orderID"))},
$S:1}
A.el.prototype={
$1(a){return A.aA(a.h(0,"orderID"))},
$S:5}
A.eE.prototype={
$1(a){A.i("  Group: "+A.d(a.h(0,"groupID")))
J.fI(t.j.a(a.h(0,"orders")),new A.ej())},
$S:4}
A.ej.prototype={
$1(a){return A.i("    OrderID: "+A.d(J.k(a,"orderID")))},
$S:3}
A.eF.prototype={
$1(a){A.i("  Group: "+A.d(a.h(0,"groupID")))
J.fI(t.j.a(a.h(0,"orders")),new A.ei())},
$S:4}
A.ei.prototype={
$1(a){return A.i("    OrderID: "+A.d(J.k(a,"orderID")))},
$S:3}
A.eG.prototype={
$1(a){return A.i("  OrderID: "+A.d(a.h(0,"orderID")))},
$S:4}
A.cX.prototype={
$1(a){return a},
$S(){return this.a.i("0(@)")}}
A.bW.prototype={
bk(a,b,c,d,e,f){this.a.onmessage=A.hu(new A.cW(this))},
gb3(){return this.a},
gb9(){return A.aD(A.bl(null))},
b6(){return A.aD(A.bl(null))},
a_(a){return A.aD(A.bl(null))},
aL(a){return A.aD(A.bl(null))},
T(){var s=0,r=A.hz(t.H),q=this
var $async$T=A.hI(function(a,b){if(a===1)return A.ho(b,r)
while(true)switch(s){case 0:q.a.terminate()
s=2
return A.ji(q.b.T(),$async$T)
case 2:return A.hp(null,r)}})
return A.hq($async$T,r)}}
A.cW.prototype={
$1(a){var s,r,q,p=this,o=A.fy(a.data)
if(B.x.b7(o)){s=p.a
s.c.$0()
s.T()
return}if(B.y.b7(o)){s=p.a.f
if((s.a.a&30)===0)s.bK()
return}if(A.iw(o)){r=J.k(B.e.a9(J.ag(o),null),"$IsolateException")
s=J.aC(r)
q=s.h(r,"error")
s.h(r,"stack")
p.a.b.bI(J.ag(q),B.i)
return}s=p.a
s.b.E(0,s.d.$1(o))},
$S:16}
A.cY.prototype={
aI(){var s=t.N
return B.e.aa(A.w(["$IsolateException",A.w(["error",J.ag(this.a),"stack",this.b.j(0)],s,s)],s,t.c),null)}}
A.bY.prototype={
bv(){return"IsolateState."+this.b},
aI(){var s=t.N
return B.e.aa(A.w(["type","$IsolateState","value",this.b],s,s),null)},
b7(a){var s,r,q
if(typeof a!="string")return!1
try{s=t.f.a(B.e.a9(a,null))
r=J.T(J.k(s,"type"),"$IsolateState")&&J.T(J.k(s,"value"),this.b)
return r}catch(q){}return!1}}
A.e3.prototype={
$2(a,b){this.a.n(0,a,A.fx(b))},
$S:13}
A.ee.prototype={
$2(a,b){return new A.aK(A.bL(a),A.bL(b),t.w)},
$S:44}
A.b3.prototype={
a_(a){return this.a.a.a_(a)}}
A.bX.prototype={}
A.cv.prototype={
bl(a,b,c){this.a.onmessage=A.hu(new A.dI(this))},
gb9(){var s=this.b
return new A.aO(s,A.u(s).i("aO<1>"))},
a_(a){this.a.postMessage(A.bL(a))},
aL(a){this.a.postMessage(A.bL(a.aI()))},
b6(){var s=t.N
this.a.postMessage(A.bL(B.e.aa(A.w(["type","$IsolateState","value","initialized"],s,s),null)))}}
A.dI.prototype={
$1(a){this.a.b.E(0,A.fy(a.data))},
$S:16}
A.ec.prototype={
$1(a){var s,r,q,p=this.d,o=new A.a9(new A.r($.o,p.i("r<0>")),p.i("a9<0>"))
p=this.a
o.a.ad(p.gbh(),new A.eb(p),t.H)
try{o.Y(this.b.$1(a))}catch(q){s=A.S(q)
r=A.Y(q)
o.a8(s,r)}},
$S(){return this.c.i("~(0)")}}
A.eb.prototype={
$2(a,b){return this.a.a.a.aL(new A.cY(a,b))},
$S:8};(function aliases(){var s=J.aj.prototype
s.bj=s.j})();(function installTearOffs(){var s=hunkHelpers._static_2,r=hunkHelpers._static_1,q=hunkHelpers._static_0,p=hunkHelpers._instance_2u,o=hunkHelpers._instance_0u,n=hunkHelpers._instance_1u
s(J,"jw","iA",46)
r(A,"jV","iP",10)
r(A,"jW","iQ",10)
r(A,"jX","iR",10)
q(A,"hK","jP",0)
s(A,"jZ","jK",8)
q(A,"jY","jJ",0)
p(A.r.prototype,"gbs","R",8)
o(A.bs.prototype,"gbx","by",0)
r(A,"k1","jm",9)
r(A,"k_","ki",32)
r(A,"kn","fx",9)
r(A,"ko","bL",7)
n(A.b3.prototype,"gbh","a_",45)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.l,null)
q(A.l,[A.fj,J.bV,J.aI,A.f,A.bO,A.t,A.d9,A.ak,A.c4,A.ck,A.b2,A.de,A.d7,A.b1,A.bB,A.ar,A.L,A.d3,A.c2,A.cZ,A.dO,A.P,A.ct,A.dU,A.dS,A.cl,A.ah,A.aN,A.bo,A.cn,A.co,A.aQ,A.r,A.cm,A.cr,A.ds,A.cy,A.bs,A.cz,A.dX,A.cu,A.aM,A.dN,A.aT,A.n,A.bP,A.bR,A.dL,A.E,A.du,A.bj,A.dv,A.cS,A.aK,A.A,A.cA,A.bk,A.d6,A.bW,A.cY,A.b3,A.bX,A.cv])
q(J.bV,[J.b4,J.b6,J.b8,J.b7,J.b9,J.at,J.au])
q(J.b8,[J.aj,J.z,A.c5,A.be])
q(J.aj,[J.cf,J.ay,J.ai])
r(J.d_,J.z)
q(J.at,[J.b5,J.bZ])
q(A.f,[A.al,A.m,A.a5,A.N])
q(A.al,[A.aq,A.bG])
r(A.bt,A.aq)
r(A.bp,A.bG)
r(A.a0,A.bp)
q(A.t,[A.c1,A.a7,A.c_,A.cj,A.cp,A.cg,A.cs,A.ba,A.bM,A.Z,A.bm,A.ci,A.ax,A.bQ])
q(A.m,[A.D,A.av,A.bv])
r(A.as,A.a5)
q(A.D,[A.q,A.cx])
r(A.bg,A.a7)
q(A.ar,[A.cK,A.cL,A.dd,A.e7,A.e9,A.dm,A.dl,A.dY,A.dA,A.dH,A.db,A.cO,A.cP,A.ed,A.f7,A.f8,A.e4,A.eq,A.er,A.es,A.eL,A.eu,A.ev,A.ew,A.ex,A.ey,A.eP,A.eQ,A.eR,A.eS,A.f6,A.f3,A.f5,A.eH,A.eJ,A.ep,A.eA,A.eB,A.eU,A.eV,A.eY,A.f0,A.f1,A.em,A.en,A.eh,A.eo,A.ek,A.el,A.eE,A.ej,A.eF,A.ei,A.eG,A.cX,A.cW,A.dI,A.ec])
q(A.dd,[A.da,A.b0])
q(A.L,[A.a4,A.bu,A.cw])
q(A.cL,[A.e8,A.dZ,A.e2,A.dB,A.d4,A.d5,A.dM,A.eN,A.eO,A.eK,A.f2,A.f4,A.et,A.eT,A.ez,A.eW,A.eX,A.f_,A.eC,A.eD,A.e3,A.ee,A.eb])
q(A.be,[A.c6,A.aL])
q(A.aL,[A.bw,A.by])
r(A.bx,A.bw)
r(A.bc,A.bx)
r(A.bz,A.by)
r(A.bd,A.bz)
q(A.bc,[A.c7,A.c8])
q(A.bd,[A.c9,A.ca,A.cb,A.cc,A.cd,A.bf,A.ce])
r(A.bC,A.cs)
q(A.cK,[A.dn,A.dp,A.dT,A.dw,A.dD,A.dC,A.dz,A.dy,A.dx,A.dG,A.dF,A.dE,A.dc,A.dr,A.dq,A.dP,A.e1,A.dR,A.eM,A.eI,A.eZ])
r(A.aU,A.aN)
r(A.bq,A.aU)
r(A.aO,A.bq)
r(A.br,A.bo)
r(A.aP,A.br)
r(A.bn,A.cn)
r(A.a9,A.co)
q(A.cr,[A.cq,A.dt])
r(A.dQ,A.dX)
r(A.aS,A.bu)
r(A.bA,A.aM)
r(A.az,A.bA)
r(A.c0,A.ba)
r(A.d0,A.bP)
q(A.bR,[A.d2,A.d1])
r(A.dK,A.dL)
q(A.Z,[A.bi,A.bU])
r(A.bY,A.du)
s(A.bG,A.n)
s(A.bw,A.n)
s(A.bx,A.b2)
s(A.by,A.n)
s(A.bz,A.b2)})()
var v={typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{b:"int",j:"double",kh:"num",c:"String",F:"bool",A:"Null",h:"List",l:"Object",e:"Map"},mangledNames:{},types:["~()","F(e<c,@>)","@(e<c,@>)","~(@)","~(e<c,@>)","c(e<c,@>)","j(j,e<c,@>)","l?(l?)","~(l,W)","@(@)","~(~())","~(b,h<e<c,@>>)","A()","~(@,@)","~(l?,l?)","b(c?)","A(y)","e<c,@>()","E(E,E)","A(@)","j(e<c,@>)","F(e<c,@>,j)","j(j,j,j,j{errorMargin:j})","j(j)","A(@,W)","h<b>(h<e<c,@>>)","A(~())","c(b)","F(h<e<c,@>>,h<b>)","E(c)","F(e<c,@>,e<c,@>)","F(e<c,@>,e<c,@>,e<c,@>)","c(@)","h<b>(h<e<c,@>>,b)","~(h<e<c,@>>,h<b?>,b,h<b>,b)","h<e<c,@>>()","F(b)","r<@>(@)","A(l,W)","e<c,@>(h<e<c,@>>,j,j)","j(h<e<c,@>>,h<b>)","e<c,@>(e<c,@>)","@(@,c)","~(b,@)","aK<l?,l?>(@,@)","~(l?)","b(@,@)","@(c)","F(h<e<c,@>>)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti")}
A.jb(v.typeUniverse,JSON.parse('{"cf":"aj","ay":"aj","ai":"aj","b4":{"F":[],"p":[]},"b6":{"A":[],"p":[]},"b8":{"y":[]},"aj":{"y":[]},"z":{"h":["1"],"m":["1"],"y":[],"f":["1"]},"d_":{"z":["1"],"h":["1"],"m":["1"],"y":[],"f":["1"]},"at":{"j":[]},"b5":{"j":[],"b":[],"p":[]},"bZ":{"j":[],"p":[]},"au":{"c":[],"p":[]},"al":{"f":["2"]},"aq":{"al":["1","2"],"f":["2"],"f.E":"2"},"bt":{"aq":["1","2"],"al":["1","2"],"m":["2"],"f":["2"],"f.E":"2"},"bp":{"n":["2"],"h":["2"],"al":["1","2"],"m":["2"],"f":["2"]},"a0":{"bp":["1","2"],"n":["2"],"h":["2"],"al":["1","2"],"m":["2"],"f":["2"],"n.E":"2","f.E":"2"},"c1":{"t":[]},"m":{"f":["1"]},"D":{"m":["1"],"f":["1"]},"a5":{"f":["2"],"f.E":"2"},"as":{"a5":["1","2"],"m":["2"],"f":["2"],"f.E":"2"},"q":{"D":["2"],"m":["2"],"f":["2"],"D.E":"2","f.E":"2"},"N":{"f":["1"],"f.E":"1"},"bg":{"a7":[],"t":[]},"c_":{"t":[]},"cj":{"t":[]},"bB":{"W":[]},"cp":{"t":[]},"cg":{"t":[]},"a4":{"L":["1","2"],"e":["1","2"],"L.V":"2"},"av":{"m":["1"],"f":["1"],"f.E":"1"},"c5":{"y":[],"ff":[],"p":[]},"be":{"y":[]},"c6":{"fg":[],"y":[],"p":[]},"aL":{"K":["1"],"y":[]},"bc":{"n":["j"],"h":["j"],"K":["j"],"m":["j"],"y":[],"f":["j"]},"bd":{"n":["b"],"h":["b"],"K":["b"],"m":["b"],"y":[],"f":["b"]},"c7":{"cQ":[],"n":["j"],"h":["j"],"K":["j"],"m":["j"],"y":[],"f":["j"],"p":[],"n.E":"j"},"c8":{"cR":[],"n":["j"],"h":["j"],"K":["j"],"m":["j"],"y":[],"f":["j"],"p":[],"n.E":"j"},"c9":{"cT":[],"n":["b"],"h":["b"],"K":["b"],"m":["b"],"y":[],"f":["b"],"p":[],"n.E":"b"},"ca":{"cU":[],"n":["b"],"h":["b"],"K":["b"],"m":["b"],"y":[],"f":["b"],"p":[],"n.E":"b"},"cb":{"cV":[],"n":["b"],"h":["b"],"K":["b"],"m":["b"],"y":[],"f":["b"],"p":[],"n.E":"b"},"cc":{"dg":[],"n":["b"],"h":["b"],"K":["b"],"m":["b"],"y":[],"f":["b"],"p":[],"n.E":"b"},"cd":{"dh":[],"n":["b"],"h":["b"],"K":["b"],"m":["b"],"y":[],"f":["b"],"p":[],"n.E":"b"},"bf":{"di":[],"n":["b"],"h":["b"],"K":["b"],"m":["b"],"y":[],"f":["b"],"p":[],"n.E":"b"},"ce":{"dj":[],"n":["b"],"h":["b"],"K":["b"],"m":["b"],"y":[],"f":["b"],"p":[],"n.E":"b"},"cs":{"t":[]},"bC":{"a7":[],"t":[]},"r":{"aJ":["1"]},"ah":{"t":[]},"aO":{"aU":["1"],"aN":["1"]},"aP":{"bo":["1"]},"bn":{"cn":["1"]},"a9":{"co":["1"]},"bq":{"aU":["1"],"aN":["1"]},"br":{"bo":["1"]},"aU":{"aN":["1"]},"bu":{"L":["1","2"],"e":["1","2"]},"aS":{"bu":["1","2"],"L":["1","2"],"e":["1","2"],"L.V":"2"},"bv":{"m":["1"],"f":["1"],"f.E":"1"},"az":{"aM":["1"],"m":["1"],"f":["1"]},"L":{"e":["1","2"]},"aM":{"m":["1"],"f":["1"]},"bA":{"aM":["1"],"m":["1"],"f":["1"]},"cw":{"L":["c","@"],"e":["c","@"],"L.V":"@"},"cx":{"D":["c"],"m":["c"],"f":["c"],"D.E":"c","f.E":"c"},"ba":{"t":[]},"c0":{"t":[]},"h":{"m":["1"],"f":["1"]},"bM":{"t":[]},"a7":{"t":[]},"Z":{"t":[]},"bi":{"t":[]},"bU":{"t":[]},"bm":{"t":[]},"ci":{"t":[]},"ax":{"t":[]},"bQ":{"t":[]},"bj":{"t":[]},"cA":{"W":[]},"cV":{"h":["b"],"m":["b"],"f":["b"]},"dj":{"h":["b"],"m":["b"],"f":["b"]},"di":{"h":["b"],"m":["b"],"f":["b"]},"cT":{"h":["b"],"m":["b"],"f":["b"]},"dg":{"h":["b"],"m":["b"],"f":["b"]},"cU":{"h":["b"],"m":["b"],"f":["b"]},"dh":{"h":["b"],"m":["b"],"f":["b"]},"cQ":{"h":["j"],"m":["j"],"f":["j"]},"cR":{"h":["j"],"m":["j"],"f":["j"]}}'))
A.ja(v.typeUniverse,JSON.parse('{"b2":1,"bG":2,"aL":1,"bq":1,"br":1,"cr":1,"bA":1,"bP":2,"bR":2}'))
var u={c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type"}
var t=(function rtii(){var s=A.hM
return{J:s("ff"),V:s("fg"),W:s("m<@>"),C:s("t"),E:s("cQ"),q:s("cR"),Z:s("kr"),O:s("cT"),e:s("cU"),U:s("cV"),x:s("f<l?>"),b:s("z<h<j>>"),t:s("z<e<c,@>>"),s:s("z<c>"),r:s("z<@>"),Y:s("z<b>"),T:s("b6"),m:s("y"),g:s("ai"),p:s("K<@>"),G:s("h<e<c,@>>"),j:s("h<@>"),w:s("aK<l?,l?>"),c:s("e<c,c>"),a:s("e<c,@>"),f:s("e<@,@>"),d:s("e<l?,l?>"),cQ:s("q<b,c>"),M:s("q<e<c,@>,c>"),cq:s("q<e<c,@>,@>"),P:s("A"),K:s("l"),B:s("l()"),cY:s("ks"),l:s("W"),N:s("c"),R:s("p"),b7:s("a7"),c0:s("dg"),bk:s("dh"),ca:s("di"),bX:s("dj"),o:s("ay"),h:s("a9<~>"),aY:s("r<@>"),aQ:s("r<b>"),D:s("r<~>"),A:s("aS<l?,l?>"),y:s("F"),i:s("j"),z:s("@"),v:s("@(l)"),Q:s("@(l,W)"),S:s("b"),F:s("0&*"),_:s("l*"),bc:s("aJ<A>?"),L:s("h<@>?"),X:s("l?"),I:s("b?"),n:s("kh"),H:s("~"),u:s("~(l)"),k:s("~(l,W)")}})();(function constants(){B.w=J.bV.prototype
B.a=J.z.prototype
B.f=J.b4.prototype
B.d=J.b5.prototype
B.b=J.at.prototype
B.h=J.au.prototype
B.z=J.ai.prototype
B.A=J.b8.prototype
B.m=J.cf.prototype
B.j=J.ay.prototype
B.k=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.o=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof HTMLElement == "function";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
B.u=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var userAgent = navigator.userAgent;
    if (typeof userAgent != "string") return hooks;
    if (userAgent.indexOf("DumpRenderTree") >= 0) return hooks;
    if (userAgent.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
B.p=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.t=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
B.r=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
B.q=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
B.l=function(hooks) { return hooks; }

B.e=new A.d0()
B.P=new A.d9()
B.v=new A.ds()
B.c=new A.dQ()
B.x=new A.bY("dispose")
B.y=new A.bY("initialized")
B.B=new A.d1(null)
B.C=new A.d2(null)
B.D=A.R("ff")
B.E=A.R("fg")
B.F=A.R("cQ")
B.G=A.R("cR")
B.H=A.R("cT")
B.I=A.R("cU")
B.J=A.R("cV")
B.n=A.R("y")
B.K=A.R("l")
B.L=A.R("dg")
B.M=A.R("dh")
B.N=A.R("di")
B.O=A.R("dj")
B.i=new A.cA("")})();(function staticFields(){$.dJ=null
$.aF=A.v([],A.hM("z<l>"))
$.fW=null
$.fM=null
$.fL=null
$.hO=null
$.hJ=null
$.hT=null
$.e6=null
$.ea=null
$.fA=null
$.aV=null
$.bH=null
$.bI=null
$.fu=!1
$.o=B.c})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal
s($,"kp","f9",()=>A.k5("_$dart_dartClosure"))
s($,"ku","hX",()=>A.a8(A.df({
toString:function(){return"$receiver$"}})))
s($,"kv","hY",()=>A.a8(A.df({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"kw","hZ",()=>A.a8(A.df(null)))
s($,"kx","i_",()=>A.a8(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kA","i2",()=>A.a8(A.df(void 0)))
s($,"kB","i3",()=>A.a8(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kz","i1",()=>A.a8(A.h9(null)))
s($,"ky","i0",()=>A.a8(function(){try{null.$method$}catch(r){return r.message}}()))
s($,"kD","i5",()=>A.a8(A.h9(void 0)))
s($,"kC","i4",()=>A.a8(function(){try{(void 0).$method$}catch(r){return r.message}}()))
s($,"kE","fF",()=>A.iO())
s($,"kq","hW",()=>A.iL("^([+-]?\\d{4,6})-?(\\d\\d)-?(\\d\\d)(?:[ T](\\d\\d)(?::?(\\d\\d)(?::?(\\d\\d)(?:[.,](\\d+))?)?)?( ?[zZ]| ?([-+])(\\d\\d)(?::?(\\d\\d))?)?)?$"))
s($,"kP","i6",()=>A.eg(B.K))})();(function nativeSupport(){!function(){var s=function(a){var m={}
m[a]=1
return Object.keys(hunkHelpers.convertToFastObject(m))[0]}
v.getIsolateTag=function(a){return s("___dart_"+a+v.isolateTag)}
var r="___dart_isolate_tags_"
var q=Object[r]||(Object[r]=Object.create(null))
var p="_ZxYxX"
for(var o=0;;o++){var n=s(p+"_"+o+"_")
if(!(n in q)){q[n]=1
v.isolateTag=n
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.c5,ArrayBufferView:A.be,DataView:A.c6,Float32Array:A.c7,Float64Array:A.c8,Int16Array:A.c9,Int32Array:A.ca,Int8Array:A.cb,Uint16Array:A.cc,Uint32Array:A.cd,Uint8ClampedArray:A.bf,CanvasPixelArray:A.bf,Uint8Array:A.ce})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.aL.$nativeSuperclassTag="ArrayBufferView"
A.bw.$nativeSuperclassTag="ArrayBufferView"
A.bx.$nativeSuperclassTag="ArrayBufferView"
A.bc.$nativeSuperclassTag="ArrayBufferView"
A.by.$nativeSuperclassTag="ArrayBufferView"
A.bz.$nativeSuperclassTag="ArrayBufferView"
A.bd.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$0=function(){return this()}
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$1$0=function(){return this()}
Function.prototype.$5=function(a,b,c,d,e){return this(a,b,c,d,e)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$1$1=function(a){return this(a)}
Function.prototype.$2$1=function(a){return this(a)}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q){s[q].removeEventListener("load",onLoad,false)}a(b.target)}for(var r=0;r<s.length;++r){s[r].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var s=A.kf
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()
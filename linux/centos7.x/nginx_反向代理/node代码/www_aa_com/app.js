const Koa=require('koa'),
      router = require('koa-router')(); 
const app = new Koa();


router.get('/',async (ctx)=>{
    console.log('进入www.aa.com首页');
    ctx.body=`这是www.aa.com的首页 192.168.0.11`;
})

router.get('/login',async (ctx)=>{
    console.log('进入www.aa.com登录页');
    ctx.body="这是www.aa.com的登录页面";

})

app.use(router.routes());   // 启动路由
app.use(router.allowedMethods());
app.listen(7001,function(){
    console.log("http://localhost:7001");
});

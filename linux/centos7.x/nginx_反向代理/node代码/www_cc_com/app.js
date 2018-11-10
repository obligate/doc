const Koa=require('koa'),
      router = require('koa-router')(); 
const app = new Koa();


router.get('/',async (ctx)=>{
    console.log('进入www.cc.com首页');
    ctx.body=`这是www.cc.com的首页 192.168.0.10`;
})

router.get('/login',async (ctx)=>{
    console.log('进入www.cc.com登录页');
    ctx.body="这是www.cc.com的登录页面";

})

app.use(router.routes());   // 启动路由
app.use(router.allowedMethods());
app.listen(7003,function(){
    console.log("http://localhost:7003");
});

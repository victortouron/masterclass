require('!!file-loader?name=[name].[ext]!./index.html')
require('./css/tuto.webflow.css');


var ReactDOM = require('react-dom')
var React = require('react')
var createReactClass = require('create-react-class')
var Qs = require('qs')
var Cookie = require('cookie')
var XMLHttpRequest = require("xhr2")
var When = require('when')

var HTTP = new (function(){
  this.get = (url)=>this.req('GET',url)
  this.delete = (url)=>this.req('DELETE',url)
  this.post = (url,data)=>this.req('POST',url,data)
  this.put = (url,data)=>this.req('PUT',url,data)

  this.req = (method,url,data)=> new Promise((resolve, reject) => {
    var req = new XMLHttpRequest()
    req.open(method, url)
    req.responseType = "text"
    req.setRequestHeader("accept","application/json,*/*;0.8")
    req.setRequestHeader("content-type","application/json")
    req.onload = ()=>{
      if(req.status >= 200 && req.status < 300){
        resolve(req.responseText && JSON.parse(req.responseText))
      }else{
        reject({http_code: req.status})
      }
    }
    req.onerror = (err)=>{
      reject({http_code: req.status})
    }
    req.send(data && JSON.stringify(data))
  })
})()

var remoteProps = {
  accounts: (props) => {
    return {
      url: "/all",
      prop: "account"
    }
  }
}

function addRemoteProps(props){
  return new Promise((resolve, reject)=>{
    //Here we could call `[].concat.apply` instead of `Array.prototype.concat.apply`
    //apply first parameter define the `this` of the concat function called
    //Ex [0,1,2].concat([3,4],[5,6])-> [0,1,2,3,4,5,6]
    // <=> Array.prototype.concat.apply([0,1,2],[[3,4],[5,6]])
    //Also `var list = [1,2,3]` <=> `var list = new Array(1,2,3)`
    var remoteProps = Array.prototype.concat.apply([],
      props.handlerPath
      .map((c)=> c.remoteProps) // -> [[remoteProps.user], [remoteProps.orders], null]
      .filter((p)=> p) // -> [[remoteProps.user], [remoteProps.orders]]
    )
    var remoteProps = remoteProps
    .map((spec_fun)=> spec_fun(props) ) // -> 1st call [{url: '/api/me', prop: 'user'}, undefined]
    // -> 2nd call [{url: '/api/me', prop: 'user'}, {url: '/api/orders?user_id=123', prop: 'orders'}]
    .filter((specs)=> specs) // get rid of undefined from remoteProps that don't match their dependencies
    .filter((specs)=> !props[specs.prop] ||  props[specs.prop].url != specs.url) // get rid of remoteProps already resolved with the url
    if(remoteProps.length == 0)
    return resolve(props)
    // check out https://github.com/cujojs/when/blob/master/docs/api.md#whenmap and https://github.com/cujojs/when/blob/master/docs/api.md#whenreduce
    // all remoteProps can be queried in parallel
    const promise_mapper = (spec) => {
      // we want to keep the url in the value resolved by the promise here. spec = {url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}
      return HTTP.get(spec.url).then((res) => { spec.value = res; return spec })
    }
    const reducer = (acc, spec) => {
      // spec = url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}
      acc[spec.prop] = {url: spec.url, value: spec.value}
      return acc
    }
    const promise_array = remoteProps.map(promise_mapper)
    return Promise.all(promise_array)
    .then(xs => xs.reduce(reducer, props), reject)
    .then((p) => {
      // recursively call remote props, because props computed from
      // previous queries can give the missing data/props necessary
      // to define another query
      return addRemoteProps(p).then(resolve, reject)
    }, reject)
  })
}

var cn = function(){
  var args = arguments, classes = {}
  for (var i in args) {
    var arg = args[i]
    if(!arg) continue
    if ('string' === typeof arg || 'number' === typeof arg) {
      arg.split(" ").filter((c)=> c!="").map((c)=>{
        classes[c] = true
      })
    } else if ('object' === typeof arg) {
      for (var key in arg) classes[key] = arg[key]
    }
  }
  return Object.keys(classes).map((k)=> classes[k] && k || '').join(' ')
}

var ErrorPage = createReactClass({
  render(){
    return <h1>{this.props.code} / {this.props.message}</h1>;
  }
})


// var click = document.getElementById('withdraw');
// click.onclick = () => {
//   console.log("click")
// }

function add(account)
{
  var amount = prompt("How much would you like to deposit ?");
  HTTP.get("/add/?account="+account+"&amount=" + amount).then(res => {
    window.location.reload();
  })
}

function rem(account)
{
  var amount = prompt("How much would you like to withdraw ?");
  HTTP.get("/rem/?account="+account+"&amount=" + amount).then(res => {
    window.location.reload();
  })
}
function firstname(account)
{
  var value = prompt("Choose your new firstname");
  HTTP.get("/edit/?account="+account+"&key=firstname&value=" + value).then(res => {
    window.location.reload();
  })
}

function lastname(account)
{
  var value = prompt("Choose your new lastname");
  HTTP.get("/edit/?account="+account+"&key=lastname&value=" + value).then(res => {
    window.location.reload();
  })
}

function delete_account(account)
{
  HTTP.get("/delete/?account=" + account).then(res => {
    window.location.reload();
  })
}

var Account = createReactClass({
  statics: {
    remoteProps: [remoteProps.accounts]
  },
  render(){
    console.log(this.props)
    var new_orders = this.props.account.value
    var i = 0
    new_orders.map( order =>
      console.log(order)
    )
    return <JSXZ in="page" sel=".layout">
    <Z sel=".table-body">
    {
      new_orders.map( order => (<JSXZ in="page" key={i++} sel=".table-line">
      <Z sel=".col-1">{order.account}</Z>
      <Z sel=".col-2"><button id="add" onClick={(e) => lastname(order.account)}> = </button> {order.lastname} {order.firstname} <button id="add" onClick={(e) => firstname(order.account)}> = </button></Z>
      <Z sel=".col-3"><button id="add" onClick={(e) => add(order.account)}> + </button> {order.amount} <button id="add" onClick={(e) => rem(order.account)}> - </button></Z>
      <Z sel=".col-4">{order.update}</Z>
      <Z sel=".col-6" onClick={(e) => delete_account(order.account)}></Z>
      </JSXZ>))
    }
    </Z>
    </JSXZ>
  }
})

var Child = createReactClass({
  render(){
    var [ChildHandler,...rest] = this.props.handlerPath
    return <ChildHandler {...this.props} handlerPath={rest} />
  }
})

var browserState = {Child: Child}

var routes = {
  "accounts": {
    path: (params) => {
      return "/";
    },
    match: (path, qs) => {
      return (path == "/") && {handlerPath: [Account]}
    }
  }
}

var GoTo = (route, params, query) => {
  var qs = Qs.stringify(query)
  var url = routes[route].path(params) + ((qs=='') ? '' : ('?'+qs))
  history.pushState({}, "", url)
  onPathChange()
}

function onPathChange() {
  var path = location.pathname
  var qs = Qs.parse(location.search.slice(1))
  var cookies = Cookie.parse(document.cookie)
  browserState = {
    ...browserState,
    path: path,
    qs: qs,
    cookie: cookies
  }
  var route, routeProps
  //We try to match the requested path to one our our routes
  for(var key in routes) {
    routeProps = routes[key].match(path, qs)
    if(routeProps){
      route = key
      break;
    }
  }
  browserState = {
    ...browserState,
    ...routeProps,
    route: route
  }
  addRemoteProps(browserState).then(
    (props) => {
      browserState = props
      ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))
    }, (res) => {
      ReactDOM.render(<ErrorPage message={"Shit happened"} code={404}/>, document.getElementById('root'))
    })
  }

  window.addEventListener("popstate", ()=>{ onPathChange() })
  onPathChange()

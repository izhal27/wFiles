( function _FileProviderAbstract_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileCommon.s' );

}

//

var _ = wTools;
var Parent = null;
var Self = function wFileProviderAbstract( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

var init = function( o )
{
  var self = this;

  _.protoComplementInstance( self );

  if( o )
  self.copy( o );

  console.log( 'new',_.strTypeOf( self ) )
  //debugger;

}

//

var filesRead = function( o )
{

  logger.log( 'filesRead : ' + _.strTypeOf( this ) );

  // options

  var self = this;

  if( _.arrayIs( o ) )
  o = { paths : o };

  _.assert( arguments.length === 1 );
  _.routineOptions( filesRead,o );

  if( _.objectIs( o.paths ) )
  {
    var _paths = [];
    for( var p in o.paths )
    _paths.push({ pathFile : o.paths[ p ], name : p });
    o.paths = _paths;
  }

  o.paths = _.arrayAs( o.paths );

  var con = new wConsequence();
  var result = [];
  var errs = [];

  if( o.sync )
  throw _.err( 'not implemented' );

/*
  _.assert( !o.onBegin,'not implemented' );
  _.assert( !o.onEnd,'not implemented' );
*/

  _.assert( !o.onProgress,'not implemented' );

  var onBegin = o.onBegin;
  var onEnd = o.onEnd;
  var onProgress = o.onProgress;

  delete o.onBegin;
  delete o.onEnd;
  delete o.onProgress;

  // begin

  if( onBegin )
  wConsequence.give( onBegin,{ options : o } );

  // exec

  for( var p = 0 ; p < o.paths.length ; p++ ) ( function( p )
  {

    con.got();

    var pathFile = o.paths[ p ];
    var readOptions = _.mapScreen( self.fileRead.defaults,o );
    readOptions.onEnd = o.onEach;
    if( _.objectIs( pathFile ) )
    _.mapExtend( readOptions,pathFile );
    else
    readOptions.pathFile = pathFile;

    wConsequence.make( self.fileRead( readOptions ) ).got( function filesReadFileEnd( err,read )
    {

      if( err || read === undefined )
      {
        errs[ p ] = _.err( 'cant read : ' + _.toStr( pathFile ) + '\n', ( err || 'unknown reason' ) );
      }
      else
      {
        result[ p ] = read;
      }

      con.give();

    });

  })( p );

  // end

  con.give().got( function filesReadEnd()
  {

    var err;
    // if( errs.length )
    // debugger;

    if( errs.length )
    err = _.errLog( _.arrayLeft( errs ).element );

    if( o.map === 'name' )
    {
      var _result = {};
      for( var p = 0 ; p < o.paths.length ; p++ )
      _result[ o.paths[ p ].name ] = result[ p ];
      result = _result;
    }
    else if( o.map )
    throw _.err( 'unknown map : ' + o.map );

    var r = { options : o, data : result, errs : errs };

    if( onEnd )
    wConsequence.give( onEnd,err,r );
    con.give( err,r );
  });

  //

  return con;
}

filesRead.defaults =
{

  paths : null,
  onEach : null,

  map : '',
  all : 0,

}

if( _.fileRead )
filesRead.defaults.__proto__ = _.fileRead.defaults;
else
filesRead.defaults.__proto__ =
{

  sync : 1,
  wrap : 0,
  returnRead : 0,
  silent : 0,

  pathFile : null,
  name : null,
  encoding : 'utf8',

  onBegin : null,
  onEnd : null,
  onError : null,

  advanced : null,

}

filesRead.isOriginalReader = 0;

// --
// relationship
// --

var Composes =
{
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
}

// --
// prototype
// --

var Proto =
{

  init : init,

  filesRead : filesRead,

  // ident

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

wCopyable.mixin( Self );

//

_.FileProvider = _.FileProvider || {};
_.FileProvider.Abstract = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();

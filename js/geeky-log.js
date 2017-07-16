/*  -------------------------------------
|   seolog.js
|   -------------------------------------
|   June 2017 - Victor VILA
|
|   Utilities for creating charts & tablesè
|   Based on d3js and Mike Bostock code
|
*/

    const reNL = /\n/;

	// the get 'd' parameter (the only parameter) should indicate the directory data
	 
	const directory = document.location.href.split('=')[1] || "";  
	
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  Nav
	 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  creates the menu & appends get param
	 */	 
        
	var menu = '<li><a href="home.html?d=' + directory + '">Home</a></li>';
	menu    += '<li><a href="actives.html?d=' + directory + '">Activity</a></li>';
	menu    += '<li><a href="bots.html?d=' + directory + '">Bots</a></li>';
	menu    += '<li><a href="broken.html?d=' + directory + '">Broken links</a></li>'; 
	menu    += '<li><a href="status.html?d=' + directory + '">Status</a></li>';
	document.getElementById('nav-mobile').innerHTML = menu;
	
	//document.getElementById('footer').innerText = 'This page was generated with Linux commands for the data miningpart & d3js + materializecss for presentation. 100% Wordpress free.'; 
	
	
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  creaPie
	 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  generates a pie chart
	 *  @param htmlEl : element where chart will be injected
	 *  @param dataFile : relative path to data file (csv)
	 *  Inspiration : https://bl.ocks.org/mbostock/3887235
	 *  Inspiration : http://jsbin.com/isuris/1/edit?html,css,js,output
	 */
	
	
	const createPie = function ( htmlEl, dataFile, createRawButton )
	{  
        
        var svg = d3.select     ( "#" + htmlEl + " svg"),
            width = +svg.attr   ( "width" ),
            height = +svg.attr  ( "height" ),
            radius = Math.min   ( width, height ) / 2,
            g = svg .append("g")
                    .attr("transform", 
                          "translate(" + width / 3 + "," + height / 2 + ")");

        /*var color = d3.scaleOrdinal(
        ["#98abc5", "#8a89a6", "#7b6888", 
        "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);*/
        var color = d3.scaleOrdinal(
        ["#82b1ff","#2196f3", "#dce775", 
        "#ffcc80", "#fff59d", "#ffab91", "#f44336"]);

        var pie = d3.pie()
            .sort(null)
            .value(function(d) { return d.value; });

        var path = d3.arc()
            .outerRadius(radius - 10)
            .innerRadius(0);

        var label = d3.arc()
            .outerRadius(radius - 40)
            .innerRadius(radius - 40);

        d3.tsv( 'logs/' + directory + "/" + dataFile, 
            function(d) 
            { 
              d.value = +d.value;
              return d;
            }, 
            function(error, data) 
            {
              if (error) throw error;
              
              // pie
              var arc = g.selectAll(".arc")
                .data(pie(data))
                .enter().append("g")
                  .attr("class", "arc");

              arc.append("path")
                  .attr("d", path)
                  .attr("fill", function(d) { return color(d.data.key); });
              
              // labels
              /*
              arc.append("text")
                  .attr("transform", 
                  function(d) { return "translate(" + label.centroid(d) + ")"; })
                  .attr("dy", "0.35em")
                  .text(function(d) { return d.data.key; });*/

	         // add legend   
	         var legend = svg.append("g")
	            .attr("class", "legend") 
	            .attr("height", 100)
	            .attr("width", 150)
                .attr('transform', 'translate(-50,50)')   
            
            legend.selectAll('rect')
               .data(data)
               .enter()
               .append("rect")
	           .attr("x", width - 65)
               .attr("y", function(d, i){ return i *  20;})
	           .attr("width", 10)
	           .attr("height", 10)
	           .style("fill", function(d) { return color(d.key); })
              
            legend.selectAll('text')
              .data(data)
              .enter()
              .append("text")
	          .attr("x", width - 52)
              .attr("y", function(d, i){ return i *  20 + 9;})
	          .text(function(d) {
                return d.key + ': ' + d.value; 
              });                          
        });
        
           
        // create the data link
        if ( createRawButton )
        { 
            var a      = document.createElement('a'); 
            var p      = document.createElement('p');
            a.textContent = 'raw data'; 
            a.href = 'logs/' + directory + "/" + dataFile;
            a.setAttribute('class', 'rawData waves-effect waves-teal btn');
            p.appendChild( a )
            document.getElementById( htmlEl ).appendChild( p );
        }
	};
	
		
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  creaPieData
	 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  generates a pie chart from param data
	 *  @param htmlEl : element where chart will be injected
	 *  @param dataParam : JSON data as String
	 */
	
	
	const createPieData = function ( htmlEl, dataParam )
	{  
	    // loaded as string, convert to JSON
        var data = JSON.parse(dataParam);
        
        var svg = d3.select     ( "#" + htmlEl + " svg"),
            width = +svg.attr   ( "width" ),
            height = +svg.attr  ( "height" ),
            radius = Math.min   ( width, height ) / 2,
            g = svg .append("g")
                    .attr("transform", 
                          "translate(" + width / 3 + "," + height / 2 + ")");
 
        var color = d3.scaleOrdinal(
        ["#82b1ff"/*,"#2196f3", "#dce775", 
        "#ffcc80", "#fff59d"*/, "#ffab91", "#f44336"]);

        var pie = d3.pie()
            .sort(null)
            .value(function(d) { return d.value; });

        var path = d3.arc()
            .outerRadius(radius - 10)
            .innerRadius(0);

        var label = d3.arc()
            .outerRadius(radius - 40)
            .innerRadius(radius - 40);

        // pie
        var arc = g.selectAll(".arc")
            .data(pie(data))
            .enter().append("g")
            .attr("class", "arc");

        arc.append("path")
            .attr("d", path)
            .attr("fill", function(d) {return color(d.index); });
        
	    // add legend   
	    var legend = svg.append("g")
	        .attr("class", "legend") 
	        .attr("height", 100)
	        .attr("width", 150)
            .attr('transform', 'translate(-50,50)')   
           
        legend.selectAll('rect')
            .data(data)
            .enter()
            .append("rect")
	        .attr("x", width - 65)
            .attr("y", function(d, i){ return i *  20;})
	        .attr("width", 10)
	        .attr("height", 10)
	        .style("fill", function(d) { return d.color; })
              
        legend.selectAll('text')
            .data(data)
            .enter()
            .append("text")
	        .attr("x", width - 52)
            .attr("y", function(d, i){ return i *  20 + 9;})
	        .text(function(d) {return d.key + ':' + d.value});             
	};
	
	
 
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  createTable
	 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  generates an html table
	 *  @param htmlEl : element where the table will be injected
	 *  @param dataFile : relative path to data file (csv) 
	 *  @param label : text to show in the values column 
	 *  @param limit : number of items to show 
	 */
	
	
	const createTable = function ( id, dataFile, label, limit )
	{ 	
	    console.log('create table ' + directory + "/" + dataFile)
	    let xhr = new XMLHttpRequest();
	    xhr.overrideMimeType( "application/json" );
	    xhr.open( 'GET', 'logs/' + directory + "/" + dataFile, true );
	    xhr.onreadystatechange = () =>
	    {
	        if ( xhr.readyState === 4 && xhr.status === 200 )
	        { 
                // create the data link
                var t = '<p><a class="rawData waves-effect waves-teal btn"'
                t    += 'href="' + 'logs/' + directory + "/" + dataFile + '">raw data</a></p>'; 
                
	            let data = xhr.responseText;  
	            //console.log(data)	            
	            var keys = [], values = [], total = 0;
	            var lines = data.split( reNL );
		
                for ( let i = 0 ; i < lines.length ; i++ )
                { 
                    try 
                    {
                        var line = lines[ i ].split(',');
                        // calculate total. Even in case of limit or blank url
                        total += parseInt( line[1].trim() ) | 0; 
                        if ( line[0] == null || line[0] == '' ) continue;
                        if ( i > limit ) continue;
                        keys.push( line[1].trim() )
                        values.push( line[0] )
                    }
                    catch (e) { console.log(e) }
                }
                
                t += "<table width='90%'><thead>";
                t += '<tr><th>Hits</th><th>%</th><th>';
                t += label + '</th></tr></thead>';
                t += '<tfoot><tr><td>' + total 
                t += '</td><td>100%</td><td>All</td></tr></tfoot>';
                
                for ( let i = 0 ; i < keys.length ; i++)
                {
                    var percentage = (( keys[i] * 100 ) / total ).toFixed(1);
                    //if ( percentage < 1 ) continue;
                    t += '<tr><td>' + keys[i] + '</td>';
                    t += '<td>' + percentage + '%</td>';
                    t += '<td>' + values[i] + '</td></tr>';
                }        
                t += '</table>'; 
                document.getElementById( id ).innerHTML = t;
	            
//            	console.log('table: ' + id  + ', rows: ' + keys.length) 
            } // data ok
        } // xhr
        xhr.send( null );
	};
	
	
 
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  createTableTSV
	 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  generates an html table
	 *  @param htmlEl : element where the table will be injected
	 *  @param dataFile : relative path to data file (csv) 
	 *  @param label : text to show in the values column 
	 *  @param limit : number of items to show 
	 */
	
	
	const createTableTSV = function ( id, dataFile, label, limit )
	{ 	
	    console.log('create table ' + directory + "/" + dataFile)
	    let xhr = new XMLHttpRequest();
	    xhr.overrideMimeType( "application/json" );
	    xhr.open( 'GET', 'logs/' + directory + "/" + dataFile, true );
	    xhr.onreadystatechange = () =>
	    {
	        if ( xhr.readyState === 4 && xhr.status === 200 )
	        { 
                // create the data link
                var t = '<p><a class="rawData waves-effect waves-teal btn"'
                t    += 'href="' + 'logs/' + directory + "/" + dataFile + '">raw data</a></p>'; 
                
	            let data = xhr.responseText;  
	            //console.log(data)	            
	            var keys = [], values = [], total = 0;
	            var lines = data.split( reNL );
		
                for ( let i = 0 ; i < lines.length ; i++ )
                { 
                    try 
                    {
                        var line = lines[ i ].split('\t');
                        if (line[1] == undefined) continue;
                        // calculate total. Even in case of limit or blank url
                        total += parseInt( line[1].trim() ) | 0; 
                        if ( line[0] == null || line[0] == '' ) continue;
                        if ( i > limit ) continue;
                        keys.push( line[1].trim() )
                        values.push( line[0] )
                    }
                    catch (e) { console.log(e) }
                }
                
                t += "<table width='90%'><thead>";
                t += '<tr><th>Hits</th><th>%</th><th>';
                t += label + '</th></tr></thead>';
                t += '<tfoot><tr><td>' + total 
                t += '</td><td>100%</td><td>All</td></tr></tfoot>';
                
                for ( let i = 0 ; i < keys.length ; i++)
                {
                    var percentage = (( keys[i] * 100 ) / total ).toFixed(1);
                    //if ( percentage < 1 ) continue;
                    t += '<tr><td>' + keys[i] + '</td>';
                    t += '<td>' + percentage + '%</td>';
                    t += '<td>' + values[i] + '</td></tr>';
                }        
                t += '</table>'; 
                document.getElementById( id ).innerHTML = t;
	            
//            	console.log('table: ' + id  + ', rows: ' + keys.length) 
            } // data ok
        } // xhr
        xhr.send( null );
	};
	
	
	
 
	
	
 
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  createTableList
	 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  generates an html table
	 *  @param htmlEl : element where the table will be injected
	 *  @param dataFile : relative path to data file (csv) 
	 *  @param label : text to show in the values column 
	 *  @param limit : number of items to show 
	 */
	
	
	const createTableList = function ( id, dataFile, label, limit )
	{ 	
	    console.log('create table ' + directory + "/" + dataFile)
	    let xhr = new XMLHttpRequest();
	    xhr.overrideMimeType( "application/json" );
	    xhr.open( 'GET', 'logs/' + directory + "/" + dataFile, true );
	    xhr.onreadystatechange = () =>
	    {
	        if ( xhr.readyState === 4 && xhr.status === 200 )
	        { 
                // create the data link
                var t = '<p><a class="rawData waves-effect waves-teal btn"'
                t    += 'href="' + 'logs/' + directory + "/" + dataFile + '">raw data</a></p>'; 
                
	            let data = xhr.responseText;   
                
                t += "<table width='90%'>";
                t += '<thead><tr><th>' + label + 'Hits</th></tr></thead>'; 
                
	            var lines = data.split( reNL );
		
                for ( let i = 0 ; i < lines.length ; i++ )
                { 
                    if (i > limit) continue;
                    if (lines[i] == '') continue;
                    t += '<tr><td>' + lines[i] + '</td></tr>';
                }        
                t += '</table>'; 
                document.getElementById( id ).innerHTML = t; 
            } // data ok
        } // xhr
        xhr.send( null );
	};
	
	
	
 
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  createTable2
	 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  generates an html table 
	 *  @param htmlEl : element where the table will be injected
	 *  @param dataFile : relative path to data file (csv) 
	 *  @param label : text to show in the values column 
	 *  @param limit : number of items to show 
	 */
	
	
	const createTable2 = function ( id, dataFile, label1, label2, limit )
	{ 	
	    console.log('create table ' + directory + "/" + dataFile)
	    let xhr = new XMLHttpRequest();
	    xhr.overrideMimeType( "application/json" );
	    xhr.open( 'GET', 'logs/' + directory + "/" + dataFile, true );
	    xhr.onreadystatechange = () =>
	    {
	        if ( xhr.readyState === 4 && xhr.status === 200 )
	        {  
                // create the data link
                var t = '<p><a class="rawData waves-effect waves-teal btn"'
                t    += 'href="' + 'logs/' + directory + "/" + dataFile + '">raw data</a></p>'; 
                
	            let data = xhr.responseText;  
	            //console.log(data)	            
	            var keys = [], values = [], values2 = [], total = 0;
	            var lines = data.split( reNL );
		
                for ( let i = 0 ; i < lines.length ; i++ )
                { 
                    try 
                    {
                        var line = lines[ i ].split('\t');
                        // calculate total even in case of limit or blank url
                        var stotal = parseInt( line[0].trim() ); 
                        if ( Number.isInteger(stotal) ) total += stotal; 
                        if ( line[1] == null || line[1] == '' ) continue;
                        if ( i > limit ) continue;
                        keys.push( line[0].trim() )
                        values.push( line[1] )
                        values2.push( line[2] )
                    }
                    catch (e) { console.log(e) }
                }
                
                t += "<table width='90%'><thead>";
                t += '<tr><th>Hits</th><th>%</th>';
                t += '<th>' + label1 + '</th><th>' + label2 + '</th></tr></thead>';
                t += '<tfoot><tr><td>' + total 
                t += '</td><td>100%</td><td>All</td></tr></tfoot>';
                
                // start at row 1 to zapp headers
                for ( let i = 1 ; i < keys.length ; i++)
                {
                    var percentage = (( keys[i] * 100 ) / total ).toFixed(1);
                    console.log(keys[i] + " *100 " + total)
                    //if ( percentage < 1 ) continue;
                    t += '<tr><td>' + keys[i] + '</td>';
                    t += '<td>' + percentage + '%</td>';
                    t += '<td>' + values[i] + '</td>';
                    t += '<td>' + values2[i] + '</td></tr>';
                }        
                t += '</table>'; 
                document.getElementById( id ).innerHTML = t;
	            
            	//console.log('table: ' + id  + ', rows: ' + keys.length)
            } // data ok
        } // xhr
        xhr.send( null );
	};
	
	
	
 
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  createLine
	 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  generates an html table 
	 *  @param htmlEl : element where the table will be injected
	 *  @param dataFile : relative path to data file (csv) 
	 *  @param label : text to show in the values column 
	 *  @param limit : number of items to show 
	 */
	
	
	const createLine = function ( id, dataFile, label1, label2, limit )
	{  
        //line( "broken-links", "broken-links.csv", "From", "To", 50 );
        var svg = d3.select("#" + id),
        margin  = {top: 20, right: 20, bottom: 30, left: 50},
        width   = +svg.attr("width") - margin.left - margin.right,
        height  = +svg.attr("height") - margin.top - margin.bottom,
        g       = svg.append("g")
                    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        var parseTime = d3.timeParse("%d/%b/%Y");
        //var parseTime = d3.timeParse("%d-%b");

        var x = d3.scaleTime().rangeRound([0, width]);

        var y = d3.scaleLinear().rangeRound([height, 0]);

        var line = d3.line()
            .x(function(d) { return x(d.date); })
            .y(function(d) { return y(d.hits); });

    //    d3.csv("data.csv", function(d) 
        d3.csv('logs/' + directory+"/"+dataFile, function(d) 
        {
          d.date = parseTime(d.date);
          d.hits   = +d.hits;
          return d;
        }, 
        function(error, data) 
        {
          if (error) throw error;
          console.log(data)

          x.domain(d3.extent(data, function(d) { return d.date; }));
          y.domain(d3.extent(data, function(d) { return d.hits; }));

          g.append("g")
              .attr("transform", "translate(0," + height + ")")
              .call(d3.axisBottom(x))
            .select(".domain")
              .remove();

          g.append("g")
              .call(d3.axisLeft(y))
            .append("text")
              .attr("fill", "#000")
              .attr("transform", "rotate(-90)")
              .attr("y", 6)
              .attr("dy", "0.71em")
              .attr("text-anchor", "end")
              .text("Hits");

          g.append("path")
              .datum(data)
              .attr("fill", "none")
              .attr("stroke", "steelblue")
              .attr("stroke-linejoin", "round")
              .attr("stroke-linecap", "round")
              .attr("stroke-width", 1.5)
              .attr("d", line);
        });
	};
	
	
		
	
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  createStack
	 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  generates a stacked bar chart
	 *  @param htmlEl : element where chart will be injected
	 *  @param dataFile : relative path to data file (csv)
	 *  Source : https://bl.ocks.org/mbostock/3886208
	 */
	
	const createStack = function ( htmlEl, dataFile )
	{
	    
        var svg = d3.select( "#" + htmlEl ),
            margin = {top: 60, right: 20, bottom: 30, left: 40},
            width = +svg.attr("width") - margin.left - margin.right,
            height = +svg.attr("height") - margin.top - margin.bottom,
            g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        var x = d3.scaleBand()
            .rangeRound([0, width])
            .paddingInner(0.05)
            .align(0.1);

        var y = d3.scaleLinear()
            .rangeRound([height, 0]);

        var z = d3.scaleOrdinal()
            .range([/*"#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56",*/
            "#82b1ff","#2196f3","#fdd835", "#ff8c00", "#f44336" ]);

        d3.tsv( 'logs/' + directory + "/" + dataFile, function(d, i, columns) 
        {
          for (i = 1, t = 0; i < columns.length; ++i)
          {
            t += d[columns[i]] = +d[columns[i]];
          }
          
          d.total = t;
          return d;
          
        }, 
        function(error, data) 
        {
          if (error) throw error;

          var keys = data.columns.slice(1);

          //data.sort(function(a, b) { return b.total - a.total; });
          x.domain(data.map(function(d) { return d.date; }));
          y.domain([0, d3.max(data, function(d) { return d.total; })]).nice();
          z.domain(keys);

          g.append("g")
            .selectAll("g")
            .data(d3.stack().keys(keys)(data))
            .enter().append("g")
              .attr("fill", function(d) { return z(d.key); })
            .selectAll("rect")
            .data(function(d) { return d; })
            .enter().append("rect")
              .attr("x", function(d) { return x(d.data.date); })
              .attr("y", function(d) { return y(d[1]); })
              .attr("height", function(d) { return y(d[0]) - y(d[1]); })
              .attr("width", x.bandwidth());

          g.append("g")
              .attr("class", "axis")
              .attr("transform", "translate(0," + height + ")") 
              .call(d3.axisBottom(x));

          // Hits
          g.append("g")
              .attr("class", "axis")
              .call(d3.axisLeft(y).ticks(null, "s"))
            .append("text")
              .attr("x", -25)
              .attr("y", y(y.ticks().pop()) + 0.5)
              .attr("dy", "-20")
              .attr("fill", "#000")
              //.attr("font-weight", "bold")
              .attr("text-anchor", "start")
              .text("Hits");

          // Legend
          var legend = g.append("g")
              .attr("font-family", "sans-serif")
              .attr("font-size", 10)
              .attr("text-anchor", "end")
            .selectAll("g")
            .data(keys.slice().reverse())
            .enter().append("g")
              .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

          legend.append("rect")
              .attr("x", width - 19)
              .attr("width", 19)
              .attr("height", 19)
              .attr("fill", z);

          legend.append("text")
              .attr("x", width - 24)
              .attr("y", 9.5)
              .attr("dy", "0.32em")
              .text(function(d) { return d; });
        });

	};
	
	
	
		
	
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  createDataLink
	 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 *  generates a dynamic link
	 *  @param htmlEl : element where link will be injected
	 *  @param dataFile : relative path to data file (csv) 
	 */
		

	const createDataLink = function ( htmlEl, dataFile )
	{            
        var a      = document.createElement('a'); 
        var p      = document.createElement('p');
        a.textContent = 'raw data'; 
        a.href = 'logs/' + directory + "/" + dataFile;
        a.setAttribute('class', 'rawData waves-effect waves-teal btn');
        p.appendChild( a )
        document.getElementById( htmlEl ).appendChild( p );
    };
	

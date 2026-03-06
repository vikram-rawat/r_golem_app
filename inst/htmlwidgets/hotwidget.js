HTMLWidgets.widget({
  name: 'hotwidget',
  type: 'output',

  factory: function (el, width, height) {
    let container;

    return {
      renderValue: function (x) {
        // Create container div
        container = document.createElement('div');
        container.id = 'handsontable-' + Math.floor(Math.random() * 1000000);
        el.appendChild(container);

        // Convert R data frame (column-oriented) to 2D array (row-oriented)
        let tableData = [];
        if (x.data && typeof x.data === 'object') {
          const columns = Object.keys(x.data);
          const numRows = columns.length > 0 ? x.data[columns[0]].length : 0;

          for (let i = 0; i < numRows; i++) {
            let row = [];
            for (let col of columns) {
              row.push(x.data[col][i]);
            }
            tableData.push(row);
          }
        }

        // Initialize Handsontable
        const hot = new Handsontable(container, {
          data: tableData,
          rowHeaders: true,
          colHeaders: x.colHeaders || true,
          height: 'auto',
          licenseKey: 'non-commercial-and-evaluation',
          // Add more options as needed
          contextMenu: true,
          manualRowResize: true,
          manualColumnResize: true,
        });

        // Store reference for later access
        el.hot = hot;
      },

      resize: function (width, height) {
        if (el.hot) {
          el.hot.render();
        }
      },
    };
  },
});

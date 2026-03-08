HTMLWidgets.widget({
  name: 'hotwidget',
  type: 'output',

  factory: function (el, width, height) {
    let container;
    let colHeaders;

    return {
      renderValue: function (x) {
        // Clear previous content
        el.innerHTML = '';

        // Create container div
        container = document.createElement('div');
        container.id = 'handsontable-' + Math.floor(Math.random() * 1000000);
        el.appendChild(container);

        // Store column headers for later use
        colHeaders = x.colHeaders || [];

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
          rowHeaders: false,
          colHeaders: colHeaders || true,
          colWidths: function (col) {
            // Make first column (cars) wider, others default
            return col === 0 ? 250 : undefined;
          },
          height: 'auto',
          licenseKey: 'non-commercial-and-evaluation',
          contextMenu: true,
          manualRowResize: true,
          manualColumnResize: true,
          afterChange: function (changes, source) {
            if (source === 'loadData') {
              return; // Don't send event when loading data
            }

            // Send only the change details (row, col, value) back to Shiny
            if (typeof Shiny !== 'undefined' && changes) {
              changes.forEach(function (change) {
                const row = change[0] + 1; // Convert to 1-based index for R
                const col = colHeaders[change[1]]; // Get column name
                const value = change[3]; // newValue

                setTimeout(function () {
                  Shiny.setInputValue(
                    el.id + '_cell_change',
                    {
                      row: row,
                      col: col,
                      value: value,
                      timestamp: Date.now(),
                    },
                    { priority: 'event' },
                  );
                }, 100);
              });
            }
          },
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

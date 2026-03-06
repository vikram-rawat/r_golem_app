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

        // Initialize Handsontable
        const hot = new Handsontable(container, {
          data: x.data,
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

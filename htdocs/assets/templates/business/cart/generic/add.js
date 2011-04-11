// add.js.

function prepare_add_form()
{
	YUI().use
	(
		"datasource-get", "datatable", "gallery-formmgr", "io-base", "io-form", "json", "node", function(Y)
		{
			var f = new Y.FormManager("add_form",
			  {
			  });

			f.prepareForm();

			var div = Y.one("#add_result_div");
			var success_fn = function(ioId, o)
			{
				if (o.responseText !== undefined)
				{
					div.set("innerHTML", "");

					Y.JSON.useNativeParse = false;
					var data = Y.JSON.parse(o.responseText);
					var cols =
						[
							{key: "id",   label: "Id"},
							{key: "name", label: "Name"}
						];
					var table = new Y.DataTable.Base
					({
						columnset: cols,
						recordset: data.results
					}).render("#add_result_div");
				}
				else
				{
					div.set("innerHTML", "The server's response is incomprehensible");
				}
			};
			var failure_fn = function(ioId, o)
			{
				div.set("innerHTML", "The server failed to respond");
			};

			Y.one("#reset_add").on("click", function()
			{
				f.populateForm();
			});

			Y.one("#submit_add").on('click', function(e)
			{
				if (FIC_checkForm("add_form") == false)
				{
					return false;
				}

				var cfg =
					{
						form:
						{
							id: "add_form"
						},
						method: "POST",
						on:
						{
							success: success_fn,
							failure: failure_fn
						},
						sync: true
					};

				var request = Y.io("/add", cfg);
			});
		}
	);
}

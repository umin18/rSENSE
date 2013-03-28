
$ ->
  # A File has been uploaded, decide what to do
  ($ "#csv_file_form").ajaxForm (resp) ->
    if resp["status"] == "success"
      window.location = resp['redirect']
    else
      ($ "#match_table").html ''
      ($ "#match_table").append "<tr><th> Experiment Field </th> <th> CSV Header </th></tr>"
      
      for field, fieldIndex in resp["fields"]

        options = "<option value='-1'> Select One... </option>"
        for header, headerIndex in resp['headers']
          if (resp.partialMatches[fieldIndex] isnt undefined) and (resp.partialMatches[fieldIndex].hindex is headerIndex)
            options += "<option selected='true' value='#{headerIndex}'> #{header} </option>"
          else
            options += "<option value='#{headerIndex}'> #{header} </option>"
      
        ($ "#match_table").append "<tr>
                                  <td> #{field} </td>
                                  <td><select>" + options + "</select></td>
                                  </tr>"

      ($ "button.cancel_upload_button").click ->
        ($ "#match_box").modal("hide")

      ($ "button.finished_button").click ->

        matchData =
          eid: resp.eid
          fields: resp.fields
          headers: resp.headers
          matches: []
          tmpFile: resp.tmpFile
      
        ($ "#match_table tr").each (idx, ele) ->
          if idx > 0
            matchVal = ($ ele).find("td select").val()
            headerIndex = Number matchVal
            fieldIndex = idx - 1

            if headerIndex is -1
              ($ "#match_table tr td select[value=-1]").errorFlash()
            
            matchData.matches[fieldIndex] =
              findex: fieldIndex
              hindex: headerIndex

        $.ajax
          type: "POST"
          dataType: "json"
          url: "/projects/#{resp['eid']}/uploadCSV"
          data: matchData
          success: (resp) ->
            window.location = resp['redirect']
          error: (resp) ->
            alert "Somthing went horribly wrong. I'm sorry."
      
      ($ "#match_box").modal
        backdrop: 'static'
        keyboard: true  
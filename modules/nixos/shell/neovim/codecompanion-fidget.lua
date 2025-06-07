 local code_companion_fidget = {}

    function code_companion_fidget.start_fidget()
        local has_fidget, fidget = pcall(require, "fidget")
        if not has_fidget then
            return
        end

        if code_companion_fidget.fidget_progress_handle then
            code_companion_fidget.fidget_progress_handle.message = "Abort."
            code_companion_fidget.fidget_progress_handle:cancel()
            code_companion_fidget.fidget_progress_handle = nil
        end

        code_companion_fidget.fidget_progress_handle = fidget.progress.handle.create({
            title = "",
            message = "Thinking...",
            lsp_client = { name = "CodeCompanion" },
        })
    end

    function code_companion_fidget.stop_fidget()
        local has_fidget, _ = pcall(require, "fidget")
        if not has_fidget then
            return
        end

        if code_companion_fidget.fidget_progress_handle then
            code_companion_fidget.fidget_progress_handle.message = "Done."
            code_companion_fidget.fidget_progress_handle:finish()
            code_companion_fidget.fidget_progress_handle = nil
        end
    end

    local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

    vim.api.nvim_create_autocmd({ "User" }, {
        pattern = { "CodeCompanionRequestStarted", "CodeCompanionRequestFinished" },
        group = group,
        callback = function(event)
            if event.match == "CodeCompanionRequestStarted" then
                code_companion_fidget.start_fidget()
            elseif event.match == "CodeCompanionRequestFinished" then
                code_companion_fidget.stop_fidget()
            end
        end,
    })

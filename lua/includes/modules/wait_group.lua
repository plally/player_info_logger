
function NewWaitGroup() 
    local waitGroup = {_i=0}

    waitGroup.add = function(n)
        n = n or 1
        waitGroup._i = waitGroup._i + n
    end

    waitGroup.done = function(n)
        waitGroup._i = waitGroup._i - 1
        if waitGroup._i <= 0 and waitGroup.callback then
            waitGroup.callback()
        end
    end

    waitGroup.whenDone = function(callback)
        waitGroup.callback = callback
        if waitGroup._i <= 0 then
            waitGroup.callback()
        end
    end
    
    return waitGroup
end
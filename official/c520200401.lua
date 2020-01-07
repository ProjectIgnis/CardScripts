--Master Rules 2020 Revision
--Scripted by edo9300 and kevinlul
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.op)
end
function s.op()
    aux.MR41=1
end
--無の畢竟 オールヴェイン
--Allvain the Essence of Vanity
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_NORMAL),2)
end
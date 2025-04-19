--Vanilla Mode
--Scripted by andré and shad3 and Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.op)
end
function s.op(c)
	--act limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetCondition(s.condition)
	e1:SetValue(s.aclimit)
	Duel.RegisterEffect(e1,0)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.disable)
	Duel.RegisterEffect(e2,0)
end
function s.condition()
	return Duel.GetFlagEffect(0,id)==0
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetFlagEffect(id)==0
end
function s.disable(e,c)
	return c:IsMonster() and c:GetFlagEffect(id)==0
end

--[[
	"vanilla mode" reference
	1:majesty's fiend
	2:skill drain
	3:vector pendulum
	4:concentration duel
	5:Red supremacy
	ability yell currennt id:
	id+1
	potential yell current id:
	511004399
--]]
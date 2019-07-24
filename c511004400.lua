--Vanilla Mode
--scripted by andré and shad3 and Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	--active
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCountLimit(1)
	e1:SetCondition(s.aco)
	e1:SetOperation(s.aop)
	c:RegisterEffect(e1)
end
function s.aco(e,tp,eg,ev,ep,re,r,rp)
	return Duel.GetTurnCount()==1
end
function s.aop(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	if not Duel.SelectYesNo(1-tp,aux.Stringid(4007,0)) or not Duel.SelectYesNo(tp,aux.Stringid(4007,0)) then
		local sg=Duel.GetMatchingGroup(Card.IsCode,tp,0x7f,0x7f,nil,id)
		Duel.SendtoDeck(sg,nil,-2,REASON_RULE)
		return
	end
	Duel.RegisterFlagEffect(0,id,0,0,0)
	local lol=LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_DECK
	Duel.DisableShuffleCheck()
	Duel.SendtoDeck(c,tp,-2,REASON_RULE)
	if c:GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp,1,REASON_RULE)
	end
	--act limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCondition(s.condition)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.aclimit)
	Duel.RegisterEffect(e1,tp)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCondition(s.condition)
	e2:SetTargetRange(lol,lol)
	e2:SetTarget(s.disable)
	e2:SetCode(EFFECT_DISABLE)
	Duel.RegisterEffect(e2,tp)
end
function s.condition()
   return Duel.GetFlagEffect(0,id+1)==0
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetFlagEffect(511004399)==0
end
function s.disable(e,c)
	return c:IsType(TYPE_MONSTER) and c:GetFlagEffect(511004399)==0
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

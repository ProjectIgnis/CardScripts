--Line Promotion
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--affect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(511005032)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.con)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	
	--reset flag when "Line World" leaves field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.sdcon)
	e3:SetOperation(s.sdop)
	c:RegisterEffect(e3)
end
s.listed_names={511005032}

function s.Worldfilter(c)
	return c:IsFaceup() and c:IsCode(511005032)
end
function s.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:GetOwner()==1-tp
end
function s.flagfilter(c)
	return c:GetFlagEffect(id)~=0
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	return c420.IsLineMonster(c) and c:IsControler(tp) and not s.flagfilter(c)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	eg:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
end

function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsCode,1,nil,511005032)
		and not Duel.IsExistingMatchingCard(Card.IsCode,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,511005032)
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.flagfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	g:ForEach(function (c) c:ResetFlagEffect(id) end)
end
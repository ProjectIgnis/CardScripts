--春化精の花冠
--Vernusylph Corolla
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--EARTH monsters become "Vernusylph" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH))
	e2:SetValue(SET_VERNUSYLPH)
	c:RegisterEffect(e2)
	--"Vernusylph" cost replacement
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_COST_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCountLimit(1)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_VERNUSYLPH}
function s.repval(base,extracon,e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return c:IsMonster() and c:IsSetCard(SET_VERNUSYLPH) and c:IsDiscardable()
end
function s.hintselectionfilter(c)
	return c:IsCode(id) and not c:HasFlagEffect(id)
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
	local c=base:GetHandler()
	if Duel.IsExistingMatchingCard(s.hintselectionfilter,tp,LOCATION_SZONE,0,1,c) then
		Duel.HintSelection(c)
	end
	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(id,1))
	Duel.SendtoGrave(e:GetHandler(),REASON_COST|REASON_DISCARD)
end

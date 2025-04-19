--白の悪夢
--White Nightmare
--Made by Beetron-1 Beetletop
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Your "White" monsters gain 500 ATK for each "White" monster sent to the Graveyard
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0x55d}
function s.costfilter(c)
	return c:IsWhite() and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,99,nil)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(#g)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsWhite),tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsWhite),tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	local atk=e:GetLabel()*500
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
end
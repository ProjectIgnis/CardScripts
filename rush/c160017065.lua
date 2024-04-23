--神疑の光来
--Auspicious Arrival of Divine Doubt
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Draw 2 cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsMonster() and c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if Duel.Draw(p,d,REASON_EFFECT)>0 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		local g=dg:RandomSelect(tp,1)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
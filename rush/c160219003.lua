--ＸＹＺ－ドラゴン・キャノン
--XYZ-Dragon Cannon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	local fusproc1=Fusion.AddProcMix(c,true,true,62651957,65622692,64500000)[1]
	fusproc1:SetDescription(aux.Stringid(id,0))
	local fusproc2=Fusion.AddProcMix(c,true,true,64500000,aux.FilterBoolFunctionEx(Card.IsHasEffect,160219005))[1]
	fusproc2:SetDescription(aux.Stringid(id,1))
	local fusproc3=Fusion.AddProcMix(c,true,true,65622692,aux.FilterBoolFunctionEx(Card.IsHasEffect,160219006))[1]
	fusproc3:SetDescription(aux.Stringid(id,2))
	local fusproc4=Fusion.AddProcMix(c,true,true,62651957,aux.FilterBoolFunctionEx(Card.IsHasEffect,160219007))[1]
	fusproc4:SetDescription(aux.Stringid(id,3))
	Fusion.AddUnionFusionProc(c)
	--Destroy 1 card your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,1,nil)
	local dg2=dg:AddMaximumCheck()
	Duel.HintSelection(dg2)
	Duel.Destroy(dg,REASON_EFFECT)
end
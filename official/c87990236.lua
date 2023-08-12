--魅惑の堕天使
--Darklord Enchantment
local s,id=GetID()
function s.initial_effect(c)
	--Take control of 1 monster your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DARKLORD}
function s.costfilter(c,tp)
	return c:IsSetCard(SET_DARKLORD) and c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.filter(c,ignzn)
	return c:IsControlerCanBeChanged(ignzn) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ignzn=e:GetLabel()==100
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,ignzn) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,false)
	local tc=g:GetFirst()
	if tc then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
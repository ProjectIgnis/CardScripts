--ジョインテック・ステゴサイロス
--Jointech Stegosilos
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Destroy up to 2 of opponent's defense position monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToGraveAsCost()
end
function s.desfilter(c)
	return c:IsFaceup() and c:HasDefense() and c:IsDefenseBelow(1600)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ctmax=Duel.GetMatchingGroupCount(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if ctmax>3 then ctmax=3 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,ctmax,nil)
	local ct=Duel.SendtoGrave(g,REASON_COST)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,ct,ct,nil)
		if #dg>0 then
			Duel.HintSelection(dg,true)
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

--竜騎士ブラック・マジシャン・ガール
--Dark Magician Girl the Dragon Knight
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_DARK_MAGICIAN_GIRL,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON))
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.material_setcode={SET_DARK_MAGICIAN,SET_MAGICIAN_GIRL}
s.listed_names={CARD_DARK_MAGICIAN_GIRL}
s.named_material={CARD_DARK_MAGICIAN_GIRL}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsNotMaximumModeSide),tp,0,LOCATION_ONFIELD,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(dg,REASON_COST)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsNotMaximumModeSide),tp,0,LOCATION_ONFIELD,1,1,nil)
	if #dg>0 then
		local dg2=dg:AddMaximumCheck()
		Duel.HintSelection(dg2)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
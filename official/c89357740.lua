--ユニオン・パイロット
--Union Pilot
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Union procedure
	aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT))
	--Equip 1 banished Union monster to an appropriate monster you control and Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsEquipCard() end)
	e1:SetCost(s.eqcost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
s.listed_card_types={TYPE_UNION}
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHandAsCost() end
	Duel.SendtoHand(c,nil,REASON_COST)
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
end
function s.equnionfilter(c,tp)
	return c:IsType(TYPE_UNION) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.eqtargetfilter,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.eqtargetfilter(c,ec)
	return ec:CheckUnionTarget(c) and aux.CheckUnionEquip(ec,c)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.equnionfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,tp)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,e:GetHandler():GetOriginalType(),2100,1000,5,RACE_MACHINE,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,s.equnionfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,tp):GetFirst()
	if not ec then return end
	Duel.HintSelection(ec)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.eqtargetfilter,tp,LOCATION_MZONE,0,1,1,nil,ec):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc)
	if Duel.Equip(tp,ec,tc) then
		aux.SetUnionState(ec)
		local c=e:GetHandler()
		if c:HasFlagEffect(id) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
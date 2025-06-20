--Japanese name
--Xyz Lay
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e0=aux.AddEquipProcedure(c)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	--The equipped monster gains 200 ATK for each Xyz Material attached to a monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(function(e) return 200*Duel.GetOverlayCount(0,1,1) end)
	c:RegisterEffect(e1)
	--Activate the following effect, based on the equipped monster's card type
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e) return e:GetHandler():GetEquipTarget() end)
	e2:SetCost(s.effcost)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_XYZ}
function s.thcfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsMonster() and c:IsDiscardable()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return not ec:IsType(TYPE_XYZ) or Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_COST) end
	if ec:IsType(TYPE_XYZ) then
		Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_COST)
	end
end
function s.setfilter(c)
	return c:IsSetCard(SET_XYZ) and c:IsSpellTrap() and c:IsSSetable()
end
function s.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	local b1=ec:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=not ec:IsType(TYPE_XYZ) and ec:HasLevel() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,ec:GetLevel())
	if chk==0 then return b1 or b2 end
	if b1 then
		e:SetLabel(1)
		e:SetCategory(0)
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
	elseif b2 then
		e:SetLabel(2)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Set 1 "Xyz" Spell/Trap from your Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	elseif op==2 then
		--Special Summon 1 monster with the same Level as the equipped monster from your hand in Defense Position
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local c=e:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,c:GetEquipTarget():GetLevel()):GetFirst()
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			--Negate its effects
			sc:NegateEffects(c)
		end
		Duel.SpecialSummonComplete()
	end
end
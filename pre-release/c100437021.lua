--Ｚ－ジリオン・キャタピラー
--Z-Zillion Tank
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Equip 1 Level 4 LIGHT Machine monster from your hand or GY to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,function(ec,c,tp) return ec:IsControler(tp) and s.eqfilter(ec,tp) end,Card.EquipByEffectAndLimitRegister,e1)
	--Union procedure
	aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE))
end
function s.eqfilter(c,tp)
	return c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:CheckUniqueOnField(tp)
		and not c:IsForbidden() and c:IsFaceup()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_REMOVED,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_REMOVED)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_REMOVED,0,1,1,nil,tp):GetFirst()
		if ec then
			c:EquipByEffectAndLimitRegister(e,tp,ec,nil,true)
		end
	end
	--Cannot Special Summon from the Extra Deck for the rest of this turn, except LIGHT monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_LIGHT) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalAttribute(ATTRIBUTE_LIGHT) end)
end
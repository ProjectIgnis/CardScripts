--慧炎星－コサンジャク
--Brotherhood of the Fire Fist - Peacock
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Link summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_FIRE_FIST),2,2)
	--Cannot be targeted for attack while pointing to a "Fire Fist" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.tgcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	--Take control 1 of opponent's monsters until end phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end
	--Lists "Fire Fist" archetype
s.listed_series={SET_FIRE_FORMATION,SET_FIRE_FIST}
	--If this card is pointing to "Fire Fist"
function s.lkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_FIRE_FIST) and c:IsMonster()
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():IsExists(s.lkfilter,1,nil)
end
	--Check for "Fire Formation" S/T for cost
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_FIRE_FORMATION) and c:IsSpellTrap() and c:IsAbleToGraveAsCost()
end
	--Activation legality
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone()&ZONES_MMZ
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged(false,zone) end
	local nc=Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_ONFIELD,0,1,nil)
	local tgchk=Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil,false,zone)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_FIRE_FIST_EAGLE) then 
			return tgchk
		else return nc and tgchk end
	end
	if nc and not (Duel.IsPlayerAffectedByEffect(tp,CARD_FIRE_FIST_EAGLE) and Duel.SelectYesNo(tp,aux.Stringid(CARD_FIRE_FIST_EAGLE,0))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g1=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.SendtoGrave(g1,REASON_COST)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g2=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil,false,zone)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g2,1,0,0)
end
	--Take control of opponent's monster until end phase, it cannot attack
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc then
		local zone=c:GetLinkedZone()&ZONES_MMZ
		if Duel.GetControl(tc,tp,PHASE_END,1,zone)~=0 then
			local reset=RESET_EVENT|RESETS_STANDARD-RESET_TURN_SET|RESET_PHASE|PHASE_END
			--Cannot attack
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3206)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(reset)
			tc:RegisterEffect(e1)
		end
	end
end
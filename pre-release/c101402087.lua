--JP name
--Skyborne Blue Cularsaw
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 Level 8 or higher DARK monster + 1 Warrior monster
	Fusion.AddProcMix(c,true,true,s.lv8matfilter,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR))
	--If this card is Fusion Summoned: You can equip 1 Warrior monster from your GY or banishment, or 1 monster from your opponent's GY or banishment, to this card as an Equip Spell that gives it 500 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsFusionSummoned()
	end)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,nil,s.equipop,e1)
	--When your opponent activates a Spell/Trap Card or effect (Quick Effect): You can send 1 Equip Card you control to the GY; negate the activation
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return rp==1-tp and re:IsSpellTrapEffect() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
			and Duel.IsChainNegatable(ev)
	end)
	e2:SetCost(s.negcost)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		Duel.NegateActivation(ev)
	end)
	c:RegisterEffect(e2)
end
local LOCATIONS_GRAVE_REMOVED=LOCATION_GRAVE|LOCATION_REMOVED
function s.lv8matfilter(c,fc,sumtype,tp)
	return c:IsLevelAbove(8) and c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)
end
function s.eqfilter(c,opp,tp)
	return (c:IsRace(RACE_WARRIOR) or (c:IsMonster() and c:IsControler(opp))) and c:IsFaceup() and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATIONS_GRAVE_REMOVED,LOCATIONS_GRAVE_REMOVED,1,nil,1-tp,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,PLAYER_EITHER,LOCATIONS_GRAVE_REMOVED)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATIONS_GRAVE_REMOVED,LOCATIONS_GRAVE_REMOVED,1,1,nil,1-tp,tp):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc)
		--Equip it to this card as an Equip Spell that gives it 500 ATK/DEF
		s.equipop(c,e,tp,sc)
	end
end
function s.equipop(c,e,tp,tc)
	if c:EquipByEffectAndLimitRegister(e,tp,tc,nil,true) then
		--Equip it to this card as an Equip Spell that gives it 500 ATK/DEF
		local e1a=Effect.CreateEffect(tc)
		e1a:SetType(EFFECT_TYPE_EQUIP)
		e1a:SetCode(EFFECT_UPDATE_ATTACK)
		e1a:SetValue(500)
		e1a:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1a)
		local e1b=e1a:Clone()
		e1b:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e1b)
	end
end
function s.negcostfilter(c)
	return c:IsEquipCard() and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
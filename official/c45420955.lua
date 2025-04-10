--迅雷の暴君 グローザー
--Groza, Tyrant of Thunder
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Synchro summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_FIEND),1,99)
	--During opponent's turn, negate 1 effect monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Apply protection when a fiend sent from hand to GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
function s.disfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end
function s.dfilter(c)
	return c:IsMonster() and c:IsDiscardable()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.disfilter(chkc) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,s.dfilter,1,1,REASON_EFFECT|REASON_DISCARD)==0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function s.cfilter(c,tp)
	return c:IsMonster() and c:IsRace(RACE_FIEND) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_HAND)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=not c:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)
	local g2=not c:IsHasEffect(EFFECT_INDESTRUCTABLE_EFFECT)
	local g3=not c:IsHasEffect(EFFECT_CANNOT_BE_EFFECT_TARGET)
	return eg:IsExists(s.cfilter,1,nil,tp)
	and (g1 or g2 or g3)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=not c:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)
	local b2=not c:IsHasEffect(EFFECT_INDESTRUCTABLE_EFFECT)
	local b3=not c:IsHasEffect(EFFECT_CANNOT_BE_EFFECT_TARGET)
	local dtab={}
	if b1 then
		table.insert(dtab,aux.Stringid(id,2))
	end
	if b2 then
		table.insert(dtab,aux.Stringid(id,3))
	end
	if b3 then
		table.insert(dtab,aux.Stringid(id,4))
	end
	local opt=Duel.SelectOption(tp,table.unpack(dtab))+1
	if not (b1 and b2) then opt=3 end
	if not (b1 and b3) then opt=2 end
	if (b1 and b3 and not b2 and opt==2) then opt=3 end
	if (b2 and b3 and not b1) then opt=opt+1 end
	if opt==1 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3000) --Cannot be destroyed by battle
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetOwnerPlayer(tp)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	elseif opt==2 then --Cannot be destroyed by opponent's card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3060)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	else --Cannot be targeted by opponent's card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3061)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.efilter(e,re,rp)
	return e:GetHandlerPlayer()==1-rp
end
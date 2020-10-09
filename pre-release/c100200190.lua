-- 迅雷の暴君 グローザー
-- Grozer the Thunderclap Tyrant
local s,id=GetID()
function s.initial_effect(c)
    --synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_FIEND),1,99)
	c:EnableReviveLimit()
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--apply when sent from hand to grave
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.condition)
    e2:SetOperation(s.effop)
    c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and aux.disfilter1(c)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)==0 then return end
	local tc=Duel.GetFirstTarget()
	if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end

function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsPreviousLocation(LOCATION_HAND)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=c:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)
	local g2=c:IsHasEffect(EFFECT_INDESTRUCTABLE_EFFECT)
	local g3=c:IsHasEffect(EFFECT_CANNOT_BE_EFFECT_TARGET)
	return eg:IsExists(s.cfilter,1,nil,tp)
	and (g1 or g2 or g3)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=c:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)
	local g2=c:IsHasEffect(EFFECT_INDESTRUCTABLE_EFFECT)
	local g3=c:IsHasEffect(EFFECT_CANNOT_BE_EFFECT_TARGET)
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
	
	if opt==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3000)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetOwnerPlayer(tp)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	elseif opt==1 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3008)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	else
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3002)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
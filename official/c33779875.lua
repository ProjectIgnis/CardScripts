--六花聖ティアドロップ
--Teardrop the Rikka Queen
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 8 monsters
	Xyz.AddProcedure(c,nil,8,2)
	--Tribute 1 monster on the field
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_RELEASE)
	e1a:SetType(EFFECT_TYPE_IGNITION)
	e1a:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCountLimit(1,id)
	e1a:SetCondition(aux.NOT(s.quickcon))
	e1a:SetCost(Cost.DetachFromSelf(1))
	e1a:SetTarget(s.tribtg)
	e1a:SetOperation(s.tribop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetType(EFFECT_TYPE_QUICK_O)
	e1b:SetCode(EVENT_FREE_CHAIN)
	e1b:SetCondition(s.quickcon)
	e1b:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1b)
	--This card gains 200 ATK for each monster Tributed, until the end of this turn
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_ATKCHANGE)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2a:SetCode(EVENT_CUSTOM+id)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetOperation(s.atkop)
	c:RegisterEffect(e2a)
	--Keep track of the number of Tributed monsters and raise the custom event using that number as the event value
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2b:SetCode(EVENT_RELEASE)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetOperation(s.regop)
	c:RegisterEffect(e2b)
end
function s.tribtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsReleasableByEffect() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectTarget(tp,Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,tp,0)
end
function s.tribop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Release(tc,REASON_EFFECT)
	end
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_PLANT)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--This card gains 200 ATK for each, until the end of this turn
		c:UpdateAttack(ev*200,RESETS_STANDARD_DISABLE_PHASE_END)
	end
end
function s.atkconfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) or (not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsMonster())
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.atkconfilter,nil)
	if ct>0 then
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,re,r,rp,ep,ct)
	end
end
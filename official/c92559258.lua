--サーヴァント・オブ・エンディミオン
--Servant of Endymion
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableCounterPermit(COUNTER_SPELL,LOCATION_PZONE+LOCATION_MZONE)
	Pendulum.AddProcedure(c)
	--Add counter (self)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(s.atkcon)
	c:RegisterEffect(e3)
	--Add counter (mass)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.ctcon2)
	e4:SetCost(s.ctcost2)
	e4:SetTarget(s.cttg2)
	e4:SetOperation(s.ctop2)
	c:RegisterEffect(e4)
	--counter check
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_DESTROY)
	e5:SetOperation(s.ctchk)
	e5:SetLabel(0)
	c:RegisterEffect(e5)
	--pendulum
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetLabelObject(e5)
	e6:SetCondition(s.pencon)
	e6:SetTarget(s.pentg)
	e6:SetOperation(s.penop)
	c:RegisterEffect(e6)
end
s.counter_place_list={COUNTER_SPELL}
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and re:GetHandler()~=c then
		c:AddCounter(COUNTER_SPELL,1)
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,COUNTER_SPELL,3,REASON_COST) end
	c:RemoveCounter(tp,COUNTER_SPELL,3,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCanAddCounter(COUNTER_SPELL,1,false,LOCATION_MZONE) and c:IsAttackAbove(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_PZONE+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e)
		or not c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		or not (Duel.GetLocationCount(tp,LOCATION_MZONE)>1)
		or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		g:AddCard(c)
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==2 then
			g:ForEach(Card.AddCounter,COUNTER_SPELL,1)
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1)>0
end
function s.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.ctcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.cttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanAddCounter(COUNTER_SPELL,1)
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCanAddCounter,COUNTER_SPELL,1),tp,LOCATION_ONFIELD,0,1,c) end
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() or not c:IsCanAddCounter(COUNTER_SPELL,1) then return end
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsCanAddCounter,COUNTER_SPELL,1),tp,LOCATION_ONFIELD,0,c)
	if #g>0 then
		g:AddCard(c)
		g:ForEach(Card.AddCounter,COUNTER_SPELL,1)
	end
end
function s.ctchk(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetCounter(COUNTER_SPELL))
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r&REASON_EFFECT+REASON_BATTLE~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabelObject():GetLabel()
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and (ct==0 or e:GetHandler():IsCanAddCounter(COUNTER_SPELL,ct,false,LOCATION_PZONE)) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		Duel.BreakEffect()
		c:AddCounter(COUNTER_SPELL,ct)
	end
end
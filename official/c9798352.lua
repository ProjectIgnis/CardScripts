--奇采のプルフィネス
--Prufinesse, the Tactical Trapper
--Scripted by Hel
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 Trap from Deck to gain 1 Level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.bdcost)
	e1:SetOperation(s.bdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Banish 1 Trap from the GY to gain 1 Level
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.bgtg)
	e3:SetOperation(s.bgop)
	c:RegisterEffect(e3)
	--Set 1 of your banished Normal Traps
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.stcon)
	e4:SetTarget(s.sttg)
	e4:SetOperation(s.stop)
	c:RegisterEffect(e4)
end
function s.cfilter(c)
	return c:IsTrap() and c:IsAbleToRemoveAsCost()
end
function s.bdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		--Increase Level by 1
		c:UpdateLevel(1)
	end
end
function s.bgfilter(c)
	return c:IsTrap() and c:IsAbleToRemove()
end
function s.bgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.bgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.bgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.bgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.bgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		--Increase Level by 1
		c:UpdateLevel(1)
	end
end
function s.stcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
function s.stfilter(c)
	return c:IsNormalTrap() and c:IsFaceup() and c:IsSSetable()
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_REMOVED,0,1,nil) end
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
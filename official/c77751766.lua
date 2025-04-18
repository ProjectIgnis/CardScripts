--火器の祝台
--Summer Schoolwork Successful!
--Scripted by Hatter
local s,id=GetID()
local COUNTER_SCHOOLWORK=0x213
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SCHOOLWORK)
	--Activate this card by placing 5 Success Counters on it
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.actg)
	c:RegisterEffect(e1)
	--Remove 1 Success Counter from this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re) return re and re:IsSpellTrapEffect() and eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_EXTRA) end)
	e2:SetTarget(s.rcttg)
	e2:SetOperation(s.rctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re) return re and re:IsSpellTrapEffect() and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_DECK) end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SCHOOLWORK}
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsCanAddCounter(tp,COUNTER_SCHOOLWORK,5,c) end
	c:AddCounter(COUNTER_SCHOOLWORK,5)
end
function s.rcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,4000)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.setfilter(c)
	return c:IsSetCard(SET_SCHOOLWORK) and c:IsTrap() and c:IsSSetable()
end
function s.rctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:RemoveCounter(tp,COUNTER_SCHOOLWORK,1,REASON_EFFECT) and not c:HasCounter(COUNTER_SCHOOLWORK)) then return end
	Duel.BreakEffect()
	if Duel.Destroy(c,REASON_EFFECT)==0 or Duel.Recover(tp,4000,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.BreakEffect()
	if Duel.SSet(tp,sc)>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=1 then
		Duel.BreakEffect()
		Duel.Win(tp,WIN_REASON_SUMMER_SCHOOLWORK)
	end
end
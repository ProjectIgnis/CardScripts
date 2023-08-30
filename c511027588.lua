--虹の引力
--Rainbow Gravity
--Made by When
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x1034}
function s.cfilter(c)
	return c:IsSetCard(0x1034) and (not c:IsOnField() or c:IsFaceup())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>6
end
function s.spfilter(c,e,tp)
	return (c:IsCode(79856792) or c:IsCode(511600140)) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and g:IsExists(s.spfilter,1,nil,e,tp) end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,1,nil,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP) then
		    if Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) and Duel.IsBattlePhase() then
		       local e1=Effect.CreateEffect(c)
           	       e1:SetType(EFFECT_TYPE_FIELD)
           	       e1:SetCode(EFFECT_MUST_ATTACK)
           	       e1:SetRange(LOCATION_MZONE)
                       e1:SetTarget(aux.TargetBoolFunction(Card.IsAttackPos))
           	       e1:SetTargetRange(0,LOCATION_MZONE)
                       e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
           	       tc:RegisterEffect(e1)
           	       local e2=e1:Clone()
           	       e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
           	       e2:SetValue(s.atklimit)
           	       tc:RegisterEffect(e2)
                    end
              end
	end
end
function s.atklimit(e,c)
	return c==e:GetHandler()
end

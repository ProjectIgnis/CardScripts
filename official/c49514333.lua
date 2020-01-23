--ソウル・オブ・スタチュー
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e1:SetLabelObject(g)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and 
		Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,1000,1800,4,RACE_ROCK,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,1000,1800,4,RACE_ROCK,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetLabelObject(e)
	c:RegisterEffect(e1,true)
	Duel.SpecialSummonComplete()
end
function s.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:GetDestination()==LOCATION_GRAVE and c:IsReason(REASON_DESTROY)
		and c:GetReasonPlayer()~=tp and c:GetOwner()==tp and (c:GetOriginalType()&TYPE_TRAP)~=0 and c:IsCanTurnSet()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(s.repfilter,e:GetHandler(),tp)
		return count>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=count
	end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local container=e:GetLabelObject():GetLabelObject()
		container:Clear()
		local g=eg:Filter(s.repfilter,e:GetHandler(),tp)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
		Duel.ChangePosition(g,POS_FACEDOWN)
		container:Merge(g)
		return true
	end
	return false
end
function s.repval(e,c)
	return e:GetLabelObject():GetLabelObject():IsContains(c)
end

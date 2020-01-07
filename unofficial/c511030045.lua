--機塊テスト
--Appliancer Test
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:GetSequence()>4 and c:IsSetCard(0x57a) and c:IsLinkMonster()
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,fc)
	local zone=fc:GetToBeLinkedZone(c,tp,true)
	return c:IsSetCard(0x57a) and c:IsLinkMonster() and c:IsLink(1)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetHandler():GetFieldID()
	local c=Duel.GetFirstTarget()
	local zone=c:GetFreeLinkedZone()&0x1f
	local count=s.zone_count(zone)
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,c)
	if #sg<count then count=#sg end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then count=1 end
	if c:IsFaceup() and c:IsRelateToEffect(e) and zone~=0 then
		for i=0,count,1
		do
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c)
			local tc=g:GetFirst()
			if tc then
				local zone=c:GetToBeLinkedZone(tc,tp,true)
				if zone>0 then
					Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone)
					--0 ATK
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_SET_ATTACK_FINAL)
					e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
					e1:SetValue(0)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
				end
			end
		end
		Duel.SpecialSummonComplete()
		--banish them during this End Phase
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetOperation(s.rmop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.rmfilter(c)
	return c:GetFlagEffect(id)>0
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil)
	if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end
function s.zone_count(z)
	local c=0
	while z>0 do
		c=c+1
		z=z&(z-1)
	end
	return c
end
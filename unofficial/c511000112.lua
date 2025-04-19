--拘束解除
--Front Change
--Re-scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Summon "Assault Cannon Beetle"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.hint)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg(511000111,511000110))
	e1:SetOperation(s.op(511000111,511000110))
	c:RegisterEffect(e1)
	--Summon "Combat Scissor Beetle"
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetTarget(s.tg(511000110,511000111))
	e2:SetOperation(s.op(511000110,511000111))
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_names={511000110,511000111}
function s.counterfilter(c)
	return not c:IsCode(511000110)
end
function s.hint(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end
function s.tefilter(c,e,tp,code1,code2)
	return c:IsCode(code1) and c:IsAbleToExtra() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,code2,c)
end
function s.spfilter(c,e,tp,code,fc)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,fc,c)>0
end
function s.tg(code1,code2)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(s.tefilter,tp,LOCATION_MZONE,0,1,nil,e,tp,code1,code2) end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function s.op(code1,code2)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tc=Duel.SelectMatchingCard(tp,s.tefilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,code1,code2):GetFirst()
		if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sp=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,code2):GetFirst()
			if sp then
				Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
				if sp:IsCode(511000111) then sp:CompleteProcedure() end
			end
		end
	end
end
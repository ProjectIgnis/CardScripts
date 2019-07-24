--Eternal Bond
--  By Shad3
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x55) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=nil
	if #tg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if #g<=0 then return end
	local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil)
	if ct>0 then
		if ct>#mg then
			local sg=mg:Filter(Card.IsControlerCanBeChanged,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local ctg=sg:Select(tp,1,1,nil)
			local tc=ctg:GetFirst()
			if tc then
				Duel.HintSelection(ctg)
				Duel.GetControl(tc,tp)
			end
		end
		local atkg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local ag=atkg:Select(tp,1,1,nil)
		local tc=ag:GetFirst()
		if tc then
			Duel.HintSelection(ag)
			atkg=atkg:Filter(aux.TRUE,tc)
			local atk=atkg:GetSum(Card.GetAttack)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(atk)
			tc:RegisterEffect(e1)
		end
	end
end

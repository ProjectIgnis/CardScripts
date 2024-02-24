--Spell of Mask
local s,id=GetID()
function s.initial_effect(c)
	aux.AddVrainsSkillProcedure(c,s.spcond,s.spop,EVENT_DESTROYED)
	aux.AddSkillProcedure(c,1,false,s.thcond,s.thop,1)
end
local LOCATION_HAND_DECK_GY=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE
s.listed_names={49064413,48948935,94377247} --The Masked Beast, Masked Beast Des Gardius, Curse of the Masked Beast
function s.desfilter(c,tp)
	return c:IsCode(49064413) and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsReason(REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function s.spfilter(c,e,tp)
	return c:IsCode(48948935) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0 and eg:IsExists(s.desfilter,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND_DECK_GY,0,1,nil,e,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	--Special Summon 1 "Masked Beast Des Gradius"
	if Duel.GetFlagEffect(tp,id)~=0 or Duel.SelectYesNo(tp,aux.Stringid(id,0))==0 then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND_DECK_GY,0,1,1,nil,e,tp)
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
	--Search 1 "The Masked Beast" and 1 "Curse of the Masked Beast"
	if Duel.GetFlagEffect(tp,id+1)~=0 then return end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.thcond)
	e2:SetOperation(s.thop)
	Duel.RegisterEffect(e2,tp)
end
function s.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+1)==0 and aux.CanActivateSkill(tp)
		and Duel.CheckReleaseGroupCost(tp,Card.IsCode,1,false,nil,nil,48948935)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,49064413)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,94377247)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)~=0 or Duel.SelectYesNo(tp,aux.Stringid(id,1))==0 then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsCode,1,1,false,nil,nil,48948935)
	if Duel.Release(g,REASON_COST)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,49064413)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,94377247)
		g1:Merge(g2)
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
	end
	--Special Summon 1 "Masked Beast Des Gardius" if "The Masked Beast" is destroyed
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.spcond)
	e1:SetOperation(s.spop)
	Duel.RegisterEffect(e1,tp)
end
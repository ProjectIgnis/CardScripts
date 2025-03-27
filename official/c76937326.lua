--ダイガスタ・ラプラムピリカ
--Daigusto Laplampilica
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Synchro procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_GUSTO),1,99)
	c:EnableReviveLimit()
	--Special Summon 2 "Gusto" monsters and Synchro Summon using them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Cannot be targeted by effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tgtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GUSTO}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSynchroSummoned()
end
function s.matfilter(c,e,tp)
	return c:IsSetCard(SET_GUSTO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter(c,mg,tp,chk)
	return c:IsSetCard(SET_GUSTO) and c:IsType(TYPE_SYNCHRO) and (not chk or Duel.GetLocationCountFromEx(tp,tp,mg,c)>0) and (not mg or Card.IsSynchroSummonable(c,nil,mg,#mg,#mg))
end
function s.rescon(exg)
	return function(sg,e,tp,mg)
		local _1,_2=aux.dncheck(sg,e,tp,mg)
		return sg:GetClassCount(Card.GetLocation)==#sg and exg:IsExists(Card.IsSynchroSummonable,1,nil,nil,sg,#sg,#sg),_2
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local exg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,nil,tp)
	local cancelcon=s.rescon(exg)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if chk==0 then return ft>1 and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and aux.SelectUnselectGroup(mg,e,tp,1,2,cancelcon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	--cannot special summon except wind
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--synchro part
	local exg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,nil,tp)
	local cancelcon=s.rescon(exg)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	local g=aux.SelectUnselectGroup(mg,e,tp,1,2,cancelcon,1,tp,HINTMSG_SPSUMMON,cancelcon)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g or #g==0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1) then return end
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()
	local syng=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,g,tp,true)
	if #syng>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local c=syng:Select(tp,1,1,nil):GetFirst()
		Duel.SynchroSummon(tp,c,nil,g,#g,#g)
	end
end
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
--opponent cannot target
function s.tgtg(e,c)
	return c:IsSetCard(SET_GUSTO) and c:IsType(TYPE_SYNCHRO) and c~=e:GetHandler()
end
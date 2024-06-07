--烙印の即凶劇
--Etude of the Branded
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Synchro Summon using a Dragon monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
	--Banished instead
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_ALL)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
s.listed_series={SET_BYSTIAL}
function s.checkaddition(tp,sg,sc)
	return sg:IsExists(Card.IsRace,1,nil,RACE_DRAGON)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		Synchro.CheckAdditional=s.checkaddition
		local res=Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil)
		Synchro.CheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	Synchro.CheckAdditional=s.checkaddition
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst())
	else
		Synchro.CheckAdditional=nil
	end
end
function s.rmcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_BYSTIAL),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.rmtg(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetOwner()==1-tp and Duel.IsPlayerCanRemove(tp,c) and c:GetReasonPlayer()==1-tp
		and (c:GetReason()&(REASON_RELEASE|REASON_RITUAL)==(REASON_RELEASE|REASON_RITUAL)
		or c:IsReason(REASON_FUSION|REASON_SYNCHRO|REASON_LINK))
end
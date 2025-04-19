--Speed Spell - Deceased Synchron (Anime)
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--synchro effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.con)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(e:GetHandler():GetControler(),LOCATION_FZONE,0)
	return tc and tc:GetCounter(0x91)>4
end
function s.spfilter(c,tp)
	local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_GRAVE,0,nil,c)
	return c:IsSynchroSummonable(nil,mg) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_EXTRA) and s.spfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	Duel.SetTargetCard(g:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g:GetFirst(),1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_GRAVE,0,nil,tc)
	Synchro.Send=2
	if not tc then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	e1:SetOperation(s.regop)
	tc:RegisterEffect(e1)
	Duel.SynchroSummon(tp,tc,nil,mg)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetOwner()
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1)
	e:Reset()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end